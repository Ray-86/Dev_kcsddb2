/*
 10/14/05 KC: 增加指定編號執行, 用來更新已結清的case
 10/22/05 KC: 不管呆帳T
*/
CREATE        PROCEDURE [kcsd].[p_kc_updateloanstatus_old(停用)] @pm_case_no varchar(10)=NULL
AS
--Status: N: 新資料, C: 結案[待結案], D: 逾期, E: 逾期結清(末期逾期 >= 2 個月), G: 正常, X: 取消,P: 核准, R: 退件, S: 照會, T: 呆帳

DECLARE	@wk_case_no	varchar(10),
		@wk_loan_stat	char(1),
		@wk_over_count	int,
		@wk_expt_count	int,
		@wk_over_count_org	int,
		@wk_pay_count	int,
		@wk_pay_count_org	int,
		@wk_dday_count	int,	/* 逾期月數 */
		@wk_dday_count_org	int,
		@wk_dday_date	datetime,/* 逾期起始日 */
		@wk_dday_date_org	datetime,
		@wk_perd_fee		int,
		@wk_over_amt		int,	/* 逾期金額 */
		@wk_over_amt_org	int,
		@wk_break_amt	int,	/* 違約金 */
		@wk_break_amt_org	int,	
		@wk_break_amt_m	int,
		@wk_break_amt2	int,	/* 天數違約金 */
		@wk_break_amt2_org	int,
		@wk_rema_amt		int,	/* 剩餘金額 */
		@wk_rema_amt_org	int,
		@wk_apply_stat		char(1)	/* 核准/未核准 */

SELECT	@wk_expt_count = 0, 
		@wk_over_count = 0, @wk_over_count_org = 0,
		@wk_pay_count = 0, @wk_pay_count_org = 0,
		@wk_dday_count = 0, @wk_dday_count_org = 0,
		@wk_over_amt = 0, @wk_break_amt = 0,@wk_break_amt_m = 0,
		@wk_rema_amt = 0, @wk_break_amt2 = 0,
		@wk_dday_date = NULL,
		@wk_apply_stat = NULL

IF	@pm_case_no IS NULL	/* Normal */
BEGIN
	UPDATE	kcsd.kc_customerloan
	SET	kc_loan_stat = 'N',
		kc_over_count = 0, kc_pay_count = 0
	WHERE	kc_loan_stat IS NULL

	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	kc_case_no, kc_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_loan_stat <> 'X'
		AND	kc_loan_stat <> 'C'
		AND	kc_loan_stat <> 'E'
		AND	kc_loan_stat <> 'R'
		AND	kc_loan_stat <> 'T'	/* 不管呆帳 */
END
ELSE	/* 指定編號執行 */
BEGIN
	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	kc_case_no, kc_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_loan_stat <> 'X'
		AND	kc_loan_stat <> 'R'
		AND	kc_case_no = @pm_case_no
END


OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_count=0, @wk_dday_date=NULL, @wk_over_amt=0,
		@wk_pay_count=0, @wk_rema_amt=0

	/* 處理退件 */
	IF	@wk_loan_stat IS NULL
	BEGIN
		SELECT	@wk_apply_stat = kc_apply_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		IF	@wk_apply_stat = 'R'
		BEGIN
			UPDATE	kcsd.kc_customerloan
			SET	kc_loan_stat = 'R'
			WHERE	kc_case_no = @wk_case_no

			RETURN
		END
	END

	/* 計算實際逾期期數, delay 天數, 及金額 */
	SELECT	@wk_over_count=COUNT(kc_case_no),
		@wk_dday_date = MIN(kc_expt_date),
		@wk_over_amt = ISNULL(SUM(kc_expt_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date IS NULL
	AND	kc_expt_date < GETDATE()

	/* 計算實際繳款期數 */
	SELECT	@wk_pay_count=COUNT(kc_case_no)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date IS NOT NULL

	/* 計算剩餘金額 */
	SELECT	@wk_rema_amt = SUM(kc_expt_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date IS NULL	

	SELECT	@wk_dday_count = DATEDIFF(month,ISNULL(@wk_dday_date,GETDATE()),GETDATE()) 
 	--SELECT	@wk_dday_count = DATEDIFF(day,ISNULL(@wk_dday_date,GETDATE()),GETDATE()) / 30
	IF	@wk_dday_count < 0
		SELECT	@wk_dday_count = 0

	/* 計算違約金 */
	SELECT	@wk_perd_fee = kc_perd_fee
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_break_amt_m = ROUND(@wk_perd_fee*0.02,0)
	SELECT	@wk_break_amt = @wk_break_amt_m*(@wk_dday_count+@wk_dday_count-@wk_over_count+1)*@wk_over_count/2.0

	/* 計算天數違約金 */
	EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt2 OUTPUT

	/* 取得原有逾期期數等資料 */
	SELECT	@wk_over_count_org = ISNULL(kc_over_count,0),
		@wk_pay_count_org = ISNULL(kc_pay_count,0),
		@wk_dday_date_org = kc_dday_date,
		@wk_dday_count_org = ISNULL(kc_dday_count,0),
		@wk_over_amt_org = ISNULL(kc_over_amt,0),
		@wk_break_amt_org = ISNULL(kc_break_amt,0),
		@wk_break_amt2_org = ISNULL(kc_break_amt2, 0),
		@wk_rema_amt_org = ISNULL(kc_rema_amt,0)
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* 更新逾期統計 */	
	IF	(@wk_over_count <> @wk_over_count_org)
	OR	(@wk_pay_count <> @wk_pay_count_org)
	OR	(@wk_dday_date <> @wk_dday_date_org)
	OR	(@wk_dday_count <> @wk_dday_count_org)
	OR	(@wk_over_amt <> @wk_over_amt_org)
	OR	(@wk_break_amt <> @wk_break_amt_org)
	OR	(@wk_break_amt2 <> @wk_break_amt2_org)
	OR	(@wk_rema_amt <> @wk_rema_amt_org)	BEGIN
		UPDATE	kcsd.kc_customerloan
		SET	kc_over_count = @wk_over_count,
			kc_pay_count = @wk_pay_count,
			kc_dday_date = @wk_dday_date,
			kc_dday_count = @wk_dday_count,
			kc_over_amt = @wk_over_amt,
			kc_break_amt = @wk_break_amt,
			kc_break_amt2 = @wk_break_amt2,
			kc_rema_amt = @wk_rema_amt
		WHERE	kc_case_no = @wk_case_no
	END
	IF	@wk_over_count > 0	/* 逾期 */
	BEGIN		
		IF	@wk_loan_stat <> 'D'
		BEGIN
			SELECT	@wk_loan_stat = 'D'

			UPDATE	kcsd.kc_customerloan
			SET	kc_loan_stat = @wk_loan_stat
			WHERE	kc_case_no = @wk_case_no
		END
	END
	ELSE	/* 未欠款 (@wk_over_count=0) */
	BEGIN
		/* 計算是否還有未到期的分期 */
		SELECT	@wk_expt_count=COUNT(kc_case_no)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date IS NULL
		AND	kc_expt_fee > 0	

		IF	@wk_expt_count = 0 /* 已付清 */
		BEGIN
			/* 逾期結清 */
			IF	@wk_dday_count_org >= 2
			BEGIN
				SELECT	@wk_loan_stat = 'E'

				UPDATE	kcsd.kc_customerloan
				SET	kc_loan_stat = @wk_loan_stat
				WHERE	kc_case_no = @wk_case_no
			END

			ELSE
			BEGIN
				SELECT	@wk_loan_stat = 'C'

				UPDATE	kcsd.kc_customerloan
				SET	kc_loan_stat = @wk_loan_stat
				WHERE	kc_case_no = @wk_case_no
			END
		END
		ELSE	/* 還有未到期的分期 */
		IF	@wk_loan_stat <> 'G'
		BEGIN
			UPDATE	kcsd.kc_customerloan

			SET	kc_loan_stat = 'G'
			WHERE	kc_case_no = @wk_case_no
		END
	END
	
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_loan_stat
END

DEALLOCATE	cursor_case_no

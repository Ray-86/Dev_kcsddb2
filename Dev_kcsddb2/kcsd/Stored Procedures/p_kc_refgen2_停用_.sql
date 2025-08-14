-- =============================================
-- 07/01/06 KC:	for DY1, copy from p_kc_refgen
-- KC: last pay date 5/31/06
-- =============================================
CREATE     PROCEDURE [kcsd].[p_kc_refgen2(停用)] 
	@pm_run_code varchar(10)=NULL,
	@pm_case_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_buy_date	datetime,
	@wk_expt_date	datetime,
	@wk_pay_date	datetime,
	@wk_delay_days	int,
	@wk_ref_memo	varchar(200),
	@wk_cut_date	datetime
	
SELECT	@wk_case_no=NULL,
--	@wk_cut_date = '6/1/2006'	-- less than cut date
	@wk_cut_date = '6/1/2007'	-- less than cut date

DECLARE	cursor_case_no_ref	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsddb.kcsd.dy1kc_customerloan
	WHERE	(	kc_loan_stat = 'C'
		OR	kc_loan_stat = 'E')
--	AND	kc_case_no BETWEEN 'E7339' AND 'E7399'		-- part1: 7/1/06 已執行
--	AND	kc_case_no > 'E7399' AND kc_case_no LIKE 'E%'	-- part2: 7/8/06 已執行
--	AND	kc_case_no LIKE 'F%'				-- part2: 7/8/06 已執行
--	AND	kc_case_no LIKE 'G%'				-- part2: 7/8/06 已執行
--	AND	kc_case_no LIKE 'H%'				-- part2: 7/8/06 已執行
	AND	kc_case_no NOT IN (SELECT	kc_case_no
				   FROM		kcsd.kc_refexception)
	ORDER BY kc_case_no

CREATE TABLE #tmp_refgen
(kc_case_no	varchar(10),
kc_buy_date	datetime,
kc_expt_date	datetime,
kc_pay_date	datetime,
kc_delay_days	int,
kc_ref_memo	varchar(200)
)

OPEN cursor_case_no_ref
FETCH NEXT FROM cursor_case_no_ref INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_buy_date = NULL, @wk_expt_date = NULL, @wk_pay_date = NULL,
		@wk_ref_memo = NULL

	/* Get basic info */
	SELECT	@wk_buy_date = kc_buy_date
	FROM	kcsddb.kcsd.dy1kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* Get last payment */
	SELECT	@wk_expt_date = MAX(kc_expt_date)
	FROM	kcsddb.kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_pay_date = MAX(kc_pay_date)
	FROM	kcsddb.kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date IS NOT NULL

	-- skip
	IF	@wk_pay_date >= @wk_cut_date
	BEGIN
		FETCH NEXT FROM cursor_case_no_ref INTO @wk_case_no
		CONTINUE
	END

	SELECT	@wk_delay_days = DATEDIFF(day, @wk_expt_date , @wk_pay_date)
	IF	@wk_delay_days < 0
		SELECT	@wk_delay_days = 0

	SELECT	@wk_ref_memo = '( ' + CONVERT(varchar(8), @wk_buy_date, 12) + ' - '
				+ CONVERT(varchar(8), @wk_pay_date, 12) + ' ) '
				+ CONVERT(varchar(10),@wk_delay_days)

	INSERT	#tmp_refgen
		(kc_case_no, kc_buy_date, kc_expt_date, kc_pay_date, kc_delay_days, kc_ref_memo)
	VALUES	(@wk_case_no, @wk_buy_date, @wk_expt_date, @wk_pay_date, @wk_delay_days, @wk_ref_memo)

	IF	@pm_run_code = 'EXECUTE'
	BEGIN
-- reference
		INSERT	kcsd.kc_reference
			(kc_ref_no, 
			kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
			kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
			kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2,
			kc_ref_memo
			)
		SELECT	kc_case_no,
			kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
			kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
			kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2,
			@wk_ref_memo
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_case_no = @wk_case_no
-- customerloan
		INSERT	refdb.kcsd.kc_customerloan2
		SELECT	*
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_case_no = @wk_case_no
-- loanpayment	
		INSERT	refdb.kcsd.kc_loanpayment2
		SELECT	*
		FROM	kcsddb.kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
-- push
		INSERT	refdb.kcsd.kc_push2
		SELECT	*
		FROM	kcsddb.kcsd.kc_push
		WHERE	kc_case_no = @wk_case_no
	END

	IF	@pm_run_code = 'CLEAR'
	BEGIN
		DELETE
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		-- no need to clear loanpayment because customerloan will also delete loanpayment
		/*
		DELETE
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no */

		DELETE
		FROM	kcsddb.kcsd.kc_push
		WHERE	kc_case_no = @wk_case_no
	END

	FETCH NEXT FROM cursor_case_no_ref INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_ref

SELECT	*
FROM	#tmp_refgen
ORDER BY kc_case_no

DROP TABLE #tmp_refgen

-- ==========================================================================================
--01/05/08 新增 kc_intr_fee 計算
--
-- ==========================================================================================

CREATE        PROCEDURE [kcsd].[p_kc_pushscore_test] @pm_strt_date datetime, @pm_stop_date datetime
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_perd_no	int,
	@wk_pay_date	datetime,
	@wk_pay_fee	int,
	@wk_break_fee	int,
	@wk_intr_fee	int,
	@wk_pusher_code	varchar(6)
--	@wk_rece_code varchar(2)

CREATE TABLE #tmp_pushscore
(
	kc_case_no	varchar(10),
	kc_perd_no	int,
	kc_pay_date	datetime,
	kc_pay_fee	int,
	kc_break_fee	int,
	kc_intr_fee	int,
	kc_pusher_code	varchar(6)
--	kc_rece_code	varchar(2)
)

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_perd_no
	FROM	kcsd.kc_loanpayment
	WHERE	kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND kc_expt_date > @pm_strt_date
	and kc_case_no in (select kc_case_no FROM kcsd.kc_loanpayment WHERE kc_rece_code = 'A2' )
	--and kc_case_no not in (SELECT kc_case_no FROM kcsd.kc_customerloan where kc_loan_stat IN ('C','E'))

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pay_date=NULL, @wk_pay_fee=0, @wk_break_fee=0, @wk_intr_fee=0,
		@wk_pusher_code=NULL--,@wk_rece_code=NULL

	SELECT	@wk_pay_date = kc_pay_date, @wk_pay_fee = kc_pay_fee,
		@wk_break_fee = kc_break_fee, @wk_intr_fee = kc_intr_fee
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no

	/* 找出當時催收人 */
	SELECT	@wk_pusher_code = kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date <= @wk_pay_date
	--AND	( kc_stop_date >= @wk_pay_date OR kc_stop_date IS NULL)
	AND	kc_stop_date >= @wk_pay_date

	-- 是否目前還在催收
	IF	@wk_pusher_code IS NULL
		SELECT	@wk_pusher_code = kc_pusher_code
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date <= @wk_pay_date
		AND	kc_stop_date IS NULL
	
	IF	@wk_pusher_code IS NOT NULL
	BEGIN

--		SELECT @wk_rece_code = kc_rece_code  FROM kcsd.kc_loanpayment WHERE kc_rece_code = 'A2' and kc_case_no = @wk_case_no

		INSERT	#tmp_pushscore
			(kc_case_no, kc_perd_no, kc_pay_date,
			kc_pay_fee, kc_break_fee, kc_intr_fee, kc_pusher_code)
		VALUES	(@wk_case_no, @wk_perd_no, @wk_pay_date,
			@wk_pay_fee,  @wk_break_fee, @wk_intr_fee, @wk_pusher_code)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no
END
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_pushscore order by kc_pusher_code,kc_case_no

DROP TABLE #tmp_pushscore

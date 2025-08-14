/* 10/07/05 KC:  修改自 pushassign_close, 轉換 P1 用 */
/* 11/26/05 KC:  修改自 pushassign_close, 轉換 P61 用 */
CREATE   PROCEDURE [kcsd].[p_kc_pushassign_close_new(停用)]
	@pm_run_code varchar(10)=NULL,
	@pm_due_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_perd_strt	datetime,		/* 本月1日 */
	@wk_perd_lstrt	datetime,		/* 上月第一天 (M1基準日) */
	@wk_perd_lstop	datetime,		/* 上月最後一天 */
	@wk_lpay_date	datetime,
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */
	@wk_count	int

IF	@pm_due_date IS NULL
	SELECT	@pm_due_date = GETDATE()

SELECT	@wk_case_no=NULL, @wk_count = 0

/* 抓上月第一天/最後一天 */
SELECT	@wk_perd_strt = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
	+ CONVERT(char(4), DATEPART(year, GETDATE()))
SELECT	@wk_perd_lstrt = DATEADD(month, -1, @wk_perd_strt)
SELECT	@wk_perd_lstop = DATEADD(day, -1, @wk_perd_strt)

CREATE TABLE #tmp_assignclose
(
kc_case_no	varchar(10) not null,
kc_strt_date	datetime not null,
kc_lpay_date	datetime null
)

/* M0 不管何時結束, 每天計算 */
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	c.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_pushassign p
	WHERE	p.kc_stop_date IS NULL
	AND	c.kc_case_no = p.kc_case_no
	AND	(c.kc_loan_stat = 'G'
		OR c.kc_loan_stat = 'C'
		OR c.kc_loan_stat = 'E' )
	/* P1使用
	AND	(	c.kc_pusher_code = '1105'
		OR	c.kc_pusher_code = '1106'
		OR	c.kc_pusher_code = '1110'
		OR	c.kc_pusher_code = '1113'
		OR	c.kc_pusher_code = '1168'
		OR	c.kc_pusher_code = '1132')
	*/
	/* P61使用 */
	AND	(	c.kc_pusher_code = '1139'
		OR	c.kc_pusher_code = '1142' )
	ORDER BY c.kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_lpay_date = NULL, @wk_strt_date = NULL

	SELECT	@wk_strt_date = kc_strt_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_stop_date IS NULL

	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @pm_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	IF	@wk_over_amt = 0
	BEGIN
		/* 上月底前最後一次付款日*/
		SELECT	@wk_lpay_date = MAX(kc_pay_date)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date IS NOT NULL

		INSERT	#tmp_assignclose
			(kc_case_no, kc_strt_date, kc_lpay_date)
		VALUES	(@wk_case_no, @wk_strt_date, @wk_lpay_date)

		/* 執行指派結束 */
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = GETDATE(),
				kc_updt_user = USER, kc_updt_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = NULL, kc_pusher_date = NULL,
				kc_delay_code = NULL
			WHERE	kc_case_no = @wk_case_no
		END
		SELECT	@wk_count = @wk_count + 1
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	t.*, c.kc_pusher_code
FROM	#tmp_assignclose t, kc_customerloan c
WHERE	t.kc_case_no = c.kc_case_no
/*ORDER BY c.kc_pusher_code, t.kc_lpay_date*/
ORDER BY t.kc_case_no

SELECT	@wk_count AS count, @wk_perd_lstrt AS perd_lstrt, @wk_perd_lstop AS perd_lstop

DROP TABLE #tmp_assignclose

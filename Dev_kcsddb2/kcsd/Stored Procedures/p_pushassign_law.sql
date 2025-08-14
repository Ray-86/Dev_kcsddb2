/* @pm_age_date 為上月最後一天 */
CREATE PROCEDURE [kcsd].[p_pushassign_law]
	@pm_run_code varchar(20)=NULL, @pm_age_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_due_date	datetime,		/* age_date+1 */
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime		/* dummy for p_kc_getoveramt */

CREATE TABLE #tmp_debtage
(kc_case_no	varchar(10),
kc_expt_sum	int,			/* 逾期金額 */
kc_arec_amt	int,			/* 未繳金額 */
kc_dday_count	int			/* 逾期月數 */
)

SELECT	@wk_case_no=NULL

/* 參數為Null: 預設帳齡基準日為上月最後一天 */
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_age_date = DATEADD(day, -1, @pm_age_date)
END

DECLARE	cursor_case_no_law	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'D'
	AND	kc_buy_date <= @pm_age_date
	AND	kc_pusher_code <> '1111'
	AND	kc_pusher_code IS NOT NULL

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

OPEN cursor_case_no_law
FETCH NEXT FROM cursor_case_no_law INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	IF	@wk_over_amt > 0
	AND	DATEDIFF(month, @wk_dday_date, @pm_age_date) >= 4	/* 超過4個月(含) */
	BEGIN
		SELECT	@wk_case_no
	END		

	FETCH NEXT FROM cursor_case_no_law INTO @wk_case_no
END

SELECT	*
FROM	#tmp_debtage
ORDER BY kc_case_no

/*
SELECT	SUM(kc_expt_sum)
FROM	#tmp_debtage
*/
DEALLOCATE	cursor_case_no_law

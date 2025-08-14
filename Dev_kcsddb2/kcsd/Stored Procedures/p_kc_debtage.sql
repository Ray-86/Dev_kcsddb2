
-- ==========================================================================================
-- 20170301 修正計算方式(只計算購買日區間內案件)
-- ==========================================================================================

CREATE   PROCEDURE kcsd.p_kc_debtage	@pm_age_date datetime=NULL
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

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date <= @pm_age_date
SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	IF	@wk_over_amt > 0
	BEGIN
		INSERT	#tmp_debtage
			(kc_case_no, kc_expt_sum, kc_arec_amt,
			kc_dday_count)
		VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,
			DATEDIFF(month, @wk_dday_date, @pm_age_date) )
	END		

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

SELECT	*
FROM	#tmp_debtage
ORDER BY kc_case_no

/*
SELECT	SUM(kc_expt_sum)
FROM	#tmp_debtage
*/
DEALLOCATE	cursor_case_no

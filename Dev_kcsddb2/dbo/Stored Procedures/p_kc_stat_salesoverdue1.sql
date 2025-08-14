/* 11/12/05 KC: proc for 業務逾期統計 kcp_stat01 */
CREATE PROCEDURE [dbo].[p_kc_stat_salesoverdue1]
	@pm_strt_date DATETIME=NULL,
	@pm_stop_date DATETIME=NULL,
	@pm_cut_date DATETIME=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */
	@wk_pay_sum	int

CREATE TABLE #tmp_salesoverdue
(kc_case_no	varchar(10),
kc_over_amt	int,
kc_over_count	int,
kc_pay_sum	int
)

IF	@pm_strt_date IS NULL
	SELECT	@pm_strt_date = '1/1/2000'
IF	@pm_stop_date IS NULL
	SELECT	@pm_stop_date = GETDATE()
IF	@pm_cut_date IS NULL
	SELECT	@pm_cut_date = GETDATE()

SELECT	@pm_cut_date = DATEADD(day, 1, @pm_cut_date )

SELECT	@wk_case_no=NULL


DECLARE	cursor_caseno_overdue	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date


OPEN cursor_caseno_overdue
FETCH NEXT FROM cursor_caseno_overdue INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	

	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_dday_date = NULL, @wk_pay_sum = 0

	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @pm_cut_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	IF	@wk_over_amt > 0
	BEGIN
		SELECT	@wk_pay_sum = ISNULL(SUM(kc_pay_fee), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date < @pm_cut_date

		INSERT	#tmp_salesoverdue
			(kc_case_no, kc_over_amt, kc_over_count, kc_pay_sum)
		VALUES	(@wk_case_no, @wk_over_amt, DATEDIFF(day, @wk_dday_date, @pm_cut_date)/30, @wk_pay_sum )
	END

	FETCH NEXT FROM cursor_caseno_overdue INTO @wk_case_no
END

DEALLOCATE	cursor_caseno_overdue

SELECT	*
FROM	#tmp_salesoverdue

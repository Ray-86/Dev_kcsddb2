CREATE       PROCEDURE [kcsd].[p_kc_paystat] @pm_strt_date DATETIME=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_loop_date	datetime,
	@wk_expt_fee1	int,
	@wk_expt_fee	int,
	@wk_prepay_sum	int,
	@wk_norm_pay	int,
	@wk_delay_pay	int,
	@wk_no_pay	int
/*
CREATE TABLE #tmp_custpaystat
(
kc_expt_date	datetime,
kc_expt_fee	int,
kc_norm_pay	int,
kc_delay_pay	int,
kc_no_pay	int
)*/

/* 抓上月第一天/最後一天 */
IF	@pm_strt_date IS NULL
OR	@pm_stop_date IS NULL
BEGIN
	SELECT	@pm_stop_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_strt_date = DATEADD(month, -1, @pm_stop_date)
	SELECT	@pm_stop_date = DATEADD(day, -1, @pm_stop_date)
END

SELECT	@wk_loop_date = @pm_strt_date

WHILE	(@wk_loop_date <= @pm_stop_date)
BEGIN	
	SELECT	@wk_expt_fee1 = 0, @wk_prepay_sum = 0

	SELECT	@wk_expt_fee1 = ISNULL(SUM(kc_expt_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_expt_date = @wk_loop_date
	AND	kc_perd_no < 50

	SELECT	@wk_prepay_sum = ISNULL(SUM(kc_pay_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_expt_date = @wk_loop_date
	AND	kc_pay_date < @pm_strt_date

	SELECT	@wk_expt_fee = @wk_expt_fee1 - @wk_prepay_sum
	/*
	SELECT	@wk_expt_fee = ISNULL(SUM(kc_expt_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_expt_date = @wk_loop_date
	AND	kc_perd_no < 50 */

	SELECT	@wk_norm_pay = ISNULL(SUM(kc_pay_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_expt_date = @wk_loop_date
	/* AND	kc_pay_date <= kc_expt_date */
	AND	kc_pay_date BETWEEN @pm_strt_date AND kc_expt_date

	SELECT	@wk_delay_pay = ISNULL(SUM(kc_pay_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_expt_date = @wk_loop_date
	AND	kc_pay_date > kc_expt_date
	AND	kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date


	DELETE	kcsd.kc_paystat
	WHERE	kc_expt_date = @wk_loop_date

	IF	@wk_expt_fee <> 0
		INSERT	kcsd.kc_paystat
			(kc_expt_date, kc_expt_fee, kc_norm_pay, kc_delay_pay,
			kc_no_pay, kc_updt_user, kc_updt_date)
		VALUES	(@wk_loop_date, @wk_expt_fee, @wk_norm_pay, @wk_delay_pay,
			@wk_expt_fee - @wk_norm_pay - @wk_delay_pay, USER, GETDATE())

	/* SELECT	@wk_loop_date, @wk_expt_fee, @wk_norm_pay, @wk_delay_pay,
			@wk_expt_fee - @wk_norm_pay - @wk_delay_pay */

	SELECT	@wk_loop_date = DATEADD(day, 1, @wk_loop_date)
END

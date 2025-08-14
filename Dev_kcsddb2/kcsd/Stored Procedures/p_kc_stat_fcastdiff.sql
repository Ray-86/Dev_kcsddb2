/*
05/29/2004 KC: 限制實收金額的應繳日在@wk_strt_date之前
*/
CREATE         PROCEDURE [kcsd].[p_kc_stat_fcastdiff]
@pm_lstrt_date datetime=NULL,
@pm_lstop_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_expt_fee1	int,
	@wk_expt_fee	int,
	@wk_prepay_sum	int,
	@wk_pay_sum	int,
	@wk_intr_sum	int,
	@wk_strt_date	datetime,
	@wk_stop_date	datetime,
	@wk_fcast_sum	int

CREATE TABLE	#tmp_fcastdiff
(kc_case_no	varchar(10),
kc_expt_fee	int,
kc_pay_sum	int,
kc_intr_sum	int
)

SELECT	@wk_case_no=NULL, @wk_fcast_sum = 0

/* 取得上月第一天/最後一天 */
IF	@pm_lstrt_date IS NULL
OR	@pm_lstop_date IS NULL
BEGIN
	SELECT	@pm_lstrt_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_lstop_date = DATEADD(day, -1, DATEADD(minute, 1, @pm_lstrt_date))
	SELECT	@pm_lstrt_date = DATEADD(month, -1, @pm_lstrt_date)
END

SELECT	@wk_strt_date = DATEADD(month, 1, @pm_lstrt_date),
	@wk_stop_date = DATEADD(day, -1, DATEADD(month, 1, @wk_strt_date))

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	DISTINCT kc_case_no
	FROM	kcsd.kc_loanpayment
	/*WHERE	kc_expt_date <= @pm_lstop_date*/
	WHERE	kc_expt_date < @wk_strt_date

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_expt_fee1 = 0, @wk_prepay_sum = 0,
		@wk_pay_sum = 0, @wk_intr_sum = 0

	SELECT	@wk_expt_fee1 = ISNULL(SUM(kc_expt_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_expt_date <= @pm_lstop_date
	AND	kc_perd_no < 50

	SELECT	@wk_prepay_sum = ISNULL(SUM(kc_pay_fee), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date <= @pm_lstop_date
	AND	kc_pay_fee IS NOT NULL
	AND	kc_pay_fee > 0

	SELECT	@wk_expt_fee = @wk_expt_fee1 - @wk_prepay_sum
	IF	@wk_expt_fee < 0
		SELECT	@wk_expt_fee = 0
	SELECT	@wk_fcast_sum = @wk_fcast_sum + @wk_expt_fee

	SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
		@wk_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date BETWEEN @wk_strt_date AND @wk_stop_date
	AND	kc_expt_date < @wk_strt_date

	/* 與催收比較 */
	IF	@wk_expt_fee > 0
	AND	NOT EXISTS
		(SELECT	'X'
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	(	(kc_strt_date <= @wk_stop_date AND kc_stop_date IS NULL)
			/*OR	(kc_strt_date <= @wk_stop_date AND kc_stop_date BETWEEN @wk_strt_date AND @wk_stop_date) )*/
		OR	(kc_strt_date <= @wk_stop_date AND kc_stop_date >= @wk_strt_date) )
		)
	BEGIN
		INSERT	#tmp_fcastdiff
			(kc_case_no, kc_expt_fee, kc_pay_sum, kc_intr_sum)
		VALUES	(@wk_case_no, @wk_expt_fee, @wk_pay_sum, @wk_intr_sum)
	END
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END


DEALLOCATE	cursor_case_no

/*SELECT	@wk_fcast_sum*/

SELECT	*
FROM	#tmp_fcastdiff
ORDER BY kc_case_no

/*
SELECT	SUM(kc_expt_fee), COUNT(kc_case_no)
FROM	#tmp_fcastdiff
*/

DROP TABLE #tmp_fcastdiff

CREATE   PROCEDURE [kcsd].[p_kc_overloan] @pm_stop_date datetime=NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_over_count	int,
	@wk_count	int,

	@wk_expt_sum	int,
	@wk_pay_sum	int,
	@wk_rema_amt	int

CREATE TABLE #tmp_overloan
(
kc_case_no	varchar(10),
kc_over_count	int,
kc_expt_sum	int,
kc_pay_sum	int,
kc_rema_amt	int
)

SELECT	@wk_case_no=NULL, @wk_count = 0, @wk_over_count = 0

IF	@pm_stop_date IS NULL
	SELECT	@pm_stop_date = GETDATE()

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	p.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
	WHERE	c.kc_case_no = p.kc_case_no
	AND	c.kc_buy_date < @pm_stop_date
	AND	p.kc_expt_date < @pm_stop_date
	AND	(	p.kc_pay_date IS NULL
		OR	p.kc_pay_date > @pm_stop_date )
	GROUP BY p.kc_case_no
	HAVING COUNT(p.kc_case_no) > 2

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	/* SELECT	@wk_case_no */
	SELECT	@wk_expt_sum = 0, @wk_pay_sum = 0, @wk_over_count = 0

	SELECT	@wk_over_count = COUNT(DISTINCT p.kc_expt_date)
	FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
	WHERE	c.kc_case_no = p.kc_case_no
	AND	c.kc_case_no = @wk_case_no
	AND	c.kc_buy_date < @pm_stop_date
	AND	p.kc_expt_date < @pm_stop_date
	AND	(	p.kc_pay_date IS NULL
		OR	p.kc_pay_date > @pm_stop_date )

	/* 只考慮大於2期(不含) */
	IF	@wk_over_count > 2
	BEGIN
		SELECT	@wk_expt_sum = SUM(kc_expt_fee)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_perd_no < 50

		SELECT	@wk_pay_sum = ISNULL(SUM(kc_pay_fee), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date < @pm_stop_date

		SELECT	@wk_rema_amt = @wk_expt_sum - @wk_pay_sum

		INSERT	#tmp_overloan
			(kc_case_no, kc_over_count, kc_expt_sum, kc_pay_sum, kc_rema_amt)
		VALUES	(@wk_case_no, @wk_over_count, @wk_expt_sum, @wk_pay_sum, @wk_rema_amt)

		SELECT	@wk_count = @wk_count + 1
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	v.*, c.kc_cust_name
FROM	#tmp_overloan v, kcsd.kc_customerloan c
WHERE	v.kc_case_no = c.kc_case_no
ORDER BY v.kc_case_no

/*
SELECT	c.kc_area_code, SUM(v.kc_rema_amt)
FROM	#tmp_overloan v, kcsd.kc_customerloan c
WHERE	v.kc_case_no = c.kc_case_no
GROUP BY c.kc_area_code
*/

DROP TABLE #tmp_overloan

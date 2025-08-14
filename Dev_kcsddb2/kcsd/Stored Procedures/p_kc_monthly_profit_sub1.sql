CREATE PROCEDURE [kcsd].[p_kc_monthly_profit_sub1]
	@pm_perd_year	INT=1999,
	@pm_perd_month	INT=1
AS

CREATE TABLE #tmp_perdpay (
	kc_perd_year smallint NOT NULL ,
	kc_perd_month tinyint NOT NULL ,
	kc_comp_char char (1) NOT NULL ,
	kc_pay_sum money NULL ,
	kc_pay_fee money NULL ,
	kc_break_fee money NULL ,
	kc_intr_fee money NULL
)


DECLARE	@wk_strt_date	datetime,
	@wk_stop_date	datetime,	
	@wk_comp_char	char(1),	/* company */

	/* money */
	@wk_pay_sum	money,
	@wk_pay_fee	money,
	@wk_break_fee	money,

	@wk_intr_fee	money

/* Init */
SELECT	@wk_strt_date = NULL, @wk_stop_date = NULL, @wk_comp_char = NULL,
	/* money */
	@wk_pay_sum = 0, @wk_pay_fee = 0, @wk_break_fee = 0, @wk_intr_fee = 0

SELECT	@wk_strt_date = CONVERT(char(2),@pm_perd_month) + '/1/' + CONVERT(char(4),@pm_perd_year)
SELECT	@wk_stop_date = DATEADD(MINUTE,-1,DATEADD(MONTH,1, @wk_strt_date))


INSERT	#tmp_perdpay
SELECT	@pm_perd_year, @pm_perd_month, c.kc_comp_char,
	SUM(ISNULL(p.kc_pay_fee,0))+SUM(ISNULL(p.kc_break_fee,0))-SUM(ISNULL(p.kc_intr_fee,0)),
	SUM(ISNULL(p.kc_pay_fee,0)), SUM(ISNULL(p.kc_break_fee,0)),SUM(ISNULL(p.kc_intr_fee,0))
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_pay_date BETWEEN @wk_strt_date AND @wk_stop_date
GROUP BY c.kc_comp_char


/* Update Data */
DECLARE	cur_comp_char	CURSOR
FOR	SELECT	kc_comp_char
	FROM	#tmp_perdpay


OPEN cur_comp_char
FETCH NEXT FROM cur_comp_char INTO @wk_comp_char

/* Main Loop */

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pay_sum = kc_pay_sum, @wk_pay_fee = kc_pay_fee,
		@wk_break_fee = kc_break_fee, @wk_intr_fee = kc_intr_fee
	FROM	#tmp_perdpay
	WHERE	kc_comp_char = @wk_comp_char

	IF	EXISTS(	SELECT	'X'
			FROM	kcsd.kc_balance
			WHERE	kc_perd_year = @pm_perd_year
			AND	kc_perd_month = @pm_perd_month
			AND	kc_comp_char = @wk_comp_char )
		UPDATE	kcsd.kc_balance
		SET	kc_pay_sum = @wk_pay_sum,
			kc_pay_fee = @wk_pay_fee,
			kc_break_fee = @wk_break_fee,
			kc_intr_fee = @wk_intr_fee
		WHERE	kc_perd_year = @pm_perd_year
		AND	kc_perd_month = @pm_perd_month
		AND	kc_comp_char = @wk_comp_char
	ELSE
		INSERT	kcsd.kc_balance
			(kc_perd_year, kc_perd_month, kc_comp_char,
			kc_pay_sum, kc_pay_fee, kc_break_fee, kc_intr_fee)
		VALUES	(@pm_perd_year, @pm_perd_month, @wk_comp_char,
			@wk_pay_sum, @wk_pay_fee, @wk_break_fee, @wk_intr_fee)
			
	FETCH NEXT FROM cur_comp_char INTO @wk_comp_char
END

/* Free */
DEALLOCATE	cur_comp_char

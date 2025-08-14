CREATE PROCEDURE [kcsd].[p_kc_monthly_profit_sub4]
	@pm_perd_year	INT=1999,
	@pm_perd_month	INT=1
AS

CREATE TABLE #tmp_perdinvest (
	kc_perd_year smallint NOT NULL,
	kc_perd_month tinyint NOT NULL,
	kc_comp_char char (1) NOT NULL,
	kc_perd_inve money NULL,

)


DECLARE	@wk_strt_date	datetime,
	@wk_stop_date	datetime,	
	@wk_comp_char	char(1),	/* company */
	/* money */
	@wk_perd_inve	money

/* Init */
SELECT	@wk_strt_date = NULL, @wk_stop_date = NULL,
	/* money */
	@wk_perd_inve = 0
	

SELECT	@wk_strt_date = CONVERT(char(2),@pm_perd_month) + '/1/' + CONVERT(char(4),@pm_perd_year)
SELECT	@wk_stop_date = DATEADD(MINUTE,-1,DATEADD(MONTH,1, @wk_strt_date))

/* Period */
INSERT	#tmp_perdinvest
SELECT	@pm_perd_year, @pm_perd_month, c.kc_comp_char,
	SUM(c.kc_loan_fee/c.kc_loan_perd)
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
GROUP BY c.kc_comp_char


/* Update Data */
DECLARE	cur_comp_char	CURSOR
FOR	SELECT	kc_comp_char
	FROM	#tmp_perdinvest


OPEN cur_comp_char
FETCH NEXT FROM cur_comp_char INTO @wk_comp_char

/* Main Loop */

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_perd_inve = kc_perd_inve
	FROM	#tmp_perdinvest

	WHERE	kc_comp_char = @wk_comp_char

	IF	EXISTS(	SELECT	'X'
			FROM	kcsd.kc_balance
			WHERE	kc_perd_year = @pm_perd_year
			AND	kc_perd_month = @pm_perd_month
			AND	kc_comp_char = @wk_comp_char )
		UPDATE	kcsd.kc_balance
		SET	kc_perd_inve = @wk_perd_inve
		WHERE	kc_perd_year = @pm_perd_year
		AND	kc_perd_month = @pm_perd_month
		AND	kc_comp_char = @wk_comp_char
	ELSE
		INSERT	kcsd.kc_balance
			(kc_perd_year, kc_perd_month, kc_comp_char,
			kc_perd_inve)
		VALUES	(@pm_perd_year, @pm_perd_month, @wk_comp_char,
			@wk_perd_inve)
			
	FETCH NEXT FROM cur_comp_char INTO @wk_comp_char
END

/* Free */
DEALLOCATE	cur_comp_char

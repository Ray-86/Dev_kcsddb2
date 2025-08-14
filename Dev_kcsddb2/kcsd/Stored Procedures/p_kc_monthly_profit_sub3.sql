CREATE PROCEDURE [kcsd].[p_kc_monthly_profit_sub3]
	@pm_perd_year	INT=1999,
	@pm_perd_month	INT=1
AS

CREATE TABLE #tmp_perdexpt (
	kc_perd_year smallint NOT NULL,
	kc_perd_month tinyint NOT NULL,
	kc_comp_char char (1) NOT NULL,
	kc_perd_expt money NOT NULL,
	kc_prev_expt money NOT NULL

)

CREATE TABLE #tmp_perdexpt_s1 (
	kc_perd_year smallint NOT NULL,
	kc_perd_month tinyint NOT NULL,
	kc_comp_char char (1) NOT NULL,
	kc_perd_expt money NOT NULL,
	kc_prev_expt money NOT NULL

)


DECLARE	@wk_strt_date	datetime,
	@wk_stop_date	datetime,	
	@wk_comp_char	char(1),	/* company */
	/* money */
	@wk_perd_expt	money,
	@wk_prev_expt	money

/* Init */
SELECT	@wk_strt_date = NULL, @wk_stop_date = NULL,
	/* money */
	@wk_perd_expt = 0, @wk_prev_expt = 0
	

SELECT	@wk_strt_date = CONVERT(char(2),@pm_perd_month) + '/1/' + CONVERT(char(4),@pm_perd_year)
SELECT	@wk_stop_date = DATEADD(MINUTE,-1,DATEADD(MONTH,1, @wk_strt_date))

/* Period */
INSERT	#tmp_perdexpt_s1
SELECT	@pm_perd_year, @pm_perd_month, c.kc_comp_char,
	SUM(p.kc_expt_fee),0
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
GROUP BY c.kc_comp_char

/* Previous */
INSERT	#tmp_perdexpt_s1
SELECT	@pm_perd_year, @pm_perd_month, c.kc_comp_char,
	0,SUM(p.kc_expt_fee)
FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p

WHERE	c.kc_case_no = p.kc_case_no
AND	p.kc_expt_date < @wk_strt_date
AND	(p.kc_pay_date = NULL 
	OR p.kc_pay_date >= @wk_strt_date)
GROUP BY c.kc_comp_char

INSERT	#tmp_perdexpt
SELECT	a.kc_perd_year, a.kc_perd_month, a.kc_comp_char,
	SUM(ISNULL(a.kc_perd_expt,0)), SUM(ISNULL(a.kc_prev_expt,0))
FROM	#tmp_perdexpt_s1 a
GROUP BY a.kc_perd_year, a.kc_perd_month, a.kc_comp_char

/* Update Data */
DECLARE	cur_comp_char	CURSOR
FOR	SELECT	kc_comp_char
	FROM	#tmp_perdexpt


OPEN cur_comp_char
FETCH NEXT FROM cur_comp_char INTO @wk_comp_char

/* Main Loop */

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_perd_expt = kc_perd_expt, @wk_prev_expt = kc_prev_expt
	FROM	#tmp_perdexpt

	WHERE	kc_comp_char = @wk_comp_char

	IF	EXISTS(	SELECT	'X'
			FROM	kcsd.kc_balance
			WHERE	kc_perd_year = @pm_perd_year
			AND	kc_perd_month = @pm_perd_month
			AND	kc_comp_char = @wk_comp_char )
		UPDATE	kcsd.kc_balance
		SET	kc_perd_expt = @wk_perd_expt,
			kc_prev_expt = @wk_prev_expt
		WHERE	kc_perd_year = @pm_perd_year
		AND	kc_perd_month = @pm_perd_month
		AND	kc_comp_char = @wk_comp_char
	ELSE
		INSERT	kcsd.kc_balance
			(kc_perd_year, kc_perd_month, kc_comp_char,
			kc_perd_expt, kc_prev_expt)
		VALUES	(@pm_perd_year, @pm_perd_month, @wk_comp_char,
			@wk_perd_expt, @wk_prev_expt)
			
	FETCH NEXT FROM cur_comp_char INTO @wk_comp_char
END

/* Free */
DEALLOCATE	cur_comp_char

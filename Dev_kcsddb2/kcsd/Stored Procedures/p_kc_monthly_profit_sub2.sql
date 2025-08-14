CREATE PROCEDURE [kcsd].[p_kc_monthly_profit_sub2]
	@pm_perd_year	INT=1999,
	@pm_perd_month	INT=1
AS


CREATE TABLE #tmp_perdloan (
	kc_perd_year smallint NOT NULL,
	kc_perd_month tinyint NOT NULL,
	kc_comp_char char (1) NOT NULL,
	kc_loan_fee money NOT NULL,

	kc_loan_ret money NOT NULL
)


DECLARE	@wk_strt_date	datetime,
	@wk_stop_date	datetime,
	
	@wk_comp_char	char(1),	/* company */

	/* money */
	@wk_loan_fee	money,
	@wk_loan_ret	money


/* Init */
SELECT	@wk_strt_date = NULL, @wk_stop_date = NULL, @wk_comp_char = NULL,
	/* money */
	@wk_loan_fee = 0, @wk_loan_ret = 0

SELECT	@wk_strt_date = CONVERT(char(2),@pm_perd_month) + '/1/' + CONVERT(char(4),@pm_perd_year)
SELECT	@wk_stop_date = DATEADD(MINUTE,-1,DATEADD(MONTH,1, @wk_strt_date))

INSERT	#tmp_perdloan
SELECT	@pm_perd_year, @pm_perd_month, c.kc_comp_char, SUM(kc_loan_fee),
	SUM(kc_perd_fee*kc_loan_perd)
FROM	kcsd.kc_customerloan c
WHERE	c.kc_buy_date BETWEEN @wk_strt_date AND @wk_stop_date
GROUP BY c.kc_comp_char


/* Update Data */
DECLARE	cur_comp_char	CURSOR
FOR	SELECT	kc_comp_char
	FROM	#tmp_perdloan


OPEN cur_comp_char
FETCH NEXT FROM cur_comp_char INTO @wk_comp_char

/* Main Loop */

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_loan_fee = kc_loan_fee, @wk_loan_ret = kc_loan_ret
	FROM	#tmp_perdloan
	WHERE	kc_comp_char = @wk_comp_char

	IF	EXISTS(	SELECT	'X'
			FROM	kcsd.kc_balance
			WHERE	kc_perd_year = @pm_perd_year
			AND	kc_perd_month = @pm_perd_month
			AND	kc_comp_char = @wk_comp_char )
		UPDATE	kcsd.kc_balance
		SET	kc_loan_fee = @wk_loan_fee,
			kc_loan_ret = @wk_loan_ret
		WHERE	kc_perd_year = @pm_perd_year
		AND	kc_perd_month = @pm_perd_month
		AND	kc_comp_char = @wk_comp_char
	ELSE
		INSERT	kcsd.kc_balance
			(kc_perd_year, kc_perd_month, kc_comp_char,
			kc_loan_fee, kc_loan_ret)
		VALUES	(@pm_perd_year, @pm_perd_month, @wk_comp_char,
			@wk_loan_fee, @wk_loan_ret)
			
	FETCH NEXT FROM cur_comp_char INTO @wk_comp_char
END

/* Free */
DEALLOCATE	cur_comp_char

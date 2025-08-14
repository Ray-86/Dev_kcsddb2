CREATE PROCEDURE [kcsd].[p_kc_monthly_profit_loop]
	@pm_perd_year int=1999,
	@pm_perd_month int=1,
	@pm_strt_year int=1998,
	@pm_strt_month int=5
AS

DECLARE	@wk_perd_year	smallint,
	@wk_perd_month	tinyint

SELECT	@wk_perd_year = 0, @wk_perd_month = 0


DECLARE	cur_perd_yearmonth	CURSOR
FOR	SELECT	kc_perd_year, kc_perd_month
	FROM	kcsd.kc_period
	WHERE	(kc_perd_year < @pm_perd_year
		OR	(kc_perd_year = @pm_perd_year
			AND kc_perd_month <= @pm_perd_month)
		)
	AND	(kc_perd_year > @pm_strt_year
		OR	(kc_perd_year = @pm_strt_year
			AND kc_perd_month >= @pm_strt_month)
		)


OPEN cur_perd_yearmonth
FETCH NEXT FROM cur_perd_yearmonth INTO @wk_perd_year, @wk_perd_month

WHILE (@@FETCH_STATUS = 0)
BEGIN	
	SELECT @wk_perd_year, @wk_perd_month

	EXECUTE	p_kc_monthly_profit @wk_perd_year, @wk_perd_month	


	FETCH NEXT FROM cur_perd_yearmonth INTO @wk_perd_year, @wk_perd_month
END

DEALLOCATE	cur_perd_yearmonth

CREATE PROCEDURE [kcsd].[p_kc_monthly_profit]
	@pm_perd_year	INT=1999,
	@pm_perd_month	INT=1
AS

EXECUTE	kcsd.p_kc_monthly_profit_sub1 @pm_perd_year, @pm_perd_month
EXECUTE	kcsd.p_kc_monthly_profit_sub2 @pm_perd_year, @pm_perd_month
EXECUTE	kcsd.p_kc_monthly_profit_sub3 @pm_perd_year, @pm_perd_month
EXECUTE	kcsd.p_kc_monthly_profit_sub4 @pm_perd_year, @pm_perd_month


SELECT	*
FROM	kcsd.kc_balance

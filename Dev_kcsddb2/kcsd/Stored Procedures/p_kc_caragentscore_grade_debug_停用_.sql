CREATE PROCEDURE [kcsd].[p_kc_caragentscore_grade_debug(停用)] @pm_agent_code varchar(30), @pm_strt_date datetime, @pm_stop_date datetime
AS
DECLARE	@wk_sale_grade varchar(10)

EXECUTE p_kc_stat_caragentscore_grade_sub @pm_agent_code, @pm_strt_date, @pm_stop_date, @wk_sale_grade OUTPUT

SELECT	@wk_sale_grade

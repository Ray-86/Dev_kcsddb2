CREATE PROCEDURE [kcsd].[p_kc_monthly_goal_cron] AS

DECLARE @wk_curr_year	int,
	@wk_curr_month	int,
	@wk_curr_day	int,
	@wk_prev_year	int,
	@wk_prev_month	int,
	@wk_prev_mday	datetime

/* ¡p║ÔñWñÙ¬║ñÁñÐ */
SELECT	@wk_prev_mday = DATEADD(month, -1,GETDATE())
SELECT	@wk_prev_year = DATEPART(year, @wk_prev_mday),
	@wk_prev_month = DATEPART(month, @wk_prev_mday)

SELECT	@wk_curr_year = DATEPART(year, GETDATE()), @wk_curr_month = DATEPART(month, GETDATE()),
	@wk_curr_day = DATEPART(day, GETDATE())


/* ¡p║ÔÑ╗ñÙ╣Fª¿▓v */
EXECUTE	kcsd.p_kc_monthly_goal @wk_curr_year, @wk_curr_month

/* ¡Yñp®¾15ñÚ, ½hªA¡p║ÔñWñÙ╣Fª¿▓v */
IF	@wk_curr_day <= 15
	EXECUTE	kcsd.p_kc_monthly_goal @wk_prev_year, @wk_prev_month

/*
-- ==========================================================================================
03/22/08 車行分級
-- ==========================================================================================*/
CREATE     PROCEDURE [kcsd].[p_kc_stat_caragentscore_grade]
	@pm_run_code varchar(10)='TEST',
	@pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL
AS
DECLARE	@wk_agent_code	varchar(20),
	@wk_perd_code	varchar(20),
	@wk_sale_qty	int,
	@wk_sale_grade	varchar(10)

-- 預設為上個月第一天~最後一天
IF	@pm_strt_date IS NULL
OR	@pm_stop_date IS NULL
BEGIN
	SELECT	@pm_strt_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_stop_date = DATEADD(day, -1, @pm_strt_date)
	
	SELECT	@pm_strt_date = DATEADD(month, -1, @pm_strt_date)
END

SELECT	@wk_perd_code = CONVERT(char(4), @pm_strt_date, 12)	-- YYMM

/*
CREATE TABLE #tmp_caragentscore_grade
(kc_perd_code	varchar(20),
kc_agent_code	varchar(30),
kc_sale_qty	int,
kc_sale_grade	varchar(10) null
)
*/


/*
DECLARE	cursor_agent_code CURSOR
FOR	SELECT DISTINCT kc_comp_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	kc_loan_stat <> 'X'
	ORDER BY kc_comp_code */

DECLARE	cursor_agent_code CURSOR
FOR	SELECT DISTINCT kc_agent_code
	FROM	kcsd.kc_caragent
	ORDER BY kc_agent_code

OPEN cursor_agent_code
FETCH NEXT FROM cursor_agent_code INTO @wk_agent_code

WHILE (@@FETCH_STATUS = 0)
BEGIN

	EXECUTE	kcsd.p_kc_stat_caragentscore_grade_sub
		@wk_agent_code, @pm_strt_date, @pm_stop_date,
		@wk_sale_grade OUTPUT, @wk_sale_qty OUTPUT

	IF	EXISTS	(SELECT	kc_perd_code
			FROM	kcsd.kc_caragentscore
			WHERE	kc_perd_code = @wk_perd_code
			AND	kc_agent_code = @wk_agent_code)
		UPDATE	kcsd.kc_caragentscore
		SET	kc_sale_grade = @wk_sale_grade, kc_sale_qty = @wk_sale_qty
		WHERE	kc_perd_code = @wk_perd_code
		AND	kc_agent_code = @wk_agent_code
	ELSE
		INSERT	kcsd.kc_caragentscore
			(kc_perd_code, kc_agent_code, kc_sale_qty, kc_sale_grade)
		VALUES	(@wk_perd_code, @wk_agent_code, @wk_sale_qty, @wk_sale_grade)

	-- check if update to MASTER kc_caragent
	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		UPDATE	kcsd.kc_caragent
		SET	kc_sale_grade = @wk_sale_grade, kc_sale_qty = @wk_sale_qty
		WHERE	kc_agent_code = @wk_agent_code
	END
/*
	SELECT	@wk_sale_qty = 0

	SELECT	@wk_sale_qty = count(kc_case_no)
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	kc_loan_stat <> 'X'
	AND	kc_comp_code = @wk_agent_code

	INSERT	#tmp_caragentscore
		(kc_perd_code, kc_agent_code, kc_sale_qty)
	VALUES	(@wk_perd_code, @wk_agent_code, @wk_sale_qty)
*/

	FETCH NEXT FROM cursor_agent_code INTO @wk_agent_code
END

DEALLOCATE	cursor_agent_code

/*
SELECT	*
FROM	#tmp_caragentscore

DELETE	
FROM	kcsd.kc_caragentscore
WHERE	kc_perd_code = @wk_perd_code

INSERT	kcsd.kc_caragentscore
SELECT	*
FROM	#tmp_caragentscore

DROP TABLE #tmp_caragentscore
*/

/*
-- ==========================================================================================
03/22/08 實際計算單一車行分級
E: 台數 0
D: 曾經台數>0, 但3個月內台數0

A: 每月5台(含)以上
B: 每月1台(含)以上
C: 3個月台數總和1以上(含)

-- ==========================================================================================*/
CREATE     PROCEDURE [kcsd].[p_kc_stat_caragentscore_grade_sub]
	@pm_agent_code varchar(30), @pm_strt_date DATETIME, @pm_stop_date DATETIME,
	@pm_sale_grade varchar(10) OUTPUT, @pm_sale_qty int OUTPUT
AS
DECLARE	@wk_sale_sum	int,
	@wk_pstrt_code	varchar(20),
	@wk_pstop_code	varchar(20),
	
	@wk_sale_qty1	int,
	@wk_sale_qty2	int,
	@wk_sale_qty3	int,

	@wk_pstrt_date	datetime,
	@wk_pstop_date	datetime

-- Init @pm_sale_qty 回傳 0
SELECT	@wk_sale_sum = 0, @pm_sale_qty = 0

SELECT	@wk_sale_sum = ISNULL( SUM(kc_sale_qty), 0)
FROM	kcsd.kc_caragentscore
WHERE	kc_agent_code = @pm_agent_code

-- ==========================================================================================*/
-- E: 台數 0
IF	@wk_sale_sum = 0
BEGIN
	SELECT	@pm_sale_grade = 'E'
	RETURN
END

-- ==========================================================================================*/
-- D: 曾經台數>0, 但3個月內台數0
SELECT	@wk_sale_sum = 0

SELECT	@wk_pstrt_code = CONVERT(varchar(4), DATEADD(month, -2, @pm_strt_date), 12),
	@wk_pstop_code = CONVERT(varchar(4), @pm_stop_date, 12)

SELECT	@wk_sale_sum = ISNULL( SUM(kc_sale_qty), 0)
FROM	kcsd.kc_caragentscore
WHERE	kc_agent_code = @pm_agent_code
AND	kc_perd_code BETWEEN @wk_pstrt_code AND @wk_pstop_code

IF	@wk_sale_sum = 0
BEGIN
	SELECT	@pm_sale_grade = 'D'
	RETURN
END

-- ==========================================================================================*/
-- 先判斷  是否 A: 每月5台(含)以上
-- 否則判斷是否 B: 每月1台(含)以上
-- 否則一定是   C: 3個月台數總和1以上(含)

-- month 1
SELECT	@wk_pstrt_date = @pm_strt_date,
	@wk_pstop_date = @pm_stop_date

SELECT	@wk_pstrt_code = CONVERT(varchar(4), @wk_pstrt_date, 12),
	@wk_pstop_code = CONVERT(varchar(4), @wk_pstop_date, 12)

SELECT	@wk_sale_qty1 = ISNULL( SUM(kc_sale_qty), 0)
FROM	kcsd.kc_caragentscore
WHERE	kc_agent_code = @pm_agent_code
AND	kc_perd_code BETWEEN @wk_pstrt_code AND @wk_pstop_code
	
SELECT	@pm_sale_qty = @wk_sale_qty1	-- 最近的台數

-- SELECT	@wk_pstrt_date, @wk_pstop_date, @wk_pstrt_code, @wk_pstop_code

-- month 2
SELECT	@wk_pstrt_date = DATEADD(month, -1, @pm_strt_date)
SELECT	@wk_pstop_date = DATEADD(  day, -1, DATEADD(month,  1, @wk_pstrt_date))

SELECT	@wk_pstrt_code = CONVERT(varchar(4), @wk_pstrt_date, 12),
	@wk_pstop_code = CONVERT(varchar(4), @wk_pstop_date, 12)

SELECT	@wk_sale_qty2 = ISNULL( SUM(kc_sale_qty), 0)
FROM	kcsd.kc_caragentscore
WHERE	kc_agent_code = @pm_agent_code
AND	kc_perd_code BETWEEN @wk_pstrt_code AND @wk_pstop_code

-- SELECT	@wk_pstrt_date, @wk_pstop_date, @wk_pstrt_code, @wk_pstop_code

-- month 2
SELECT	@wk_pstrt_date = DATEADD(month, -2, @pm_strt_date)
SELECT	@wk_pstop_date = DATEADD(  day, -1, DATEADD(month,  1, @wk_pstrt_date))

SELECT	@wk_pstrt_code = CONVERT(varchar(4), @wk_pstrt_date, 12),
	@wk_pstop_code = CONVERT(varchar(4), @wk_pstop_date, 12)

SELECT	@wk_sale_qty3 = ISNULL( SUM(kc_sale_qty), 0)
FROM	kcsd.kc_caragentscore
WHERE	kc_agent_code = @pm_agent_code
AND	kc_perd_code BETWEEN @wk_pstrt_code AND @wk_pstop_code

-- SELECT	@wk_pstrt_date, @wk_pstop_date, @wk_pstrt_code, @wk_pstop_code

-- 開始計算 A, B, C
-- SELECT	@wk_sale_qty1, @wk_sale_qty2, @wk_sale_qty3

IF	@wk_sale_qty1 >= 5
AND	@wk_sale_qty2 >= 5
AND	@wk_sale_qty3 >= 5
BEGIN
	SELECT	@pm_sale_grade = 'A'
	RETURN
END
ELSE
IF	@wk_sale_qty1 >= 1
AND	@wk_sale_qty2 >= 1
AND	@wk_sale_qty3 >= 1
BEGIN
	SELECT	@pm_sale_grade = 'B'
	RETURN
END
ELSE
	SELECT	@pm_sale_grade = 'C'

/*
-- ==========================================================================================
04/21/08 防止無業績的月份
04/19/08 計算車行業績差異
-- ==========================================================================================*/
CREATE     PROCEDURE [kcsd].[p_kc_stat_caragentscore_gradedown] @pm_strt_date datetime=NULL
AS
DECLARE	@wk_agent_code	varchar(20),
	@wk_perd_code	varchar(20),	-- 本期
	@wk_sale_qty	int,
	@wk_sale_grade	varchar(10),

	@wk_perd_code2	varchar(20),	-- 前期
	@wk_sale_qty2	int,
	@wk_sale_grade2	varchar(10),

	@wk_perd_code3	varchar(20),	-- 去年同期
	@wk_sale_qty3	int,
	@wk_sale_grade3	varchar(10),

	@wk_count	INT,
	@wk_strt_date DATETIME,
	@wk_end_date datetime
	
CREATE TABLE #tmp_agentdown
(kc_perd_code	varchar(20),
kc_agent_code	varchar(30),
kc_sale_qty	int,		-- 本期
kc_sale_grade	varchar(10),	-- 本期
kc_sale_qty2	int,		-- 上期
kc_sale_grade2	varchar(10),	-- 上期
kc_sale_qty3	int,		-- 去年同期
kc_sale_grade3	varchar(10)	-- 去年同期
)

-- 預設為上個月第一天
IF	@pm_strt_date IS NULL
BEGIN
	SELECT	@pm_strt_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))	
	SELECT	@pm_strt_date = DATEADD(month, -1, @pm_strt_date)
END

SELECT	@wk_perd_code  = CONVERT(char(4), @pm_strt_date, 12),					-- YYMM
	@wk_perd_code2 = CONVERT(char(4), DATEADD(month,-1, @pm_strt_date), 12),	-- YYMM (上期)
	@wk_perd_code3 = CONVERT(char(4), DATEADD(year, -1, @pm_strt_date), 12)		-- YYMM (去年)

--產生車行資料
--SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(mm,0,@pm_strt_date), 0)
--SELECT @wk_end_date = DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,@pm_strt_date)+1, 0))
--EXECUTE kcsd.p_kc_stat_caragentscore @wk_strt_date,@wk_end_date

--SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(mm,0,DATEADD(month,-1, @pm_strt_date)), 0)
--SELECT @wk_end_date = DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(month,-1, @pm_strt_date))+1, 0))
--EXECUTE kcsd.p_kc_stat_caragentscore @wk_strt_date,@wk_end_date

--SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(mm,0,DATEADD(year,-1, @pm_strt_date)), 0)
--SELECT @wk_end_date = DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(year,-1, @pm_strt_date))+1, 0))
--EXECUTE kcsd.p_kc_stat_caragentscore @wk_strt_date,@wk_end_date

-- 不能執行無業績資料的月份, 避免車行資料外流
--SELECT	@wk_count = 0
--SELECT	@wk_count = COUNT(kc_agent_code)
--FROM	kcsd.kc_caragentscore
--WHERE	kc_perd_code = @wk_perd_code

--IF	@wk_count < 100		-- 小於100家,視為無業績, 傳回空白table
--BEGIN
--	SELECT	*
--	FROM	#tmp_agentdown
--	RETURN
--END

DECLARE	cursor_agent_down CURSOR
FOR	SELECT DISTINCT kc_agent_code
	FROM	kcsd.kc_caragent
	ORDER BY kc_agent_code

OPEN cursor_agent_down
FETCH NEXT FROM cursor_agent_down INTO @wk_agent_code

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_sale_qty = 0, @wk_sale_qty2 = 0, @wk_sale_qty3 = 0

	SELECT	@wk_sale_qty = kc_sale_qty, @wk_sale_grade = kc_sale_grade
	FROM	kcsd.kc_caragentscore
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_perd_code = @wk_perd_code

	SELECT	@wk_sale_qty2 = ISNULL(kc_sale_qty, 0), @wk_sale_grade2 = kc_sale_grade
	FROM	kcsd.kc_caragentscore
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_perd_code = @wk_perd_code2

	SELECT	@wk_sale_qty3 = ISNULL(kc_sale_qty, 0), @wk_sale_grade3 = kc_sale_grade
	FROM	kcsd.kc_caragentscore
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_perd_code = @wk_perd_code3

	IF	@wk_sale_qty - @wk_sale_qty2 <= -3
	BEGIN
		INSERT	#tmp_agentdown
			(kc_perd_code, kc_agent_code,
			kc_sale_qty, kc_sale_grade,
			kc_sale_qty2, kc_sale_grade2,
			kc_sale_qty3, kc_sale_grade3
			)
		VALUES	(@wk_perd_code, @wk_agent_code,
			@wk_sale_qty, @wk_sale_grade,
			@wk_sale_qty2, @wk_sale_grade2,
			@wk_sale_qty3, @wk_sale_grade3)
	END

	FETCH NEXT FROM cursor_agent_down INTO @wk_agent_code
END

DEALLOCATE	cursor_agent_down

--SELECT	@wk_perd_code2, @wk_perd_code3

SELECT	*
FROM	#tmp_agentdown

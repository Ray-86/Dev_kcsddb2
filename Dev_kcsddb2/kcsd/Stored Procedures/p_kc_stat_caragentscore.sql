/*
-- ==========================================================================================
-- 計算每月車行台數, 以供等級用
-- ==========================================================================================*/
CREATE  PROCEDURE [kcsd].[p_kc_stat_caragentscore]
	@pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL
AS
DECLARE	
--	@wk_case_no	varchar(10),
--	@wk_case_type	varchar(4),

--	@wk_buy_date	datetime,
--	@wk_buy_date2	datetime,	/* 本月之前的最後購買日 */
--	@wk_cut_date6	datetime	/* 6個月前 */
	@wk_agent_code	varchar(20),
	@wk_perd_code	varchar(20),
	@wk_sale_qty	int

-- 預設為本個月第一天到最後一天
IF	@pm_strt_date IS NULL
OR	@pm_stop_date IS NULL
BEGIN
	--SELECT	@pm_strt_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
	--	+ CONVERT(char(4), DATEPART(year, GETDATE()))
	--SELECT	@pm_stop_date = DATEADD(day, -1, @pm_strt_date)
	
	--SELECT	@pm_strt_date = DATEADD(month, -1, @pm_strt_date)
	
	SELECT	@pm_strt_date = DATEADD(mm, DATEDIFF(mm,0,GETDATE()), 0)
	SELECT	@pm_stop_date = DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1, 0))
	
END

--SELECT	@wk_case_no=NULL, @wk_comp_code=NULL, @wk_buy_date=NULL

SELECT	@wk_perd_code = CONVERT(char(4), @pm_strt_date, 12)	-- YYMM

CREATE TABLE #tmp_caragentscore
(kc_perd_code	varchar(20),
kc_agent_code	varchar(30),
kc_sale_qty	int,
kc_sale_grade	varchar(10) null
)

--SELECT	@wk_cut_date6 = DATEADD(month, -6, @pm_strt_date)

INSERT	#tmp_caragentscore
SELECT	@wk_perd_code, kc_comp_code, count(kc_case_no), NULL
FROM	kcsd.kc_customerloan
WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
AND	kc_loan_stat <> 'X'
GROUP BY kc_comp_code

/*
DECLARE	cursor_comp_code_caragentscore CURSOR
FOR	SELECT DISTINCT kc_comp_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	kc_loan_stat <> 'X'
	ORDER BY kc_comp_code

OPEN cursor_comp_code_caragentscore
FETCH NEXT FROM cursor_comp_code_caragentscore INTO @wk_agent_code

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_sale_qty = 0

	SELECT	@wk_sale_qty = count(kc_case_no)
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	kc_loan_stat <> 'X'
	AND	kc_comp_code = @wk_agent_code

	INSERT	#tmp_caragentscore
		(kc_perd_code, kc_agent_code, kc_sale_qty)
	VALUES	(@wk_perd_code, @wk_agent_code, @wk_sale_qty)

	FETCH NEXT FROM cursor_comp_code_caragentscore INTO @wk_agent_code
END

DEALLOCATE	cursor_comp_code_caragentscore
*/

--SELECT	*
--FROM	#tmp_caragentscore

DELETE	
FROM	kcsd.kc_caragentscore
WHERE	kc_perd_code = @wk_perd_code

INSERT	kcsd.kc_caragentscore
	(kc_perd_code, kc_agent_code, kc_sale_qty, kc_sale_grade)
SELECT	*
FROM	#tmp_caragentscore

--計算等級
EXECUTE kcsd.p_kc_stat_caragentscore_grade 'EXECUTE',@pm_strt_date , @pm_stop_date

DROP TABLE #tmp_caragentscore

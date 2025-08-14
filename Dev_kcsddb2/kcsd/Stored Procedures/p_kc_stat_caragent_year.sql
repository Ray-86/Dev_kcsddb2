-- ==========================================================================================
-- 20170218 改寫直接查詢年度資料統計
-- 2011-07-09 改為	A類: 無成交記錄 (不變)
-- 			B類: 有成交紀錄, 且前次成交, 在6~12月內
-- 			C類: 有成交紀錄, 且前次成交, 在12個月前
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_stat_caragent_year] --@pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL
AS
DECLARE	@wk_strt_date	datetime,
		@wk_stop_date	datetime

CREATE TABLE #tmp_carlevel
(
y				varchar(4),
m				varchar(2),
kc_buy_date		varchar(6),
kc_area_code	varchar(2),
kc_level_type	varchar(1),
kc_level_cnt	int
)


DECLARE	cursor_comp_code CURSOR
FOR	
SELECT DISTINCT convert(datetime, convert(varchar(6),kc_buy_date,112)+'01', 112),dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,convert(datetime, convert(varchar(6),kc_buy_date,112)+'01', 112))+1, 0))
FROM	kcsd.kc_customerloan
--WHERE	kc_buy_date between @pm_strt_date and @pm_stop_date
GROUP BY kc_buy_date

OPEN cursor_comp_code
FETCH NEXT FROM cursor_comp_code INTO @wk_strt_date,@wk_stop_date


WHILE (@@FETCH_STATUS = 0)
BEGIN
	INSERT	#tmp_carlevel
	SELECT 
	Substring(convert(varchar(6),kc_buy_date,112),1,4) as y,Substring(convert(varchar(6),kc_buy_date,112),5,2) as m,
	convert(varchar(6),s.kc_buy_date,112) as kc_buy_date ,s.kc_area_code,kc_level_type,count(*) as kc_level_cnt FROM 
	(
	SELECT c.kc_area_code,c.kc_sales_code, Max(c.kc_case_no) AS kc_case_no, c.kc_comp_code, Max(c.kc_buy_date) AS kc_buy_date,
	CASE WHEN s.kc_buy_date is null THEN 'A' ELSE (CASE WHEN s.kc_buy_date Between DateAdd(mm,-12,@wk_strt_date) And DateAdd(mm,-6,@wk_strt_date) THEN 'B' ELSE (CASE WHEN s.kc_buy_date < DateAdd(mm,-12,@wk_strt_date)  THEN 'C' ELSE null END) END) END AS kc_level_type

	FROM kcsd.kc_customerloan c LEFT JOIN (SELECT kc_comp_code, MAX(kc_buy_date) as kc_buy_date FROM kcsd.kc_customerloan c1 WHERE kc_buy_date < @wk_strt_date GROUP BY kc_comp_code) s ON s.kc_comp_code = c.kc_comp_code
	WHERE 
	c.kc_loan_stat not in ('Y','Z') AND c.kc_buy_date Between @wk_strt_date And @wk_stop_date
	GROUP BY c.kc_area_code,c.kc_sales_code,c.kc_comp_code,s.kc_buy_date
	) AS s
	WHERE s.kc_level_type is not null
	GROUP by s.kc_area_code,convert(varchar(6),s.kc_buy_date,112),s.kc_level_type
	ORDER by s.kc_area_code,convert(varchar(6),s.kc_buy_date,112),s.kc_level_type

	FETCH NEXT FROM cursor_comp_code INTO @wk_strt_date,@wk_stop_date
END

DEALLOCATE	cursor_comp_code

SELECT	*
FROM	#tmp_carlevel

DROP TABLE #tmp_carlevel

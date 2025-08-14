-- =============================================
-- 2021-07-12 新增單獨的分公司篩選
-- 2018-10-24 加產品別(商品)
-- 2018-09-26 排除勞務件
-- 2018-02-09 加產品別
-- 2014-04-30 不計算案件狀態為 (Y，Z)
-- 2012-12-21 改為4年同期比較
-- =============================================
CREATE     PROCEDURE [kcsd].[p_kc_regionstat] @pm_strt_date datetime, @pm_stop_date DATETIME,@pm_area_code varchar(100)=NULL,@wk_area_code varchar(2) =NULL
AS

--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @wk_area_code = ''
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
end
else
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ' and kc_area_code = '+ @wk_area_code +')'
end
EXEC sp_executesql @SQL

SELECT s2.kc_area_code,s2.kc_regn_code,s2.kc_regn_cate,s2.kc_regn_name,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_A ELSE 0 END) AS y1_A,	--今年
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_B ELSE 0 END) AS y1_B,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_C ELSE 0 END) AS y1_C,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_D ELSE 0 END) AS y1_D,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_E ELSE 0 END) AS y1_E,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_F ELSE 0 END) AS y1_F,
sum(CASE WHEN s2.buyyear  = year(@pm_strt_date) THEN s2.sum_G ELSE 0 END) AS y1_G,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_A ELSE 0 END) AS y2_A, --去年
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_B ELSE 0 END) AS y2_B,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_C ELSE 0 END) AS y2_C,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_D ELSE 0 END) AS y2_D,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_E ELSE 0 END) AS y2_E,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_F ELSE 0 END) AS y2_F,
sum(CASE WHEN s2.buyyear  = year(DATEADD(yy,-1,@pm_strt_date)) THEN s2.sum_G ELSE 0 END) AS y2_G
FROM 
(
SELECT
s1.buyyear,s1.kc_area_code,s1.kc_regn_code,s1.kc_regn_cate,s1.kc_regn_name,
sum(CASE WHEN s1.kc_new_flag  ='N' and s1.kc_prod_type  ='01' THEN 1 ELSE 0 END) AS sum_A,
sum(CASE WHEN s1.kc_new_flag  ='O' and s1.kc_prod_type  ='01' THEN 1 ELSE 0 END) AS sum_B,
COUNT(DISTINCT(s1.kc_agent_code)) AS sum_C,
sum(CASE WHEN s1.kc_prod_type  ='06' THEN 1 ELSE 0 END) AS sum_D,
sum(CASE WHEN s1.kc_prod_type  ='04' THEN 1 ELSE 0 END) AS sum_E,
sum(CASE WHEN s1.kc_prod_type  ='07' THEN 1 ELSE 0 END) AS sum_F,
sum(CASE WHEN s1.kc_prod_type  ='10' THEN 1 ELSE 0 END) AS sum_G
FROM (select SUBSTRING(CONVERT(varchar(4),year(c.kc_buy_date)),1,4) AS buyyear,c.kc_area_code,c.kc_new_flag,a.kc_regn_code,a.kc_agent_code,r.kc_regn_cate,r.kc_regn_name,c.kc_prod_type FROM kcsd.kc_customerloan c, kcsd.kc_caragent a,kcsd.kct_region r 
WHERE c.kc_area_code IN ( SELECT kc_user_area from #tmp_userperm ) and c.kc_comp_code = a.kc_agent_code and a.kc_regn_code = r.kc_regn_code and c.kc_prod_type <> '08' and c.kc_loan_stat not in ('Y','Z') and c.kc_buy_date BETWEEN DATEADD(yy,-1,@pm_strt_date)  AND DATEADD(yy,-1,@pm_stop_date))  AS s1
GROUP BY s1.buyyear,s1.kc_area_code,s1.kc_regn_code,s1.kc_regn_cate,s1.kc_regn_name
UNION ALL
SELECT
s1.buyyear,s1.kc_area_code,s1.kc_regn_code,s1.kc_regn_cate,s1.kc_regn_name,
sum(CASE WHEN s1.kc_new_flag  ='N' and s1.kc_prod_type  ='01' THEN 1 ELSE 0 END) AS sum_A,
sum(CASE WHEN s1.kc_new_flag  ='O' and s1.kc_prod_type  ='01' THEN 1 ELSE 0 END) AS sum_B,
COUNT(DISTINCT(s1.kc_agent_code)) AS sum_C,
sum(CASE WHEN s1.kc_prod_type  ='06' THEN 1 ELSE 0 END) AS sum_D,
sum(CASE WHEN s1.kc_prod_type  ='04' THEN 1 ELSE 0 END) AS sum_E,
sum(CASE WHEN s1.kc_prod_type  ='07' THEN 1 ELSE 0 END) AS sum_F,
sum(CASE WHEN s1.kc_prod_type  ='10' THEN 1 ELSE 0 END) AS sum_G
FROM (select SUBSTRING(CONVERT(varchar(4),year(c.kc_buy_date)),1,4) AS buyyear,c.kc_area_code,c.kc_new_flag,a.kc_regn_code,a.kc_agent_code,r.kc_regn_cate,r.kc_regn_name,c.kc_prod_type FROM kcsd.kc_customerloan c, kcsd.kc_caragent a,kcsd.kct_region r 
WHERE c.kc_area_code IN ( SELECT kc_user_area from #tmp_userperm ) and c.kc_comp_code = a.kc_agent_code and a.kc_regn_code = r.kc_regn_code and c.kc_prod_type <> '08' and c.kc_loan_stat not in ('Y','Z') and c.kc_buy_date BETWEEN @pm_strt_date  AND @pm_stop_date)  AS s1
GROUP BY s1.buyyear,s1.kc_area_code,s1.kc_regn_code,s1.kc_regn_cate,s1.kc_regn_name

) AS s2
GROUP BY s2.kc_area_code,s2.kc_regn_code,s2.kc_regn_cate,s2.kc_regn_name
ORDER BY s2.kc_area_code,s2.kc_regn_code

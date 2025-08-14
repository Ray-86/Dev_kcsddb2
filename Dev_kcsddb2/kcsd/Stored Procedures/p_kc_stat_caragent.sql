-- ==========================================================================================
-- 20170220 增加產生月報資料
-- 20110709 A類: 無成交記錄 (不變)
-- 			B類: 有成交紀錄, 且前次成交, 在6~12月內
-- 			C類: 有成交紀錄, 且前次成交, 在12個月前
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_stat_caragent] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_carlevel
(
kc_buy_date		varchar(6),
kc_area_code	varchar(2),
kc_level_type	varchar(1),
kc_level_cnt	int
)

	INSERT	#tmp_carlevel
	SELECT 
	convert(varchar(6),s.kc_buy_date,112) as kc_buy_date ,s.kc_area_code,kc_level_type,count(*) as kc_level_cnt FROM 
	(
	SELECT c.kc_area_code,c.kc_sales_code, Max(c.kc_case_no) AS kc_case_no, c.kc_comp_code, Max(c.kc_buy_date) AS kc_buy_date,
	CASE WHEN s.kc_buy_date is null THEN 'A' ELSE (CASE WHEN s.kc_buy_date Between DateAdd(mm,-12,@pm_strt_date) And DateAdd(mm,-6,@pm_strt_date) THEN 'B' ELSE (CASE WHEN s.kc_buy_date < DateAdd(mm,-12,@pm_strt_date)  THEN 'C' ELSE null END) END) END AS kc_level_type

	FROM kcsd.kc_customerloan c LEFT JOIN (SELECT kc_comp_code, MAX(kc_buy_date) as kc_buy_date FROM kcsd.kc_customerloan c1 WHERE kc_buy_date < @pm_strt_date GROUP BY kc_comp_code) s ON s.kc_comp_code = c.kc_comp_code
	WHERE 
	c.kc_loan_stat not in ('Y','Z') AND c.kc_buy_date Between @pm_strt_date And @pm_stop_date
	GROUP BY c.kc_area_code,c.kc_sales_code,c.kc_comp_code,s.kc_buy_date
	) AS s
	WHERE s.kc_level_type is not null
	GROUP by s.kc_area_code,convert(varchar(6),s.kc_buy_date,112),s.kc_level_type
	ORDER by s.kc_area_code,convert(varchar(6),s.kc_buy_date,112),s.kc_level_type


IF	@pm_run_code = 'EXECUTE'
BEGIN

DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_stat_caragent where kc_buy_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_stat_caragent
		SELECT * from #tmp_carlevel
	END

END
ELSE
BEGIN
	SELECT	* FROM	#tmp_carlevel
END

DROP TABLE #tmp_carlevel

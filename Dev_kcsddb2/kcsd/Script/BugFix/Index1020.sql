-- 25.08.19 kc_audit_date 資料型態是dateTime, 查詢是轉成Date
DECLARE @wk_strt_date Date, @wk_stop_date Date,
				   @wk_strt_date2 Date, @wk_stop_date2 Date,
				   @wk_area_code varchar(5),
				   @wk_biz_stat varchar(5),
				   @wk_sales_code2 varchar(5)

SELECT DISTINCT p.kc_sales_code'new_sales_code', c.*
FROM kcsd.kc_caragent C
LEFT JOIN kcsd.kc_caragentbranchProd P 
	   ON C.kc_agent_code = P.kc_agent_code
WHERE 1=1
  AND ((@wk_strt_date='' OR @wk_stop_date='') OR (CONVERT(Date, kc_audit_date) BETWEEN @wk_strt_date AND @wk_stop_date))  --審核日期
  AND ((@wk_strt_date2='' OR @wk_stop_date2='') OR (kc_dev_date BETWEEN @wk_strt_date2 AND @wk_stop_date2))  --開發日期
  AND (@wk_area_code = '' OR kc_area_code = @wk_area_code) --分公司
  AND (@wk_biz_stat = '' OR kc_biz_stat = @wk_biz_stat) --登記現況
  AND (@wk_sales_code2 = '' OR p.kc_sales_code = @wk_sales_code2) --業務人員
-- ==========================================================================================
-- 20170218 改寫直接查詢年度資料統計
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_stat_salesoverdue_year] @pm_query_type int = NULL
AS
DECLARE	@wk_buy_date	datetime,
		@wk_strt_date	datetime,
		@wk_stop_date	datetime,
		@wk_stop_date2	datetime,
		@wk_month_cnt	int

CREATE TABLE #tmp_salesoverdue
(
kc_case_no		varchar(7),
kc_area_code	varchar(2),
kc_buy_date		datetime,
kc_over_amt		int,
kc_over_count	int,
kc_pay_sum		int,
kc_updt_fig		int
)

IF	@pm_query_type = '0'
BEGIN
	SELECT @wk_month_cnt = 4 --完全未繳(前4月)
END
ELSE
BEGIN
	SELECT @wk_month_cnt = 15 --累計完全未繳(前月)
END

IF @pm_query_type is null return

DECLARE	cursor_comp_code CURSOR
FOR	
SELECT DISTINCT 
convert(datetime, convert(varchar(6),kc_buy_date,112)+'01', 112),
DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-@wk_month_cnt,kc_buy_date))+1, 0),
dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-3,kc_buy_date))+1, 0)),
dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,convert(datetime, convert(varchar(6),kc_buy_date,112)+'01', 112))+1, 0))
FROM	kcsd.kc_customerloan
GROUP BY kc_buy_date
--2016-02-01 2015/12/1~2016/11/30及2017/2/1~2017/2/28)，
OPEN cursor_comp_code
FETCH NEXT FROM cursor_comp_code INTO @wk_buy_date,@wk_strt_date,@wk_stop_date,@wk_stop_date2
WHILE (@@FETCH_STATUS = 0)
BEGIN

	Insert into #tmp_salesoverdue exec kcsd.p_kc_stat_salesoverdue @wk_strt_date,@wk_stop_date,@wk_stop_date2
	update #tmp_salesoverdue set kc_buy_date = @wk_buy_date,kc_updt_fig = 1 where kc_updt_fig = 0
	FETCH NEXT FROM cursor_comp_code INTO  @wk_buy_date,@wk_strt_date,@wk_stop_date,@wk_stop_date2
END

DEALLOCATE	cursor_comp_code

--SELECT * FROM #tmp_salesoverdue ORDER BY kc_buy_date,kc_area_code

SELECT convert(varchar(6),kc_buy_date,112),kc_area_code,count(kc_over_amt)
FROM #tmp_salesoverdue
where kc_over_amt>0 and kc_pay_sum =0
GROUP BY convert(varchar(6),kc_buy_date,112),kc_area_code
ORDER BY convert(varchar(6),kc_buy_date,112),kc_area_code


DROP TABLE #tmp_salesoverdue

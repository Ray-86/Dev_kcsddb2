
-- ==========================================================================================
-- 20211124 新增查訪成本、認列違約金計算
-- 20171201 增加業務處理費用
-- 20170926 法務獎金計算
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_pushonhand_lawscore] @pm_strt_date datetime, @pm_stop_date datetime
AS

DECLARE	@wk_pusher_code varchar(10)

CREATE TABLE #tmp_pushonhand_law
(
	kc_case_no			varchar(10),
	kc_area_code		varchar(2),
	kc_area_desc		varchar(10),
	kc_pusher_code		varchar(6),
	kc_strt_date		datetime,
	kc_close_date		datetime,
	kc_over_amt			int,
	kc_pay_sum			int,
	kc_pay_sum1			int,
	kc_pay_sum2			int,
	kc_intr_sum			int,
	kc_break_sum		int,
	kc_law_sum			int,
	kc_sales_sum		int,
	kc_delay_code		varchar(1),
	kc_buy_date			datetime,
	kc_cust_nameu		nvarchar(60),
	kc_emp_name			varchar(10),
	kc_loan_desc		varchar(6),
	kc_recog_amt		int
)

--取得資料
INSERT #tmp_pushonhand_law EXEC kcsd.p_kc_pushonhand_law @pm_strt_date, @pm_stop_date

SELECT kc_pusher_code, 
	SUM(kc_over_amt) AS kc_over_amt, 
	SUM(kc_pay_sum) AS kc_pay_sum, 
	SUM(kc_pay_sum1) AS kc_pay_sum1, 
	SUM(kc_pay_sum2) AS kc_pay_sum2, 
	SUM(kc_intr_sum) AS kc_intr_sum, 
	SUM(kc_break_sum) AS kc_break_sum, 
	SUM(kc_law_sum) AS kc_law_sum, 
	SUM(kc_sales_sum) AS kc_sales_sum,
	SUM(kc_pay_sum)-SUM(kc_intr_sum)+SUM(kc_pay_sum2) AS kc_total_fee, 
	SUM(kc_pay_sum1)*0.5+SUM(kc_break_sum)-SUM(kc_law_sum)-SUM(kc_sales_sum) AS kc_total_break, 
	ROW_NUMBER() OVER(ORDER BY (SUM(kc_pay_sum)-SUM(kc_intr_sum)+SUM(kc_pay_sum2)-SUM(kc_law_sum)+SUM(kc_pay_sum1)*0.5+SUM(kc_break_sum)-SUM(kc_sales_sum)) DESC) AS kc_rank,
	SUM(kc_recog_amt) AS kc_recog_amt
FROM #tmp_pushonhand_law
WHERE kc_pusher_code IN (SELECT DelegateCode FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%')
GROUP BY kc_pusher_code

DROP TABLE #tmp_pushonhand_law
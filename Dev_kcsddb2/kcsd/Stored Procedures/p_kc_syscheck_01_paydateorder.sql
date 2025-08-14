-- ==========================================================================================
-- 2013/12/10 改為只檢查日期區內入帳資料
-- 2012/08/13 日期條件改為BETWEEN、Cursor 改 SQL、取消日期條件為NULL時預設查2010/01/01之後的資料
-- 09/25/2010 檢查區間由應繳日期改為順繳款日期, 以方便區隔區間
-- 09/11/2010 檢查應繳日期順序繳款順序是否不合 (應繳日期早的應該先繳款)
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_syscheck_01_paydateorder] @pm_strt_date datetime, @pm_stop_date datetime 
AS

select IDENTITY(int,1,1) as [ROW_NUMBER],kc_case_no,kc_perd_no,kc_expt_date,kc_pay_date
into #tem1             
from kcsd.kc_loanpayment
WHERE kc_pay_date between @pm_strt_date and @pm_stop_date AND kc_pay_date IS NOT NULL
ORDER BY kc_case_no,kc_expt_date,kc_perd_no
 
select IDENTITY(int,1,1) as [ROW_NUMBER],kc_case_no,kc_perd_no,kc_expt_date,kc_pay_date
into #tem2             
from kcsd.kc_loanpayment
WHERE kc_pay_date between @pm_strt_date and @pm_stop_date AND kc_pay_date IS NOT null
ORDER BY kc_case_no,kc_pay_date 
 
SELECT DISTINCT #tem1.kc_case_no from #tem1,#tem2
WHERE 
 #tem1.[ROW_NUMBER] = #tem2.[ROW_NUMBER] AND
 #tem1.kc_pay_date <> #tem2.kc_pay_date
ORDER BY #tem1.kc_case_no

drop table #tem1
drop table #tem2

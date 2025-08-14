CREATE    PROCEDURE [kcsd].[p_kc_check_test] @pm_strt_date datetime, @pm_stop_date datetime 
AS

select IDENTITY(int,1,1) as [ROW_NUMBER],kc_case_no,kc_perd_no,kc_expt_date,kc_pay_date
into #tem1             
from kcsd.kc_loanpayment
WHERE kc_case_no in(select kc_case_no from kcsd.kc_loanpayment where kc_pay_date between @pm_strt_date and @pm_stop_date) AND kc_pay_date IS NOT NULL
ORDER BY kc_case_no,kc_expt_date,kc_perd_no
 
select IDENTITY(int,1,1) as [ROW_NUMBER],kc_case_no,kc_perd_no,kc_expt_date,kc_pay_date
into #tem2             
from kcsd.kc_loanpayment
WHERE kc_case_no in(select kc_case_no from kcsd.kc_loanpayment where kc_pay_date between @pm_strt_date and @pm_stop_date) AND kc_pay_date IS NOT NULL
ORDER BY kc_case_no,kc_pay_date 
 
SELECT DISTINCT #tem1.kc_case_no from #tem1,#tem2
WHERE 
 #tem1.[ROW_NUMBER] = #tem2.[ROW_NUMBER] AND
 #tem1.kc_pay_date <> #tem2.kc_pay_date
ORDER BY #tem1.kc_case_no

drop table #tem1
drop table #tem2

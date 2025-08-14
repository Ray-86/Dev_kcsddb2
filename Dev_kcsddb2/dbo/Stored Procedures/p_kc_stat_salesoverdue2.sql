-- ==========================================================================================
-- 2014-06-10 cursor 改寫 select
-- 2005-11-12 proc for 業務逾期統計 kcp_stat01
-- ==========================================================================================

CREATE PROCEDURE [dbo].[p_kc_stat_salesoverdue2]
	@pm_strt_date DATETIME=NULL,
	@pm_stop_date DATETIME=NULL,
	@pm_cut_date DATETIME=NULL
AS

SELECT	@pm_cut_date = DATEADD(day, 1, @pm_cut_date )

SELECT kc_case_no,
1 AS kc_over_amt,
(SELECT	DATEDIFF(day,MIN(kc_expt_date),@pm_cut_date)/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND (kc_pay_date >= @pm_cut_date OR kc_pay_date IS NULL)) AS kc_over_count,
(SELECT	ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date < @pm_cut_date) AS kc_pay_sum
FROM	kcsd.kc_customerloan c
WHERE 
kc_buy_date BETWEEN @pm_strt_date  AND @pm_stop_date
and kc_loan_stat Not In ('Y','Z') AND
(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < @pm_cut_date AND kc_perd_no < 50)-
(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date <@pm_cut_date)>0
ORDER BY c.kc_case_no

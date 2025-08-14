-- ==========================================================================================
-- 2014-06-10 cursor 改寫 select
-- 2005-11-12 proc for 業務逾期統計 kcp_stat01
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_stat_salesoverdue3]
	@pm_strt_date DATETIME=NULL,
	@pm_stop_date DATETIME=NULL,
	@pm_cut_date DATETIME=NULL
AS

SELECT	@pm_cut_date = DATEADD(day, 1, @pm_cut_date )

	SELECT 	ss.kc_case_no,c.kc_sales_code,c.kc_area_code,c.kc_new_flag,c.kc_loan_stat,
		(SELECT DATEDIFF(day,MIN(kc_expt_date),@pm_cut_date)/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = ss.kc_case_no AND (kc_pay_date >= @pm_cut_date OR kc_pay_date IS NULL)) AS kc_over_count,
		sum(ss.kc_pay_fee) AS kc_pay_sum
	FROM 
	kcsd.kc_customerloan c,
	(
	SELECT l.kc_case_no AS kc_case_no ,ISNULL(SUM(l.kc_expt_fee), 0) AS kc_expt_fee,0 AS kc_pay_fee
	FROM kcsd.kc_loanpayment l  
	WHERE 
	l.kc_expt_date < @pm_cut_date AND
	l.kc_perd_no < 50 AND
	EXISTS	(
		SELECT 'X'
		FROM	kcsd.kc_customerloan c
		WHERE
		l.kc_case_no = c.kc_case_no and 
		kc_buy_date BETWEEN @pm_strt_date  AND @pm_stop_date
		and kc_loan_stat Not In ('Y','Z')
		)	
	GROUP BY l.kc_case_no
	UNION ALL
	SELECT l.kc_case_no AS kc_case_no,0 AS kc_expt_fee,ISNULL(SUM(l.kc_pay_fee), 0) AS kc_pay_fee
	FROM kcsd.kc_loanpayment l 
	WHERE 
 	l.kc_pay_date <@pm_cut_date AND
	EXISTS	(
		SELECT 'X'
		FROM	kcsd.kc_customerloan c
		WHERE
		l.kc_case_no = c.kc_case_no and 
		kc_buy_date BETWEEN @pm_strt_date  AND @pm_stop_date
		and kc_loan_stat Not In ('Y','Z')
		)	
	GROUP BY l.kc_case_no
	) AS ss
	WHERE ss.kc_case_no=c.kc_case_no
	GROUP by ss.kc_case_no,c.kc_sales_code,c.kc_area_code,c.kc_new_flag,c.kc_loan_stat
	HAVING sum(ss.kc_expt_fee) - sum(ss.kc_pay_fee) > 0
	ORDER BY ss.kc_case_no

 DECLARE @wk_strt_date date ='2025-11-01', @wk_stop_date date='2025-11-30', @wk_issu_code varchar(2) ='03'
 
 SELECT kc_customerloan.kc_case_no, kc_area_code, kc_issu_code, kc_cust_nameu, kc_buy_date, kc_perd_fee*kc_loan_perd-kc_pvall_amt-wk_invo_amt2 AS wk_unreal_intr, 
	   kc_pvall_amt-kc_total_price+kc_strt_fee-ISNULL(kc_insu_sum,0)-ISNULL(kc_rule_fee,0)-ISNULL(wk_proc_amt2,0)-ISNULL(kc_cred_fee,0) AS wk_unreal_proc, 
	   kc_loan_fee-ISNULL(wk_pvpay_amt2,0)+ISNULL(kc_cred_fee,0)+ISNULL(kc_rule_fee,0)+ISNULL(kc_insu_sum,0) AS wk_cap_remain, kc_rema_amt, kc_pay_sum
FROM kcsd.kc_customerloan 
INNER JOIN 
(
	SELECT kc_customerloan.kc_case_no, SUM(ISNULL(kc_pvpay_amt2,0)) AS wk_pvpay_amt2, SUM(ISNULL(kc_invo_amt2,0)) AS wk_invo_amt2, SUM(ISNULL(kc_proc_amt2,0)) AS wk_proc_amt2, SUM(ISNULL(kc_intr_fee,0)) AS wk_intr_fee
	FROM kcsd.kc_customerloan
	INNER JOIN (SELECT DISTINCT kc_case_no FROM kcsd.kc_lawstatus WHERE kc_law_fmt IN ('XA','XU') AND kc_doc_date BETWEEN @wk_strt_date AND @wk_stop_date) AS List ON kc_customerloan.kc_case_no = List.kc_case_no
	INNER JOIN kcsd.kc_loanpayment ON kc_customerloan.kc_case_no = kc_loanpayment.kc_case_no
	WHERE (kc_loanpayment.kc_pay_date <= @wk_stop_date OR kc_loanpayment.kc_pay_date IS NULL)
	AND kc_customerloan.kc_loan_stat NOT IN ('C','E','X','Y','Z') AND kc_idle_date IS NULL
	GROUP BY kc_customerloan.kc_case_no
) AS IdleA ON kc_customerloan.kc_case_no = IdleA.kc_case_no
LEFT JOIN 
(
	SELECT kc_case_no, SUM(ISNULL(kc_pay_fee,0)) AS kc_pay_sum 
	FROM kcsd.kc_loanpayment 
	WHERE (kc_pay_date > @wk_stop_date OR kc_pay_date IS NULL) 
	GROUP BY kc_case_no
) AS IdleB ON kc_customerloan.kc_case_no = IdleB.kc_case_no
WHERE (LEFT(kc_customerloan.kc_case_no,1) in ('T','B') OR LEFT(kc_customerloan.kc_case_no,1) BETWEEN '0' AND '5')
  AND kc_loan_stat NOT IN ('X','Y','Z')
  AND kc_issu_code = @wk_issu_code 
  AND (@wk_issu_code <> '06' or (@wk_issu_code = '06' and kc_prod_type <> '04'))
  AND kc_prod_type <> '08' --勞務件
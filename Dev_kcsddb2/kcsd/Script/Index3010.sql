DECLARE @wk_strt_date date ='2025-11-01', @wk_stop_date date='2025-11-30' --呆帳日期
DECLARE @wk_strt_date2 date ='2025-11-01', @wk_stop_date2 date='2025-11-30' --繳款日期
DECLARE @wk_issu_code varchar(2) ='01', @wk_law_code varchar(2)='' --公司別, 催告格式

              --建檔日          客戶編號                                       客戶姓名
SELECT kc_buy_date, kc_customerloan.kc_case_no, kc_cust_nameu, 
               (kc_perd_fee*kc_loan_perd)-kc_pvall_amt-ISNULL(wk_invo_amt2,0) AS wk_unreal_intr, --未實現利息
	           (kc_pvall_amt-kc_total_price+kc_strt_fee-ISNULL(kc_rule_fee,0)-ISNULL(wk_proc_amt2,0)-ISNULL(kc_insu_sum,0)-ISNULL(kc_cred_fee,0)) AS wk_unreal_proc, --未實現手續費
	           kc_capremain_fee, kc_idle_amt, wk_idleb_amt, kc_idle_type, --本金餘額 提列金額 收回 備註

	           kc_area_code, kc_issu_code,  kc_idle_date
FROM kcsd.kc_customerloan 
LEFT JOIN 
(
	SELECT kc_customerloan.kc_case_no, SUM(kc_pay_fee-ISNULL(kc_intr_fee,0)) AS wk_idleb_amt, MAX(kc_invo_date) AS wk_lpay_date, SUM(kc_loanpayment.kc_proc_fee) AS wk_proc_sum, 
	SUM(CASE WHEN kc_loanpayment.kc_pay_type = 'C' AND kc_loanpayment.kc_invo_date < '2008-01-01' THEN 0 ELSE kc_loanpayment.kc_break_fee END) AS wk_break_sum, MAX(kc_loanpayment.kc_pay_type) AS wk_pay_type
	FROM kcsd.kc_customerloan
	INNER JOIN kcsd.kc_loanpayment ON kc_customerloan.kc_case_no = kc_loanpayment.kc_case_no
	WHERE kc_customerloan.kc_idle_amt IS NOT NULL AND LEFT(kc_customerloan.kc_case_no,1) <> '9'
	AND (kc_loanpayment.kc_rece_code IS NULL OR kc_loanpayment.kc_rece_code <> 'A3')
	AND kc_loanpayment.kc_invo_date > kc_customerloan.kc_idle_date
	AND kc_loanpayment.kc_invo_date BETWEEN @wk_strt_date2 AND @wk_stop_date2
	GROUP BY kc_customerloan.kc_case_no
) AS IdleA ON kc_customerloan.kc_case_no = IdleA.kc_case_no
LEFT JOIN 
(
	SELECT kc_customerloan.kc_case_no, SUM(kc_pvpay_amt2) AS wk_pvpay_amt2, SUM(kc_invo_amt2) AS wk_invo_amt2, SUM(kc_proc_amt2) AS wk_proc_amt2, SUM(kc_intr_fee) AS wk_intr_fee
	FROM kcsd.kc_customerloan
	INNER JOIN kcsd.kc_loanpayment ON kc_customerloan.kc_case_no = kc_loanpayment.kc_case_no
	WHERE kc_customerloan.kc_idle_date IS NOT NULL AND LEFT(kc_customerloan.kc_case_no,1) <> '9'
	AND kc_loanpayment.kc_invo_date <= kc_customerloan.kc_idle_date
	GROUP BY kc_customerloan.kc_case_no
) AS IdleB ON kc_customerloan.kc_case_no = IdleB.kc_case_no
WHERE kc_idle_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND kc_customerloan.kc_prod_type <> '08' --勞務件
     AND kc_idle_amt IS NOT NULL
     AND (LEFT(kc_customerloan.kc_case_no,1) = 'T' OR LEFT(kc_customerloan.kc_case_no,1) BETWEEN '0' AND '5' OR LEFT(kc_customerloan.kc_case_no,1) = 'B')
     AND kc_loan_stat NOT IN ('X','Y','Z') 
     AND kc_issu_code = @wk_issu_code
     AND (@wk_issu_code <> '06' OR (@wk_issu_code = '06' and kc_prod_type <> '04'))
-- 報表 - 稅務類 : 預估每約分期營收表
DECLARE @wk_strt_date Date = '2025-08-01',   --應繳日期起始
                   @wk_stop_date Date = '2025-08-31' --應繳日期結束
SELECT kc_prod_type + ' ' + SC.[Text] '產品別', kc_expt_fee'預估月付款', kc_pvpay_amt2'還本數', 
               kc_invo_amt2'利息收入', kc_proc_amt2'手續費收入', kc_invo_amt2+kc_proc_amt2'財務收入', 
			   kc_pay_fee'已繳金額', '回收率'
FROM kcsd.kc_customerloan C
INNER JOIN kcsd.kc_loanpayment P --應繳日期
				ON C.kc_case_no=P.kc_case_no
INNER JOIN [Zephyr.Sys].dbo.sys_code SC --產品別
				ON C.kc_prod_type=SC.[Value] AND  SC.CodeType='ProductType' 
WHERE P.kc_expt_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND kc_prod_type <> '04' --應收排除 04 原車買賣
--GROUP BY kc_prod_type

SELECT TOP 10 * FROM kcsd.kc_loanpayment WHERE kc_pay_date IS NULL ORDER BY kc_expt_date DESC

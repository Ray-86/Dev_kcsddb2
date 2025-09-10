DECLARE @wk_strt_date Date ='2025-01-01',
                  @wk_stop_date Date ='2025-09-30'

SELECT SUBSTRING(kc_issu_desc, 1, 4)'公司別', kc_buy_date, kc_prod_type+' '+SC.[Text] '產品別',-- CONCAT((YEAR(kc_buy_date)-1911),'-',MONTH(kc_buy_date))'年月',
			    kc_loan_fee'撥款金額', (kc_perd_fee * kc_loan_perd)'應收分期款'
FROM kcsd.kc_customerloan L
INNER JOIN kcsd.kct_issuecompany I ON L.kc_issu_code=I.kc_issu_code 
INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType='ProductType' AND L.kc_prod_type=SC.[Value]
WHERE kc_regissu_type = '1'
	 AND ((L.kc_issu_code IN ('01','03') ) or (L.kc_issu_code = '06' and kc_prod_type <> '04'))
	 AND kc_buy_date BETWEEN @wk_strt_date and @wk_stop_date
	 AND kc_prod_type <> '08' --勞務件
	 AND kc_loan_stat NOT IN ('X','Y','Z')

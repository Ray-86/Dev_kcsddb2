--25.08.08 提供v1(2025.01.01~2025.08.08)  C:\Users\Ray\Documents\Ray\臨時報表\財管1140808-手續費結案名單 v1.xls
--25.08.15 提供v2(2025.01.01~2025.08.15)  C:\Users\Ray\Documents\Ray\臨時報表\財管1140808-手續費結案名單 v2.xls 
--25.08.15 提供v3(2024.01.01~2025.08.15)  C:\Users\Ray\Documents\Ray\臨時報表\財管1140808-手續費結案名單 v3.xls 
DECLARE @wk_strt_date Date ='2024-01-01',
                   @wk_stop_date Date ='2025-08-15'
SELECT C.kc_area_code + ' ' + A.kc_area_desc, CONVERT(Date, C.kc_buy_date), CP.kc_prod_type + ' ' + SC.[Text], 
			   C.kc_cp_no, C.kc_case_no, C.kc_cust_nameu, C.kc_id_no, 
			   CP.kc_comp_code, AG.kc_agent_name, CP.kc_sales_code + ' ' + U.UserName, 
			   C.kc_car_model, ISNULL(C.kc_licn_no,''), C.kc_loan_perd, C.kc_perd_fee,C.kc_give_amt, P.kc_intr_fee
FROM kcsd.kc_customerloan C
INNER JOIN kcsd.kc_cpdata CP ON C.kc_cp_no=CP.kc_cp_no
INNER JOIN kcsd.kc_loanpayment  P ON C.kc_case_no= P.kc_case_no AND P.kc_intr_fee IS NOT NULL  AND P.kc_intr_fee>0
INNER JOIN kcsd.kct_area A ON C.kc_area_code=A.kc_area_code
INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType='ProductType' AND C.kc_prod_type=SC.[Value]
INNER JOIN kcsd.kc_caragent AG ON C.kc_comp_code = AG.kc_agent_code
INNER JOIN [Zephyr.Sys].dbo.sys_user U ON C.kc_sales_code=U.UserSeq
WHERE kc_buy_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND kc_loan_stat IN ('C', 'E')
ORDER BY C.kc_buy_date, C.kc_cp_no --若建檔日相同, 則按CP編號排序
 
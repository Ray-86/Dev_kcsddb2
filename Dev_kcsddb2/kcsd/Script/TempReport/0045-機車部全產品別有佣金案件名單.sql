--25.08.15 提供v1(2025.05.01~2025.07.31)   C:\Users\Ray\Documents\Ray\臨時報表\財管1140815-機車部全產品別有佣金之案件 v1.xls 
--25.08.15 提供v2(2025.01.01~2025.07.31)   C:\Users\Ray\Documents\Ray\臨時報表\財管1140815-機車部全產品別有佣金之案件 v2.xls 
--25.08.18 修正語法 - 移除手續費結案條件, 且提供v3(2025.05.01~2025.07.31)   C:\Users\Ray\Documents\Ray\臨時報表\財管1140815-機車部全產品別有佣金之案件 v3.xls 
--                 調整語法 - 刪除佣金篩選條件, 新增欄位 現價差額, 提供另一報表 (2025.05.01~2025.07.31)  C:\Users\Ray\Documents\Ray\臨時報表\財管1140815-機車部全產品別案件.xls
DECLARE @wk_strt_date Date ='2025-05-01',
                   @wk_stop_date Date ='2025-07-31'
SELECT C.kc_area_code + ' ' + A.kc_area_desc'分公司', CONVERT(Date, C.kc_buy_date)'建檔日', CP.kc_prod_type + ' ' + SC.[Text]'產品別', C.kc_cp_no'CP編號', 
			   C.kc_case_no'客戶編號', C.kc_cust_nameu'客戶姓名', C.kc_id_no'身分證號', 
			   CP.kc_comp_code'經銷', AG.kc_agent_name'經銷名稱', CP.kc_sales_code + ' ' + U.UserName'承辦業務', 
			   C.kc_car_model'形式', ISNULL(C.kc_licn_no,'')'牌照號碼', C.kc_give_amt'撥款金額', 
			   C.kc_brok_fee2'佣金', C.kc_loan_perd'期數', C.kc_perd_fee'月付款', kc_cons_rate'CP利率',
			   C.kc_perd_fee * C.kc_loan_perd - (C.kc_give_amt - C.kc_brok_fee2) '現價差額'
FROM kcsd.kc_customerloan C
INNER JOIN kcsd.kc_cpdata CP ON C.kc_cp_no=CP.kc_cp_no
INNER JOIN kcsd.kct_area A ON C.kc_area_code=A.kc_area_code
INNER JOIN [Zephyr.Sys].dbo.sys_code SC ON SC.CodeType='ProductType' AND C.kc_prod_type=SC.[Value]
INNER JOIN kcsd.kc_caragent AG ON C.kc_comp_code = AG.kc_agent_code
INNER JOIN [Zephyr.Sys].dbo.sys_user U ON C.kc_sales_code=U.UserSeq
WHERE kc_buy_date BETWEEN @wk_strt_date AND @wk_stop_date
     AND CP.kc_prod_type IN ('01', '04', '06', '07', '13')
	 --AND kc_brok_fee2>0
ORDER BY C.kc_buy_date, C.kc_cp_no --若建檔日相同, 則按CP編號排序



 
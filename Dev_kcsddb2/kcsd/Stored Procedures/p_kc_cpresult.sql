-- ==========================================================================================
-- 20181108 增加 連結顯示新車行欄位
-- CP 顯示連結
-- ==========================================================================================

CREATE        PROCEDURE [kcsd].[p_kc_cpresult] @wk_cp_no varchar(10)
AS

Select
cpr.kc_cp_no,
cpr.kc_case_no,
code.Text As 'kc_cust_typename',
ISNULL(area.kc_area_desc,'') + ISNULL(area1.kc_area_desc,'') As kc_area_desc,
case 
	when cpr.kc_cust_type = 'CP' Then cp.kc_cp_date
	when cpr.kc_cust_type = 'C'  Then cm.kc_buy_date
	when cpr.kc_cust_type IN ('B') Then b.kc_updt_date
	when cpr.kc_cust_type IN ('XC') Then dy1cm.kc_updt_date
	when cpr.kc_cust_type IN ('XC2') Then dy1cm0.kc_updt_date
	when cpr.kc_cust_type IN ('XB','XT','RC') Then null
	when cpr.kc_cust_type = 'T' Then o.kc_buy_date
end As kc_cp_date,
cpr.kc_cust_type,
'1' AS kc_item_no,
cpr.kc_id_no,
cpr.kc_cust_nameu,
cpr.kc_papa_nameu,
cpr.kc_mama_nameu,
cpr.kc_mate_nameu,
case 
	when cpr.kc_cust_type = 'CP' Then (CASE WHEN cp.kc_ccis_flag = 'Y' Then '[CCIS]' ELSE '' END) +'[' + ISNULL(cp.kc_apply_stat + code2.text,'') +'] ' + ISNULL(cp.kc_emp_code,'') + ISNULL(emp.kc_emp_name,'') + ' ' + (case when cp.kc_agent_code is null Then cpcar.kc_agent_name else cp.kc_agent_code end) + ' ' + ISNULL(cp.kc_rej_note,'')  + ']'
	when cpr.kc_cust_type = 'C' AND cm.kc_loan_stat not in ('C','E') Then '['+ISNULL(cm.kc_loan_stat+code1.text,'') + ' 違約金:' + ISNULL(convert(VARCHAR(10),cm.kc_break_amt2),'') + ' 車況:' +ISNULL(cm.kc_car_stat + ' ' + code3.text,'')+' 催收:' +ISNULL(cm.kc_pusher_code,'無') +']' + ISNULL(cm.kc_sales_code,'') + ISNULL(emp1.kc_emp_name,'') + ' ' + ISNULL(ca.kc_agent_name,'') + ' ' + ISNULL(cm.kc_car_model,'') + ' ' + case when cm.kc_new_flag = 'N' Then '新車' when cm.kc_new_flag = 'O' Then '舊車' end + ' 貸' + ISNULL(convert(nvarchar(10),cm.kc_give_amt),'') + ' 月付' + ISNULL(convert(nvarchar(10),cm.kc_perd_fee),'') + ' 分' + ISNULL(convert(nvarchar(10),cm.kc_loan_perd),'') + '期 (已繳' + ISNULL(Convert(nvarchar(10),Maxperdno.MaxPerdNo),'0') + '期)' + (case when isnull(cm.kc_rema_amt, 0) <> 0 then '(未繳餘額' + isnull(convert(varchar, cm.kc_rema_amt), '0') + ')' else '' end)
	when cpr.kc_cust_type = 'C' AND cm.kc_loan_stat in ('C','E') Then '['+ISNULL(cm.kc_loan_stat+code1.text,'') + ' 違約金:' + ISNULL(convert(VARCHAR(10),cm.kc_break_amt2),'') + ' 車況:' +ISNULL(cm.kc_car_stat + ' ' + code3.text,'')+' 催收:' +ISNULL(cm.kc_pusher_code,'無') +']' + ISNULL(cm.kc_sales_code,'') + ISNULL(emp1.kc_emp_name,'') + ' ' + ISNULL(ca.kc_agent_name,'') + ' ' + ISNULL(cm.kc_car_model,'') + ' ' + case when cm.kc_new_flag = 'N' Then '新車' when cm.kc_new_flag = 'O' Then '舊車' end + ' 貸' + ISNULL(convert(nvarchar(10),cm.kc_give_amt),'') + ' 月付' + ISNULL(convert(nvarchar(10),cm.kc_perd_fee),'') + ' 分' + ISNULL(convert(nvarchar(10),cm.kc_loan_perd),'') + '期 ' + (select case when datediff(day,max(kc_pay_date),max(kc_expt_date))>=30 Then '('+ CONVERT(varchar(10), max(kc_pay_date), 112) + '繳'+ (select top 1 CONVERT(varchar(6),sum(kc_pay_fee)) as kc_pay_fee from kcsd.kc_loanpayment Where kc_case_no = cm.kc_case_no group by kc_pay_date order by kc_pay_date desc) +'提前'+ convert(nvarchar(5),round(cast(datediff(day,max(kc_pay_date),max(kc_expt_date)) as float)/30,1))+'個月結清)' ELSE '' END as diffday from kcsd.kc_customerloan c left join kcsd.kc_loanpayment l on l.kc_case_no = c.kc_case_no where c.kc_loan_stat in ('C','E') and c.kc_case_no = cm.kc_case_no) + (case when isnull(cm.kc_rema_amt, 0) <> 0 then '(未繳餘額' + isnull(convert(varchar, cm.kc_rema_amt), '0') + ')' else '' end)
	when cpr.kc_cust_type IN ('B') Then '[婉拒]' + ISNULL(convert(VARCHAR(10),b.kc_updt_date,111),'') + ' ' + ISNULL(b.kc_updt_user,'') + ' ' + ISNULL(b.kc_black_reason,'')
	when cpr.kc_cust_type IN ('BU') Then '[拒往]' + ISNULL(convert(VARCHAR(10),b.kc_updt_date,111),'') + ' ' + ISNULL(b.kc_updt_user,'') + ' ' + ISNULL(b.kc_black_reason,'')
	when cpr.kc_cust_type IN ('XC') Then '[' + dy1code1.Text + '] ' +ISNULL(dy1cm.kc_comp_code,'') + ' ' + ISNULL(dy1cm.kc_car_model,'') + ' ' + case when dy1cm.kc_new_flag = 'N' Then '新車' when dy1cm.kc_new_flag = 'O' Then '舊車' end + ' 月付' + ISNULL(convert(nvarchar(10),dy1cm.kc_perd_fee),'') + ' 期數' + ISNULL(convert(nvarchar(10),dy1cm.kc_loan_perd),'') 
	when cpr.kc_cust_type IN ('XC2') Then '[' + dy1code0.Text + '] ' +ISNULL(dy1cm0.kc_comp_code,'') + ' ' + ISNULL(dy1cm0.kc_car_model,'') + ' ' + case when dy1cm0.kc_new_flag = 'N' Then '新車' when dy1cm0.kc_new_flag = 'O' Then '舊車' end + ' 月付' + ISNULL(convert(nvarchar(10),dy1cm0.kc_perd_fee),'') + ' 期數' + ISNULL(convert(nvarchar(10),dy1cm0.kc_loan_perd),'') 
	when cpr.kc_cust_type IN ('XB','XT','RC') Then ISNULL(r.kc_ref_memo,'')
	when cpr.kc_cust_type = 'T' Then '[' + ISNULL(o.kc_cust_name,'') + '][' + ISNULL(convert(VARCHAR(10),o.kc_buy_date,111),'') + '][' + ISNULL(convert(nvarchar(50),o.kc_comp_code),'') + ']'
	else '查無資料...'
end As kc_memo --備註
From kcsd.kc_cpresult As cpr 
Left join kcsd.kc_cpdata As cp On cpr.kc_case_no = cp.kc_cp_no --CP
Left join kcsd.kc_customerloan As cm On cpr.kc_case_no = cm.kc_case_no --Cust
Left join kcsddb.kcsd.dy1kc_customerloan As dy1cm On cpr.kc_case_no = dy1cm.kc_case_no --CustDY1
Left join kcsddb.kcsd.kc_customerloan2 As dy1cm0 On cpr.kc_case_no = dy1cm0.kc_case_no --CustDY1低零
Left join kcsd.kc_blacklistlist As b On cpr.kc_case_no = b.kc_id_no and cpr.kc_cust_type in ('B','BU')--B BU
Left join kcsd.kc_reference As r On cpr.kc_case_no = r.kc_ref_no --reference
Left join kcsd.kc_othercase As o On cpr.kc_case_no = o.kc_id_no and cpr.kc_cust_type = 'T' --othercase
Left join kcsd.kc_employee As emp On cp.kc_emp_code = emp.kc_emp_code --emp
Left join kcsd.kc_employee As emp1 On cm.kc_sales_code = emp1.kc_emp_code --emp1
Left join kcsd.kc_caragent As ca On cm.kc_comp_code = ca.kc_agent_code --ca CASE 車行
Left join kcsd.kc_caragent As cpcar On cp.kc_comp_code = cpcar.kc_agent_code --cpcar CP 新車行
Left join [Zephyr.Sys].dbo.sys_code As code On cpr.kc_cust_type = code.Value and code.CodeType = 'CustomerType' --客戶類別
Left join [Zephyr.Sys].dbo.sys_code As code1 On cm.kc_loan_stat = code1.Value and code1.CodeType = 'LoanCode' --C狀態
Left join [Zephyr.Sys].dbo.sys_code As code2 On cp.kc_apply_stat = code2.Value and code2.CodeType = 'CpStatus' --CP狀態
Left join [Zephyr.Sys].dbo.sys_code As code3 On cm.kc_car_stat = code3.Value and code3.CodeType = 'CarStatus' --車況
Left join kcsd.kct_area As area On cp.kc_area_code = area.kc_area_code --area
Left join kcsd.kct_area As area1 On cm.kc_area_code = area1.kc_area_code --area
Left join [Zephyr.Sys].dbo.sys_code As dy1code1 On dy1cm.kc_loan_stat = dy1code1.Value and dy1code1.CodeType = 'LoanCode' --狀態DY1
Left join [Zephyr.Sys].dbo.sys_code As dy1code0 On dy1cm0.kc_loan_stat = dy1code0.Value and dy1code0.CodeType = 'LoanCode' --狀態DY1低零
Left join (Select kc_case_no,ISNULL(MAX(kc_perd_no),0) As MaxPerdNo From kcsd.kc_loanpayment Where kc_perd_no < 50 and kc_pay_date Is Not Null Group By kc_case_no) As Maxperdno On cm.kc_case_no = Maxperdno.kc_case_no
Where cpr.kc_cp_no = @wk_cp_no
union 
Select
cpr.kc_cp_no,
cpr.kc_case_no,
null As kc_cust_typename,
null As kc_area_desc,
null As kc_cp_date,
null As kc_cust_type,
'2' AS kc_item_no,
cpr.kc_id_no1,
cpr.kc_cust_name1u,
cpr.kc_papa_name1u,
cpr.kc_mama_name1u,
cpr.kc_mate_name1u,
case when cpr.kc_cust_type = 'CP' Then (CASE WHEN cp.kc_ccis_flag1 = 'Y' Then '[CCIS]' ELSE '' END) else null end As kc_memo --備註
From kcsd.kc_cpresult As cpr 
Left join kcsd.kc_cpdata As cp On cpr.kc_case_no = cp.kc_cp_no --CP
Left join kcsd.kc_customerloan As cm On cpr.kc_case_no = cm.kc_case_no --Cust
Left join kcsddb.kcsd.dy1kc_customerloan As dy1cm On cpr.kc_case_no = dy1cm.kc_case_no --CustDY1
Left join kcsddb.kcsd.kc_customerloan2 As dy1cm0 On cpr.kc_case_no = dy1cm0.kc_case_no --CustDY1低零
Left join kcsd.kc_blacklistlist As b On cpr.kc_case_no = b.kc_id_no and cpr.kc_cust_type in ('B','BU')--B BU
Left join kcsd.kc_reference As r On cpr.kc_case_no = r.kc_ref_no --reference
Left join kcsd.kc_othercase As o On cpr.kc_case_no = o.kc_id_no and cpr.kc_cust_type = 'T' --othercase
Left join kcsd.kc_employee As emp On cp.kc_emp_code = emp.kc_emp_code --emp
Left join kcsd.kc_employee As emp1 On cm.kc_sales_code = emp1.kc_emp_code --emp1
Left join kcsd.kc_caragent As ca On cm.kc_comp_code = ca.kc_agent_code --ca CASE 車行
Left join kcsd.kc_caragent As cpcar On cp.kc_comp_code = cpcar.kc_agent_code --cpcar CP 新車行
Left join [Zephyr.Sys].dbo.sys_code As code On cpr.kc_cust_type = code.Value and code.CodeType = 'CustomerType' --客戶類別
Left join [Zephyr.Sys].dbo.sys_code As code1 On cm.kc_loan_stat = code1.Value and code1.CodeType = 'LoanCode' --C狀態
Left join [Zephyr.Sys].dbo.sys_code As code2 On cp.kc_apply_stat = code2.Value and code2.CodeType = 'CpStatus' --CP狀態
Left join [Zephyr.Sys].dbo.sys_code As code3 On cm.kc_car_stat = code3.Value and code3.CodeType = 'CarStatus' --車況
Left join kcsd.kct_area As area On cp.kc_area_code = area.kc_area_code --area
Left join kcsd.kct_area As area1 On cm.kc_area_code = area1.kc_area_code --area
Left join [Zephyr.Sys].dbo.sys_code As dy1code1 On dy1cm.kc_loan_stat = dy1code1.Value and dy1code1.CodeType = 'LoanCode' --狀態DY1
Left join [Zephyr.Sys].dbo.sys_code As dy1code0 On dy1cm0.kc_loan_stat = dy1code0.Value and dy1code0.CodeType = 'LoanCode' --狀態DY1低零
Left join (Select kc_case_no,ISNULL(MAX(kc_perd_no),0) As MaxPerdNo From kcsd.kc_loanpayment Where kc_perd_no < 50 and kc_pay_date Is Not Null Group By kc_case_no) As Maxperdno On cm.kc_case_no = Maxperdno.kc_case_no
Where cpr.kc_cp_no = @wk_cp_no
union 
Select
cpr.kc_cp_no,
cpr.kc_case_no,
null As kc_cust_typename,
null As kc_area_desc,
null As kc_cp_date,
null As kc_cust_type,
'3' AS kc_item_no,
cpr.kc_id_no2,
cpr.kc_cust_name2u,
cpr.kc_papa_name2u,
cpr.kc_mama_name2u,
cpr.kc_mate_name2u,
case when cpr.kc_cust_type = 'CP' Then (CASE WHEN cp.kc_ccis_flag2 = 'Y' Then '[CCIS]' ELSE '' END) else null end As kc_memo --備註
From kcsd.kc_cpresult As cpr
Left join kcsd.kc_cpdata As cp On cpr.kc_case_no = cp.kc_cp_no --CP
Left join kcsd.kc_customerloan As cm On cpr.kc_case_no = cm.kc_case_no --Cust
Left join kcsddb.kcsd.dy1kc_customerloan As dy1cm On cpr.kc_case_no = dy1cm.kc_case_no --CustDY1
Left join kcsddb.kcsd.kc_customerloan2 As dy1cm0 On cpr.kc_case_no = dy1cm0.kc_case_no --CustDY1低零
Left join kcsd.kc_blacklistlist As b On cpr.kc_case_no = b.kc_id_no and cpr.kc_cust_type in ('B','BU')--B BU
Left join kcsd.kc_reference As r On cpr.kc_case_no = r.kc_ref_no --reference
Left join kcsd.kc_othercase As o On cpr.kc_case_no = o.kc_id_no and cpr.kc_cust_type = 'T' --othercase
Left join kcsd.kc_employee As emp On cp.kc_emp_code = emp.kc_emp_code --emp
Left join kcsd.kc_employee As emp1 On cm.kc_sales_code = emp1.kc_emp_code --emp1
Left join kcsd.kc_caragent As ca On cm.kc_comp_code = ca.kc_agent_code --ca
Left join [Zephyr.Sys].dbo.sys_code As code On cpr.kc_cust_type = code.Value and code.CodeType = 'CustomerType' --客戶類別
Left join [Zephyr.Sys].dbo.sys_code As code1 On cm.kc_loan_stat = code1.Value and code1.CodeType = 'LoanCode' --C狀態
Left join [Zephyr.Sys].dbo.sys_code As code2 On cp.kc_apply_stat = code2.Value and code2.CodeType = 'CpStatus' --CP狀態
Left join [Zephyr.Sys].dbo.sys_code As code3 On cm.kc_car_stat = code3.Value and code3.CodeType = 'CarStatus' --車況
Left join kcsd.kct_area As area On cp.kc_area_code = area.kc_area_code --area
Left join kcsd.kct_area As area1 On cm.kc_area_code = area1.kc_area_code --area
Left join [Zephyr.Sys].dbo.sys_code As dy1code1 On dy1cm.kc_loan_stat = dy1code1.Value and dy1code1.CodeType = 'LoanCode' --狀態DY1
Left join [Zephyr.Sys].dbo.sys_code As dy1code0 On dy1cm0.kc_loan_stat = dy1code0.Value and dy1code0.CodeType = 'LoanCode' --狀態DY1低零
Left join (Select kc_case_no,ISNULL(MAX(kc_perd_no),0) As MaxPerdNo From kcsd.kc_loanpayment Where kc_perd_no < 50 and kc_pay_date Is Not Null Group By kc_case_no) As Maxperdno On cm.kc_case_no = Maxperdno.kc_case_no
Where cpr.kc_cp_no = @wk_cp_no
order by kc_cp_no,kc_case_no,kc_item_no,kc_cp_date

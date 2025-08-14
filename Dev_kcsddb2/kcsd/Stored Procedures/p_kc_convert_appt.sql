CREATE PROCEDURE [kcsd].[p_kc_convert_appt] @wk_strt_date datetime,@wk_stop_date datetime,@wk_strt_date2 datetime,@wk_stop_date2 datetime
AS

SELECT kc_apptschedule.kc_case_no AS 客戶編號,
 kc_customerloan.kc_cust_nameu AS 客戶姓名,
 kc_customerloan.kc_rema_amt AS 未繳餘額,
 kc_apptschedule.kc_pusher_code AS 委派人員,
 Delegate.DelegateName AS 派訪人員,
 kc_apptschedule.kc_sales_code+v_Employee.EmpName AS 查訪人員,
 kc_apptschedule.kc_appt_date AS 派訪日期,
 kct_addresstype.kc_addr_type AS 派訪地址類型,
 kct_addresstype.kc_addr_desc AS 派訪地址,
 kct_appttype.kc_appt_desc AS 派訪類別,
 kc_apptschedule.kc_visit_date AS 查訪日期,
 v_Employee.EmpName AS 查訪人員,
 kc_apptschedule.kc_appt_amt AS 約收金額,
 kc_apptschedule.kc_break_amt AS 違約金,
 kc_apptschedule.kc_rela_name AS 關係人,
 kc_apptschedule.kc_pay_amt AS 收回金額,
 kc_apptschedule.kc_visit_outc AS 查訪結果,
 kc_apptschedule.kc_book_flag AS 有無本票,
 kc_apptschedule.kc_appt_stat AS 處理狀態,
 kc_apptschedule.kc_next_date AS 改約日期,
 kc_apptschedule.kc_pay_type AS 付款方式,
 kc_apptschedule.kc_appt_type AS 約收類別
FROM kcsd.kc_apptschedule AS kc_apptschedule
LEFT JOIN kcsd.Delegate ON kc_apptschedule.kc_pusher_code = Delegate.DelegateCode
LEFT JOIN kcsd.v_Employee ON kc_apptschedule.kc_sales_code = v_Employee.EmpCode
INNER JOIN kcsd.kc_customerloan AS kc_customerloan ON kc_apptschedule.kc_case_no = kc_customerloan.kc_case_no
LEFT JOIN kcsd.kct_addresstype AS kct_addresstype ON kc_apptschedule.kc_addr_type = kct_addresstype.kc_addr_type
LEFT JOIN kcsd.kct_appttype AS kct_appttype ON kc_apptschedule.kc_appt_type = kct_appttype.kc_appt_type
WHERE kc_apptschedule.kc_appt_date Between @wk_strt_date And @wk_stop_date
AND kc_apptschedule.kc_visit_date Between @wk_strt_date2 And @wk_stop_date2
ORDER BY kc_apptschedule.kc_appt_date, kc_apptschedule.kc_visit_date, kc_apptschedule.kc_case_no;

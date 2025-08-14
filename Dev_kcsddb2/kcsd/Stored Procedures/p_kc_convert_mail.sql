CREATE PROCEDURE [kcsd].[p_kc_convert_mail] @wk_strt_date datetime,@wk_stop_date datetime,@wk_law_code VARCHAR(1),@wk_law_fmt VARCHAR(2)
AS

SELECT
A.kc_case_no AS 客戶編號,
A.kc_law_date AS 登記日期,
A.kc_law_code AS 催告代碼,
A.kc_law_fmt AS 催告格式,
B.kc_cust_nameu AS 客戶姓名,
B.kc_cust_name1u AS 保人1姓名,
B.kc_cust_name2u AS 保人2姓名,
D.kc_court_name AS 法院名稱,
A.kc_doc_date AS 公文日,
A.kc_perm_flag AS 本人戶,
A.kc_curr_flag AS 本人聯,
A.kc_comp_flag AS 本人公,
A.kc_bill_flag AS 本人帳,
A.kc_perm_flag1 AS 保一戶,
A.kc_curr_flag1 AS 保一聯,
A.kc_comp_flag1 AS 保一公,
A.kc_perm_flag2 AS 保二戶,
A.kc_curr_flag2 AS 保二聯,
A.kc_comp_flag2 AS 保二公,
A.kc_send_flag AS 完成,
A.kc_law_amt AS 金額,
B.kc_pusher_code AS 委派,
B.kc_boro_stat+E.kc_boro_desc AS 契約狀態,
C.MaxPayDate AS 最後繳款日

FROM
kcsd.kc_lawstatus A
LEFT JOIN kcsd.kc_customerloan B ON A.kc_case_no = B.kc_case_no
LEFT JOIN (SELECT kc_case_no,MAX(kc_pay_date) AS MaxPayDate FROM kcsd.kc_loanpayment GROUP BY kc_case_no) C ON A.kc_case_no = C.kc_case_no
LEFT JOIN kcsd.kct_court D ON A.kc_court_code = D.kc_court_code
LEFT JOIN kcsd.kct_bookstatus E ON B.kc_boro_stat = E.kc_boro_stat
WHERE
A.kc_law_date BETWEEN @wk_strt_date AND @wk_stop_date AND A.kc_law_code = @wk_law_code AND ((A.kc_law_fmt = @wk_law_fmt) OR (@wk_law_fmt = ''))
ORDER BY 
A.kc_law_date, A.kc_case_no;

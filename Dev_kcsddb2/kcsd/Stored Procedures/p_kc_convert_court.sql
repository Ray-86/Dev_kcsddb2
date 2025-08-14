CREATE PROCEDURE [kcsd].[p_kc_convert_court] @wk_strt_date datetime,@wk_stop_date datetime
AS

SELECT 
A.kc_case_no AS 客戶編號,
A.kc_doc_date AS 開庭日期,
D.kc_cust_nameu AS 本人姓名,
D.kc_cust_name1u AS 保一姓名,
D.kc_cust_name2u AS 保二姓名,
A.kc_court_code + E.kc_court_name AS 法院,
D.kc_push_memo3 AS 催收註記,
D.kc_pusher_code AS 承辦人,
D.kc_boro_stat + G.kc_boro_desc AS 契約狀態,
F.MaxPayDate AS 最後繳款日,
A.kc_comp_date AS 完成日期,
A.kc_send_flag AS 完成

FROM kcsd.kc_lawStatus AS A
LEFT JOIN kcsd.kc_lawcode AS B ON A.kc_law_code = B.kc_law_code
LEFT JOIN kcsd.kct_lawformat AS C ON A.kc_law_fmt = C.kc_law_fmt
INNER JOIN kcsd.kc_customerloan AS D ON A.kc_case_no = D.kc_case_no
LEFT JOIN kcsd.kct_court AS E ON A.kc_court_code = E.kc_court_code
LEFT JOIN (SELECT kc_case_no,MAX(kc_pay_date) AS MaxPayDate FROM kcsd.kc_loanpayment GROUP BY kc_case_no) AS F ON A.kc_case_no = F.kc_case_no
LEFT JOIN kcsd.kct_bookstatus AS G ON D.kc_boro_stat = G.kc_boro_stat
WHERE A.kc_doc_date BETWEEN @wk_strt_date AND @wk_stop_date AND A.kc_law_code = 'A' AND A.kc_law_fmt IN ('XB','XH')
ORDER BY A.kc_doc_date,A.kc_case_no

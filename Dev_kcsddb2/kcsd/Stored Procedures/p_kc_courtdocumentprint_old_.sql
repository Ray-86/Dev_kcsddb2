

CREATE PROCEDURE [kcsd].[p_kc_courtdocumentprint(old)] @wk_strt_date datetime,@wk_stop_date datetime,@wk_law_code VARCHAR(1),@wk_law_fmt VARCHAR(2)
AS

SELECT
A.kc_law_date AS 登記日期,
A.kc_case_no AS 客戶編號,
B.kc_cust_nameu AS 客戶姓名,
D.kc_brand_desc AS 廠牌,
B.kc_car_model AS 機型,
B.kc_licn_no AS 牌照號碼,
B.kc_eng_no AS 引擎號碼,
B.kc_rema_amt AS 未繳餘額,
CASE WHEN B.kc_break_amt2 >0 AND B.kc_break_amt2 < 200 THEN 200 ELSE B.kc_break_amt2 END AS 違約金,
B.kc_rema_amt+B.kc_break_amt2 AS 清償金額,
--A.kc_perm_flag,
--A.kc_curr_flag,
--A.kc_comp_flag,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y' THEN B.kc_cust_nameu ELSE '' END AS 姓名,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date),A.kc_law_date) < 0 THEN '法定代理人：'+B.kc_papa_nameu+'、'+B.kc_mama_nameu  ELSE '' END ELSE '' END AS 本人未成年,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 性別,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 先生女士,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y' THEN B.kc_id_no ELSE '' END AS 本人身份證號,
CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_birth_date ELSE NULL END AS 生日,
B.kc_mobil_no AS 本人行動,
CASE WHEN A.kc_comp_flag = 'Y' THEN B.kc_comp_namea ELSE '' END AS 公司名稱,
CASE WHEN A.kc_comp_flag = 'Y' THEN B.kc_job_title ELSE '' END AS 職稱,
CASE WHEN A.kc_comp_flag = 'Y' OR A.kc_perm_flag = 'Y' THEN B.kc_perm_zip ELSE '' END AS 本人戶籍地址ZIP,
CASE WHEN A.kc_comp_flag = 'Y' OR A.kc_perm_flag = 'Y' THEN B.kc_perm_addr ELSE '' END AS 本人戶籍地址,
CASE WHEN A.kc_curr_flag = 'Y' THEN B.kc_curr_zip ELSE '' END AS 本人聯絡地址ZIP,
CASE WHEN A.kc_curr_flag = 'Y' THEN B.kc_curr_addr ELSE '' END AS 本人聯絡地址,
CASE WHEN A.kc_comp_flag = 'Y' THEN B.kc_comp_zip ELSE '' END AS 本人公司地址ZIP,
CASE WHEN A.kc_comp_flag = 'Y' THEN B.kc_comp_addr ELSE '' END AS 本人公司地址,
--A.kc_perm_flag1,
--A.kc_curr_flag1,
--A.kc_comp_flag1,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_cust_name1u ELSE '' END AS 保人1姓名,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date1),A.kc_law_date) < 0 THEN '法定代理人：'+B.kc_papa_name1u+'、'+B.kc_mama_name1u  ELSE '' END ELSE '' END AS 保人1未成年,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no1,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 保人1性別,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no1,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 保人1先生女士,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_id_no1 ELSE '' END AS 保人1身份證號,
CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_birth_date1 ELSE NULL END AS 保人1生日,
CASE WHEN A.kc_comp_flag1 = 'Y' THEN B.kc_comp_namea1 ELSE '' END AS 保人1公司名稱,
CASE WHEN A.kc_comp_flag1 = 'Y' THEN B.kc_job_title1 ELSE '' END AS 保人1職稱,
CASE WHEN A.kc_comp_flag1 = 'Y' OR A.kc_perm_flag1 = 'Y' THEN B.kc_perm_zip1 ELSE '' END AS 保人1戶籍地址ZIP,
CASE WHEN A.kc_comp_flag1 = 'Y' OR A.kc_perm_flag1 = 'Y' THEN B.kc_perm_addr1 ELSE '' END AS 保人1戶籍地址,
CASE WHEN A.kc_curr_flag1 = 'Y' THEN B.kc_curr_zip1 ELSE '' END AS 保人1聯絡地址ZIP,
CASE WHEN A.kc_curr_flag1 = 'Y' THEN B.kc_curr_addr1 ELSE '' END AS 保人1聯絡地址,
CASE WHEN A.kc_comp_flag1 = 'Y' THEN B.kc_comp_zip1 ELSE '' END AS 保人1公司地址ZIP,
CASE WHEN A.kc_comp_flag1 = 'Y' THEN B.kc_comp_addr1 ELSE '' END AS 保人1公司地址,
--A.kc_perm_flag2,
--A.kc_curr_flag2,
--A.kc_comp_flag2,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_cust_name2u ELSE '' END AS 保人2姓名,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date2),A.kc_law_date) < 0 THEN '法定代理人：'+B.kc_papa_name1u+'、'+B.kc_mama_name1u  ELSE '' END ELSE '' END AS 保人2未成年,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no2,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 保人2性別,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no2,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 保人2先生女士,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_id_no2 ELSE '' END AS 保人2身份證號,
CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_birth_date2 ELSE NULL END AS 保人2生日,
CASE WHEN A.kc_comp_flag2 = 'Y' THEN B.kc_comp_namea2 ELSE '' END AS 保人2公司名稱,
CASE WHEN A.kc_comp_flag2 = 'Y' THEN B.kc_job_title2 ELSE '' END AS 保人2職稱,
CASE WHEN A.kc_comp_flag2 = 'Y' OR A.kc_perm_flag2 = 'Y' THEN B.kc_perm_zip2 ELSE '' END AS 保人2戶籍地址ZIP,
CASE WHEN A.kc_comp_flag2 = 'Y' OR A.kc_perm_flag2 = 'Y' THEN B.kc_perm_addr2 ELSE '' END AS 保人2戶籍地址,
CASE WHEN A.kc_curr_flag2 = 'Y' THEN B.kc_curr_zip2 ELSE '' END AS 保人2聯絡地址ZIP,
CASE WHEN A.kc_curr_flag2 = 'Y' THEN B.kc_curr_addr2 ELSE '' END AS 保人2聯絡地址,
CASE WHEN A.kc_comp_flag2 = 'Y' THEN B.kc_comp_zip2 ELSE '' END AS 保人2公司地址ZIP,
CASE WHEN A.kc_comp_flag2 = 'Y' THEN B.kc_comp_addr2 ELSE '' END AS 保人2公司地址,
--A.kc_bill_flag, 
CASE WHEN A.kc_bill_flag = 'Y' THEN B.kc_zip_code ELSE '' END AS 帳單地址ZIP,
CASE WHEN A.kc_bill_flag = 'Y' THEN B.kc_bill_addr ELSE '' END AS 帳單地址,
B.kc_buy_date AS 購買日期,
B.kc_licn_date AS 發照日期,
B.kc_loan_perd AS 期數,
B.kc_strt_date AS 起始日期,
DatePart(DAY,B.kc_strt_date) AS 每月繳款日,
B.kc_perd_fee*B.kc_loan_perd AS 本票金額,
B.kc_perd_fee AS 期付金額,
--B.kc_over_amt AS 逾期金額,
--B.kc_dday_date AS 逾期日期,
--B.kc_over_count AS 逾期期數,
--B.kc_over_amt+B.kc_break_amt2 AS 合計逾期金額,
DateAdd(DAY,5,A.kc_law_date) AS 登記日後5天,
--DateAdd("d",15,A.kc_law_date) AS 登記日後15天,
--kct_mailtype.kc_mail_desc AS 郵寄方式,
A.kc_doc_no AS 法院案號,
A.kc_doc_type AS 股別,
E.kc_court_name AS 法院名稱,
F.kc_area_desc AS 分公司,
G.EmpName AS 承辦人,
B.kc_pusher_code AS 催款,
B.kc_claims_amt AS 債權金額,
B.kc_value_date AS 起息日,
A.kc_law_amt AS 金額,
M.kc_doc_no AS 前案號,
M.kc_doc_type AS 前股別,
N.kc_court_name AS 前法院,
H.kc_issu_desc AS 債權人,
I.kc_lawagents_name AS 法定代理人,
J.kc_rate_name AS 利率,
CASE WHEN A.kc_law_code = 'C' AND (A.kc_law_fmt = 'CA' OR A.kc_law_fmt = 'CB' OR A.kc_law_fmt = 'CC' OR A.kc_law_fmt = 'CD' OR A.kc_law_fmt = 'CE' OR A.kc_law_fmt = 'CJ') THEN ISNULL(Q.[text],'')+CASE WHEN O.kc_doc_no IS NOT NULL AND O.kc_court_code IS NOT NULL THEN '(前案'+CONVERT(nvarchar(5),P.kc_court_name)+'法院'+CONVERT(nvarchar(20),O.kc_doc_no)+'受償'+CONVERT(nvarchar(10),A.kc_law_amt)+'元)' ELSE '' END ELSE '' END AS 代查受償,
K.kc_uniform_no AS 統編,
L.ContactName AS 承辦,
L.ContactData AS 電話,
FLOOR(B.kc_claims_amt + ROUND((B.kc_claims_amt*J.kc_rate_name*0.01/365)*(DATEDIFF(DAY,B.kc_value_date,A.kc_law_date)+1),0)) AS 債權計算,
CASE WHEN ISNULL(C.kc_finsu_date,0)=0 THEN CASE WHEN (DateDiff(day,DateAdd(year,20,B.kc_birth_date),B.kc_buy_date)<0) AND (A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date1),B.kc_buy_date)<0) AND (A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date2),B.kc_buy_date)<0) AND (A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y') THEN '、法定代理人同意書' ELSE '' END ELSE CASE WHEN (DateDiff(day,DateAdd(year,20,B.kc_birth_date),C.kc_finsu_date)<0) AND (A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date1),C.kc_finsu_date)<0) AND (A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date2),C.kc_finsu_date)<0) AND (A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y') THEN '、法定代理人同意書' ELSE '' END END AS 同意書,
K.kc_issu_desc AS 公司別,
K.kc_acct_no AS 轉帳帳號,
K.kc_boss_name AS 負責人,
K.kc_id_no AS 負責人ID,
L.ContactData2 AS 承辦電話2,
K.kc_atm_no + CASE WHEN ISNUMERIC(B.kc_case_no)=1 THEN B.kc_case_no ELSE '0'+RIGHT(B.kc_case_no,6) END AS ATM帳號,
A.kc_law_code AS 代碼,
A.kc_law_fmt AS 格式

FROM
kcsd.kc_lawstatus A
LEFT JOIN kcsd.kc_customerloan B ON A.kc_case_no = B.kc_case_no
LEFT JOIN kcsd.kc_customerloan1 C ON A.kc_case_no = C.kc_case_no
LEFT JOIN kcsd.kc_carbrand D ON B.kc_car_brand = D.kc_car_brand
LEFT JOIN kcsd.kct_court E ON A.kc_court_code = E.kc_court_code
LEFT JOIN kcsd.kct_area F ON B.kc_area_code = F.kc_area_code
LEFT JOIN kcsd.v_Employee G ON B.kc_sales_code = G.EmpCode
LEFT JOIN kcsd.kct_issuecompany H ON B.kc_creditor_name = H.kc_issu_code
LEFT JOIN kcsd.kct_lawagents I ON B.kc_lawagents_code = I.kc_lawagents_code
LEFT JOIN kcsd.kct_lawrate J ON B.kc_rate_fee = J.kc_rate_code
LEFT JOIN kcsd.kct_issuecompany K ON B.kc_issu_code = K.kc_issu_code
LEFT JOIN kcsd.Delegate L ON B.kc_pusher_code = L.DelegateCode
LEFT JOIN (SELECT l.kc_case_no,l.kc_law_date,l.kc_law_code,l.kc_law_fmt,l.kc_doc_no,l.kc_doc_type,l.kc_court_code FROM kcsd.kc_lawstatus AS l INNER JOIN (SELECT kc_case_no,MAX(kc_item_no) AS kc_item_no FROM kcsd.kc_lawstatus WHERE kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND kc_law_fmt IN('C6','X2','XA','XC','XF') GROUP BY kc_case_no) AS A ON A.kc_case_no = l.kc_case_no AND A.kc_item_no = l.kc_item_no WHERE l.kc_doc_no IS NOT NULL AND l.kc_court_code IS NOT NULL AND l.kc_law_fmt IN('C6','X2','XA','XC','XF')) AS M ON B.kc_case_no = M.kc_case_no
LEFT JOIN kcsd.kct_court N ON M.kc_court_code = N.kc_court_code
LEFT JOIN (SELECT l.kc_case_no,l.kc_law_date,l.kc_law_code,l.kc_law_fmt,l.kc_doc_no,l.kc_doc_type,l.kc_court_code FROM kcsd.kc_lawstatus AS l INNER JOIN (SELECT kc_case_no,MAX(kc_item_no) AS kc_item_no FROM kcsd.kc_lawstatus WHERE kc_law_code = 'A' AND kc_law_fmt IN('X5','X6') GROUP BY kc_case_no) AS A ON A.kc_case_no = l.kc_case_no AND A.kc_item_no = l.kc_item_no WHERE l.kc_law_code = 'A' AND l.kc_law_fmt IN('X5','X6')) AS O ON B.kc_case_no = O.kc_case_no
LEFT JOIN kcsd.kct_court P ON O.kc_court_code = P.kc_court_code
LEFT JOIN (SELECT kc_case_no,'並賠償執行費及程序費用。' AS text FROM kcsd.kc_customerloan WHERE kc_oriclaims_amt = kc_claims_amt AND kc_orivalue_date = kc_value_date) AS Q ON B.kc_case_no = Q.kc_case_no

WHERE A.kc_law_date BETWEEN @wk_strt_date AND @wk_stop_date AND A.kc_law_code = @wk_law_code AND ((A.kc_law_fmt = @wk_law_fmt) OR (@wk_law_fmt = ''))

order by A.kc_case_no,A.kc_law_code



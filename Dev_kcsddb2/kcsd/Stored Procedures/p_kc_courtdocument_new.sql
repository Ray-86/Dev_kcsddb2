


CREATE PROCEDURE [kcsd].[p_kc_courtdocument_new] @wk_strt_date datetime,@wk_stop_date datetime,@wk_law_code VARCHAR(1),@wk_law_fmt VARCHAR(2),@wk_print_type VARCHAR(1) = NULL,@wk_case_no VARCHAR(10) = NULL
AS

SELECT A.*,
CASE WHEN A.本人未成年 = 1 AND A.本人配偶 = '' THEN CASE WHEN A.本人法代 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.本人法代 + ' 住：' + A.本人戶籍地址 ELSE (CASE WHEN A.本人父親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.本人父親 + ' 住：' + A.本人戶籍地址 ELSE '' END + CHAR(10) + CHAR(13) + CASE WHEN A.本人母親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.本人母親 + ' 住：' + A.本人戶籍地址 ELSE '' END) END ELSE '' END AS 本人法定代理人,
CASE WHEN A.保一未成年 = 1 AND A.保一配偶 = '' THEN CASE WHEN A.保一法代 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保一法代 + ' 住：' + A.保一戶籍地址 ELSE (CASE WHEN A.保一父親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保一父親 + ' 住：' + A.保一戶籍地址 ELSE '' END + CHAR(10) + CHAR(13) + CASE WHEN A.保一母親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保一母親 + ' 住：' + A.保一戶籍地址 ELSE '' END) END ELSE '' END AS 保一法定代理人,
CASE WHEN A.保二未成年 = 1 AND A.保二配偶 = '' THEN CASE WHEN A.保二法代 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保二法代 + ' 住：' + A.保二戶籍地址 ELSE (CASE WHEN A.保二父親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保二父親 + ' 住：' + A.保二戶籍地址 ELSE '' END + CHAR(10) + CHAR(13) + CASE WHEN A.保二母親 <> '' THEN CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + CHAR(32) + '法定代理人：' + A.保二母親 + ' 住：' + A.保二戶籍地址 ELSE '' END) END ELSE '' END AS 保二法定代理人,
B.Text AS 法院名稱, 
C.Text AS 前案法院名稱, 
D.Text AS 前案號法院名稱, 
CASE WHEN A.前案號法院代號 <> '' AND A.前案號法院案號 <> '' THEN '(前案' + D.Text + '法院' + A.前案號法院案號 + '受償' + CONVERT(varchar(10),A.金額) + '元)' ELSE '' END AS 代查受償2
FROM 
(
	SELECT
	A.kc_law_date AS 登記日期,
	A.kc_case_no AS 客戶編號,
	B.kc_cust_nameu AS 客戶姓名,
	A.kc_law_code AS 催告代碼,
	A.kc_law_fmt AS 催告格式,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_cust_nameu ELSE '' END AS 本人姓名,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_id_no ELSE '' END AS 本人身分證號,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_birth_date ELSE NULL END AS 本人生日,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 本人性別,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 本人先生女士,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date),A.kc_law_date) < 0 THEN 1 ELSE 0 END ELSE 0 END AS 本人未成年,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN ISNULL(B.kc_papa_nameu,'') ELSE '' END AS 本人父親,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN ISNULL(B.kc_mama_nameu,'') ELSE '' END AS 本人母親,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN ISNULL(B.kc_mate_nameu,'') ELSE '' END AS 本人配偶,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN ISNULL(B.kc_legal_agent,'') ELSE '' END AS 本人法代,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_mobil_no ELSE '' END AS 本人行動,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_comp_namea ELSE '' END AS 本人公司名稱,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_job_title ELSE '' END AS 本人職稱,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_perm_zip ELSE '' END AS 本人戶籍地址郵遞區號,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_perm_addr ELSE '' END AS 本人戶籍地址,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_curr_zip ELSE '' END AS 本人聯絡地址郵遞區號,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_curr_addr ELSE '' END AS 本人聯絡地址,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_comp_zip ELSE '' END AS 本人公司地址郵遞區號,
	CASE WHEN A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' THEN B.kc_comp_addr ELSE '' END AS 本人公司地址,

	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_cust_name1u ELSE '' END AS 保一姓名,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_id_no1 ELSE '' END AS 保一身分證號,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_birth_date1 ELSE NULL END AS 保一生日,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no1,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 保一性別,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no1,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 保一先生女士,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date1),A.kc_law_date) < 0 THEN 1 ELSE 0 END ELSE 0 END AS 保一未成年,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN ISNULL(B.kc_papa_name1u,'') ELSE '' END AS 保一父親,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN ISNULL(B.kc_mama_name1u,'') ELSE '' END AS 保一母親,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN ISNULL(B.kc_mate_name1u,'') ELSE '' END AS 保一配偶,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN ISNULL(B.kc_legal_agent1,'') ELSE '' END AS 保一法代,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_mobil_no1 ELSE '' END AS 保一行動,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_comp_namea1 ELSE '' END AS 保一公司名稱,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_job_title1 ELSE '' END AS 保一職稱,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_perm_zip1 ELSE '' END AS 保一戶籍地址郵遞區號,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_perm_addr1 ELSE '' END AS 保一戶籍地址,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_curr_zip1 ELSE '' END AS 保一聯絡地址郵遞區號,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_curr_addr1 ELSE '' END AS 保一聯絡地址,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_comp_zip1 ELSE '' END AS 保一公司地址郵遞區號,
	CASE WHEN A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y' THEN B.kc_comp_addr1 ELSE '' END AS 保一公司地址,

	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_cust_name2u ELSE '' END AS 保二姓名,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_id_no2 ELSE '' END AS 保二身分證號,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_birth_date2 ELSE NULL END AS 保二生日,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no2,2,1)='2' THEN '女' ELSE '男' END ELSE '' END AS 保二性別,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN SUBSTRING(B.kc_id_no2,2,1)='2' THEN '女士' ELSE '先生' END ELSE '' END AS 保二先生女士,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN CASE WHEN DATEDIFF(DAY,DATEADD(YEAR,20,B.kc_birth_date2),A.kc_law_date) < 0 THEN 1 ELSE 0 END ELSE 0 END AS 保二未成年,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN ISNULL(B.kc_papa_name2u,'') ELSE '' END AS 保二父親,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN ISNULL(B.kc_mama_name2u,'') ELSE '' END AS 保二母親,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN ISNULL(B.kc_mate_name2u,'') ELSE '' END AS 保二配偶,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN ISNULL(B.kc_legal_agent2,'') ELSE '' END AS 保二法代,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_mobil_no2 ELSE '' END AS 保二行動,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_comp_namea2 ELSE '' END AS 保二公司名稱,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_job_title2 ELSE '' END AS 保二職稱,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_perm_zip2 ELSE '' END AS 保二戶籍地址郵遞區號,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_perm_addr2 ELSE '' END AS 保二戶籍地址,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_curr_zip2 ELSE '' END AS 保二聯絡地址郵遞區號,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_curr_addr2 ELSE '' END AS 保二聯絡地址,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_comp_zip2 ELSE '' END AS 保二公司地址郵遞區號,
	CASE WHEN A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y' THEN B.kc_comp_addr2 ELSE '' END AS 保二公司地址,

	B.kc_buy_date AS 建檔日期,
	C.kc_finsu_date AS 契約日期,
	B.kc_licn_date AS 發照日期,
	B.kc_car_brand AS 廠牌代號,
	B.kc_car_model AS 機型,
	B.kc_licn_no AS 牌照號碼,
	B.kc_eng_no AS 引擎號碼,
	B.kc_loan_perd AS 期數,
	B.kc_strt_date AS 起始日期,
	DatePart(DAY,B.kc_strt_date) AS 每月繳款日,
	B.kc_perd_fee*B.kc_loan_perd AS 本票金額,
	B.kc_perd_fee AS 期付金額,
	DateAdd(DAY,5,A.kc_law_date) AS 登記日後5天,
	A.kc_court_code AS 法院代號,
	A.kc_doc_no AS 法院案號,
	A.kc_doc_type AS 法院股別,
	(SELECT TOP 1 kc_court_code FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND ((A.kc_perm_flag IS NULL OR kc_perm_flag = A.kc_perm_flag) AND (A.kc_perm_flag1 IS NULL OR kc_perm_flag1 = A.kc_perm_flag1) AND (A.kc_perm_flag2 IS NULL OR kc_perm_flag2 = A.kc_perm_flag2)) AND kc_law_fmt IN ('C6','X2','XA','XC','XF') ORDER BY kc_law_date DESC) AS 前案法院代號,
	(SELECT TOP 1 kc_doc_no FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND ((A.kc_perm_flag IS NULL OR kc_perm_flag = A.kc_perm_flag) AND (A.kc_perm_flag1 IS NULL OR kc_perm_flag1 = A.kc_perm_flag1) AND (A.kc_perm_flag2 IS NULL OR kc_perm_flag2 = A.kc_perm_flag2)) AND kc_law_fmt IN ('C6','X2','XA','XC','XF') ORDER BY kc_law_date DESC) AS 前案法院案號,
	(SELECT TOP 1 kc_doc_type FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND ((A.kc_perm_flag IS NULL OR kc_perm_flag = A.kc_perm_flag) AND (A.kc_perm_flag1 IS NULL OR kc_perm_flag1 = A.kc_perm_flag1) AND (A.kc_perm_flag2 IS NULL OR kc_perm_flag2 = A.kc_perm_flag2)) AND kc_law_fmt IN ('C6','X2','XA','XC','XF') ORDER BY kc_law_date DESC) AS 前案法院股別,
	A.kc_claims_amt AS 債權金額,
	A.kc_value_date AS 起息日,
	A.kc_rate_fee AS 利率,
	FLOOR(A.kc_claims_amt + ROUND((A.kc_claims_amt*A.kc_rate_fee*0.01/365)*(DATEDIFF(DAY,A.kc_value_date,A.kc_law_date)+1),0)) AS 債權計算,
	E.kc_atm_no + CASE WHEN ISNUMERIC(B.kc_case_no)=1 THEN B.kc_case_no ELSE '0'+RIGHT(B.kc_case_no,6) END AS ATM帳號,
	B.kc_pusher_code AS 委派人員,
	F.ContactName AS 承辦人員,
	F.ContactData AS 承辦電話,
	F.ContactData2 AS 承辦電話2,
	B.kc_area_code AS 分公司代號,
	D.kc_area_desc AS 分公司名稱,
	B.kc_issu_code AS 公司別代號,
	E.kc_issu_desc AS 債權人,
	E.kc_issu_addr AS 地址,
	E.kc_boss_name AS 法定代理人,
	E.kc_uniform_no AS 統一編號,
	A.kc_law_amt AS 金額,
	A.kc_litigation_amt AS 程序費,
	A.kc_litigation_amt1 AS 執行費,
	(select kc_expt_date from kcsd.kc_loanpayment l where kc_perd_no = 1 and l.kc_case_no = B.kc_case_no) as 第一期,
	(SELECT TOP 1 kc_court_code FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND (kc_perm_flag = A.kc_perm_flag OR kc_perm_flag1 = A.kc_perm_flag1 OR kc_perm_flag2 = A.kc_perm_flag2) AND kc_law_code+kc_law_fmt IN ('AX5','AX6') ORDER BY kc_law_date DESC) AS 前案號法院代號,
	(SELECT TOP 1 kc_doc_no FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND kc_doc_no IS NOT NULL AND kc_court_code IS NOT NULL AND (kc_perm_flag = A.kc_perm_flag OR kc_perm_flag1 = A.kc_perm_flag1 OR kc_perm_flag2 = A.kc_perm_flag2) AND kc_law_code+kc_law_fmt IN ('AX5','AX6') ORDER BY kc_law_date DESC) AS 前案號法院案號,
	CASE WHEN ISNULL(C.kc_finsu_date,0)=0 THEN 
	CASE WHEN (DateDiff(day,DateAdd(year,20,B.kc_birth_date),B.kc_buy_date)<0) AND (A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date1),B.kc_buy_date)<0) AND (A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date2),B.kc_buy_date)<0) AND (A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y') THEN '、法定代理人同意書' ELSE '。' END 
	ELSE CASE WHEN (DateDiff(day,DateAdd(year,20,B.kc_birth_date),C.kc_finsu_date)<0) AND (A.kc_perm_flag = 'Y' OR A.kc_curr_flag = 'Y' OR A.kc_comp_flag = 'Y' OR A.kc_bill_flag = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date1),C.kc_finsu_date)<0) AND (A.kc_perm_flag1 = 'Y' OR A.kc_curr_flag1 = 'Y' OR A.kc_comp_flag1 = 'Y') OR (DateDiff(day,DateAdd(year,20,B.kc_birth_date2),C.kc_finsu_date)<0) AND (A.kc_perm_flag2 = 'Y' OR A.kc_curr_flag2 = 'Y' OR A.kc_comp_flag2 = 'Y') THEN '、法定代理人同意書' ELSE '。' END END AS 同意書,

	CASE WHEN ((A.kc_litigation_amt <> 0 AND A.kc_litigation_amt IS NOT NULL) OR (A.kc_litigation_amt1 <> 0 AND A.kc_litigation_amt1 IS NOT NULL)) 
	THEN '並賠償' 
	+ CASE WHEN (A.kc_litigation_amt <> 0 AND A.kc_litigation_amt IS NOT NULL) THEN ('程序費' + CONVERT(varchar(10),ISNULL(A.kc_litigation_amt,0)) + '元') ELSE '' END
	+ CASE WHEN (A.kc_litigation_amt1 <> 0 AND A.kc_litigation_amt1 IS NOT NULL) THEN ('執行費' + CONVERT(varchar(10),ISNULL(A.kc_litigation_amt1,0)) + '元') ELSE '' END
	+ '。' 
	ELSE '' END AS 代查受償,
	(SELECT TOP 1 Replace(RTRIM(LTRIM(CASE WHEN a1.kc_perm_flag = 'Y' OR a1.kc_curr_flag = 'Y' OR a1.kc_comp_flag = 'Y' THEN a2.kc_cust_nameu ELSE '' END +' '+ CASE WHEN a1.kc_perm_flag1 = 'Y' OR a1.kc_curr_flag1 = 'Y' OR a1.kc_comp_flag1 = 'Y' THEN a2.kc_cust_name1u ELSE '' END +' '+ CASE WHEN a1.kc_perm_flag2 = 'Y' OR a1.kc_curr_flag2 = 'Y' OR a1.kc_comp_flag2 = 'Y' THEN a2.kc_cust_name2u ELSE '' END)),' ','、') AS 姓名 FROM kcsd.kc_lawstatus a1 left join kcsd.kc_customerloan a2 on a1.kc_case_no = a2.kc_case_no WHERE a1.kc_case_no = A.kc_case_no AND a1.kc_law_code+a1.kc_law_fmt IN ('GA7') and a1.kc_law_date<=A.kc_law_date ORDER BY a1.kc_law_date DESC) AS 前所清名單
	--,
	--CASE WHEN (SELECT TOP 1 kc_claims_amt FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND ((A.kc_perm_flag IS NULL OR kc_perm_flag = A.kc_perm_flag) AND (A.kc_perm_flag1 IS NULL OR kc_perm_flag1 = A.kc_perm_flag1) AND (A.kc_perm_flag2 IS NULL OR kc_perm_flag2 = A.kc_perm_flag2)) AND kc_law_code = 'C' AND kc_law_fmt IN ('C0','CF') ORDER BY kc_law_date) = A.kc_claims_amt 
	--AND (SELECT TOP 1 kc_value_date FROM kcsd.kc_lawstatus WHERE kc_case_no = A.kc_case_no AND ((A.kc_perm_flag IS NULL OR kc_perm_flag = A.kc_perm_flag) AND (A.kc_perm_flag1 IS NULL OR kc_perm_flag1 = A.kc_perm_flag1) AND (A.kc_perm_flag2 IS NULL OR kc_perm_flag2 = A.kc_perm_flag2)) AND kc_law_code = 'C' AND kc_law_fmt IN ('C0','CF') ORDER BY kc_law_date) = A.kc_value_date 
	--THEN ('並賠償執行費及程序費用。') ELSE '' END AS 代查受償1

	FROM
	kcsd.kc_lawstatus A
	LEFT JOIN kcsd.kc_customerloan B ON A.kc_case_no = B.kc_case_no
	LEFT JOIN kcsd.kc_customerloan1 C ON A.kc_case_no = C.kc_case_no
	LEFT JOIN kcsd.kct_area D ON B.kc_area_code = D.kc_area_code
	LEFT JOIN kcsd.kct_issuecompany E ON B.kc_issu_code = E.kc_issu_code
	LEFT JOIN kcsd.Delegate F ON B.kc_pusher_code = F.DelegateCode

	WHERE A.kc_law_date BETWEEN @wk_strt_date AND @wk_stop_date AND A.kc_law_code = @wk_law_code AND ((A.kc_law_fmt = @wk_law_fmt) OR (@wk_law_fmt = ''))
	AND ((@wk_print_type IS NOT NULL 
	AND ((@wk_print_type = 'Y' AND A.kc_court_code IN ('002','003','006','009','010','011','016','017','020','021','022')) 
	OR (@wk_print_type = 'N' AND A.kc_court_code IN ('001','004','005','007','008','013','014','015','018','019','023')))) 
	OR @wk_print_type IS NULL)
	AND (isnull(@wk_case_no, '') = '' OR A.kc_case_no = isnull(@wk_case_no, ''))
) AS A
LEFT JOIN (SELECT Value, Text FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'CourtCode') AS B ON A.法院代號 = B.Value
LEFT JOIN (SELECT Value, Text FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'CourtCode') AS C ON A.前案法院代號 = C.Value
LEFT JOIN (SELECT Value, Text FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'CourtCode') AS D ON A.前案號法院代號 = D.Value
ORDER BY A.客戶編號






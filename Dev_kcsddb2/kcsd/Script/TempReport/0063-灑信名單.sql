-- 客編, 逾期時間, 最後一次繳款時間, 本/保1/保2, 戶籍地址, ID狀態, 委派代號, 委派分類

DROP TABLE #TB
DROP TABLE #ID
DROP TABLE #CU


CREATE TABLE  #TB ( 客編 varchar(20), 最早應繳日 Date, 最後繳費日 Date, 委派代號 varchar(10), 委派分類 nvarchar(20),
                                        本人姓名 nvarchar(20), 本人身分證字號 varchar(20), 本人狀態 varchar(10), 本人戶籍 nvarchar(100),
                                        保1姓名 nvarchar(20), 保1身分證字號 varchar(20), 保1狀態 varchar(10), 保1戶籍 nvarchar(100),
                                        保2姓名 nvarchar(20), 保2身分證字號 varchar(20), 保2狀態 varchar(10), 保2戶籍 nvarchar(100))
CREATE TABLE  #ID (身分證字號 varchar(20))
CREATE TABLE  #CU (客編 varchar(20))
INSERT INTO #TB
SELECT *
FROM
(	
	SELECT kc_case_no'客編',
				  (SELECT MIN(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no=C.kc_case_no AND kc_expt_date<=GETDATE() AND kc_pay_date IS NULL)'最早應繳日',
				  (SELECT MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no=C.kc_case_no)'最後繳費日',
				  kc_pusher_code'委派代號',
				  kc_push_sort+' '+SC.[Text]'委派分類',
				  kc_cust_nameu, kc_id_no, kc_cust_stat, kc_perm_addr,
				  kc_cust_name1u, kc_id_no1, kc_cust_stat1, kc_perm_addr1,
				  kc_cust_name2u, kc_id_no2, kc_cust_stat2, kc_perm_addr2
	FROM kcsd.kc_customerloan C
	LEFT JOIN [Zephyr.Sys].dbo.sys_code SC ON  CodeType='PushSort' AND C.kc_push_sort=SC.[Value]
	WHERE kc_pusher_code IN ('L01','L02','L03','L05','L06','L07','L09','L12','LA','LH','LF')
	     AND kc_push_sort NOT IN ('X1', 'J2', 'I1', 'I2', 'J3', 'J4', 'E7' , 'F2', 'F3','E4','E6', 'G3', 'C3' )
)AS D
WHERE DATEDIFF(MONTH, D.最早應繳日, GETDATE()) >=18
     AND (D.最後繳費日 IS NULL OR DATEDIFF(MONTH, D.最後繳費日, GETDATE()) >= 6 )
--ORDER BY 客編


INSERT INTO #ID
SELECT DISTINCT 本人身分證字號 FROM #TB


INSERT INTO #CU
SELECT A.客編
FROM
(
    SELECT
        T.本人身分證字號,
        T.客編,
        ROW_NUMBER() OVER(PARTITION BY T.本人身分證字號 ORDER BY T.客編 DESC) AS rn
    FROM #TB T
    LEFT JOIN #ID I ON T.本人身分證字號 = I.身分證字號
) AS A
WHERE A.rn = 1;
    

SELECT 客編, 身份, 姓名, 身分證字號, ISNULL(狀態,'')'狀態', 戶籍, 最早應繳日, 最後繳費日, 委派代號, 委派分類
FROM
(
	--戶籍限制, ID狀態
	SELECT  C.客編,'1' '順序', '本人' '身份', 本人姓名'姓名', 本人身分證字號'身分證字號', 本人狀態+' '+SC.[Text] '狀態', 本人戶籍'戶籍', 最早應繳日, 最後繳費日, 委派代號, 委派分類
	FROM #CU C
	LEFT JOIN #TB T ON C.客編=T.客編
	LEFT JOIN [Zephyr.Sys].dbo.sys_code SC ON CodeType='CustStatus' AND T.本人狀態=SC.[Value]
	WHERE 本人狀態 NOT IN ('B', 'C', 'D')

	UNION

	SELECT  C.客編, '2' '順序', '保1' '身份', 保1姓名'姓名', 保1身分證字號'身分證字號', 保1狀態+' '+SC.[Text] '狀態', 保1戶籍'戶籍',最早應繳日, 最後繳費日, 委派代號, 委派分類
	FROM #CU C
	LEFT JOIN #TB T ON C.客編=T.客編
	LEFT JOIN [Zephyr.Sys].dbo.sys_code SC ON CodeType='CustStatus' AND T.保1狀態=SC.[Value]
	WHERE 保1狀態 NOT IN ('B', 'C', 'D')
		AND 保1姓名 IS NOT NULL

	UNION

	SELECT  C.客編,'3' '順序', '保2' '身份', 保2姓名'姓名', 保2身分證字號, 保2狀態+' '+SC.[Text] '狀態', 保2戶籍'戶籍', 最早應繳日, 最後繳費日, 委派代號, 委派分類
	FROM #CU C
	LEFT JOIN #TB T ON C.客編=T.客編
	LEFT JOIN [Zephyr.Sys].dbo.sys_code SC ON CodeType='CustStatus' AND T.保2狀態=SC.[Value]
	WHERE 保2狀態 NOT IN ('B', 'C', 'D')
		 AND 保2姓名 IS NOT NULL
) d
ORDER BY  d.客編, d.順序
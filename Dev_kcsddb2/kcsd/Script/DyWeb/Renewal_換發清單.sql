DECLARE @Type int =1 

IF @Type=1 --查詢債證
BEGIN
	SELECT A.kc_case_no, A.kc_cust_nameu, A.kc_cust_name1u, A.kc_cust_name2u,
				   A.kc_cust_stat, A.kc_cust_stat1, A.kc_cust_stat2, A.kc_perm_stat, A.kc_perm_stat1, A.kc_perm_stat2,
				   A.kc_perm_addr, A.kc_perm_addr1, A.kc_perm_addr2, B.kc_law_date,
				   A.kc_perm_addr_nt, A.kc_perm_addr1_nt, A.kc_perm_addr2_nt
	FROM kcsd.kc_customerloan A                                                                                                                                                                                                             
    LEFT JOIN (SELECT kc_case_no, Max(kc_doc_date) AS kc_law_date FROM kcsd.kc_lawstatus WHERE kc_law_fmt IN ('XA','C5','C6','CE','CQ') GROUP BY kc_case_no) B ON B.kc_case_no = A.kc_case_no
    LEFT JOIN (SELECT kc_case_no, Max(kc_law_date) AS kc_law_date FROM kcsd.kc_lawstatus WHERE kc_law_fmt IN ('XA','C6') GROUP BY kc_case_no) C ON C.kc_case_no = A.kc_case_no
    LEFT JOIN (SELECT kc_case_no, Max(kc_law_date) AS kc_law_date FROM kcsd.kc_lawstatus WHERE kc_law_fmt IN ('CE') AND kc_law_date BETWEEN DATEADD(MONTH, DATEDIFF(MONTH,0,GETDATE()), 0) AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0) GROUP BY kc_case_no) D ON D.kc_case_no = A.kc_case_no
    LEFT JOIN (SELECT kc_case_no, Max(kc_law_date) AS kc_law_date FROM kcsd.kc_lawstatus WHERE kc_law_fmt IN ('A7','A4','CA') AND kc_law_date BETWEEN DATEADD(MONTH, DATEDIFF(MONTH,0,GETDATE()), 0) AND GETDATE() GROUP BY kc_case_no) E ON E.kc_case_no = A.kc_case_no
    WHERE A.kc_area_code IN ('00','01','02','03','05','06','07','08','09','10','11','12','13','14','15','16','17','18')
	     AND A.kc_pusher_code LIKE 'L%'
		 AND A.kc_pusher_code NOT IN ('LB','LD')
		 AND A.kc_push_sort NOT IN ('C3','I2','F5')   
		 AND  (B.kc_law_date < DATEADD(YEAR,-2,GETDATE()) OR B.kc_law_date IS NULL) 
		 AND C.kc_law_date IS NOT NULL 
		 AND D.kc_law_date IS NULL 
		 AND E.kc_law_date IS NULL  
	ORDER BY B.kc_law_date

END
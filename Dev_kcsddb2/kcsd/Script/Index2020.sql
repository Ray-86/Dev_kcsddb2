DECLARE @wk_strt_date DATE ='2025-10-01',
                  @wk_stop_date DATE ='2025-10-31',
				  @wk_prod_type varchar(2)='',
				  @wk_delegate_code varchar(5)='P01',
				  @wk_citizenship_type varchar(1)=''

SELECT P.kc_pusher_code '委派代號', D.DelegateName'委派名稱',
       C.kc_case_no '客戶編號', C.kc_cust_nameu '姓名', P.kc_delay_code '帳齡', C.kc_loan_stat '回收狀態',
       CONVERT(varchar(10), P.kc_strt_date, 23) '委派日期', ISNULL(T1.委派金額,0)'委派金額' ,  
		ISNULL(CONVERT(varchar(10), P.kc_stop_date, 23),'') '停派日',  ISNULL(CONVERT(varchar(5),DATEDIFF(DAY, P.kc_strt_date, P.kc_stop_date)),'') '委派天數',
       ISNULL(T1.回收金額,0) '回收金額',  ISNULL(T1.回收違約金,0)'回收違約金',
       CASE WHEN ISNULL(T1.回收金額,0)>0 THEN 1 ELSE 0 END'回收件'
FROM kcsd.kc_pushassign P
LEFT JOIN kcsd.kc_customerloan C ON P.kc_case_no = C.kc_case_no
INNER JOIN kcsd.Delegate D ON P.kc_pusher_code=D.DelegateCode AND D.DelegateName LIKE '前催%' 
LEFT JOIN (
SELECT
	L.kc_case_no, P_sub.kc_pusher_code,
	SUM(L.kc_expt_fee)'委派金額',
        SUM(kc_pay_fee)'回收金額',
        SUM(kc_break_fee)'回收違約金'
    FROM kcsd.kc_loanpayment L
    INNER JOIN kcsd.kc_pushassign P_sub ON L.kc_case_no = P_sub.kc_case_no 
    WHERE L.kc_expt_date <= P_sub.kc_strt_date
      AND (L.kc_pay_date IS NULL OR L.kc_pay_date >= P_sub.kc_strt_date)
      AND P_sub.kc_strt_date BETWEEN @wk_strt_date AND @wk_stop_date 
    GROUP BY L.kc_case_no, P_sub.kc_pusher_code
) T1 ON P.kc_case_no = T1.kc_case_no AND P.kc_pusher_code=T1.kc_pusher_code 
WHERE ((CONVERT(Date,P.kc_strt_date) BETWEEN @wk_strt_date AND @wk_stop_date) OR (CONVERT(Date,P.kc_stop_date)BETWEEN @wk_strt_date AND @wk_stop_date) 
		OR (CONVERT(Date,P.kc_strt_date) < @wk_strt_date AND P.kc_stop_date IS NULL))
    AND (@wk_prod_type = '' OR C.kc_prod_type = @wk_prod_type)
    AND (@wk_delegate_code = '' OR P.kc_pusher_code = @wk_delegate_code)
    -- 國籍類型 空白
    AND (@wk_citizenship_type = ''        --本國人
        OR (@wk_citizenship_type = '1' AND SUBSTRING(C.kc_id_no, 2, 1) IN ('1', '2'))
        OR (@wk_citizenship_type = '2' AND SUBSTRING(C.kc_id_no, 2, 1) NOT IN ('1', '2'))) --外國人

	AND T1.委派金額 IS NOT NULL

ORDER BY 委派日期 ASC --, 停派日 ASC
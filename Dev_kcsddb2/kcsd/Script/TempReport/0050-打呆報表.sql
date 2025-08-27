DECLARE @wk_strt_date date = '2024-01-01',
                   @wk_stop_date date = '2024-03-31';


SELECT c.kc_case_no'客戶編號', CONVERT(Date,  l.kc_law_date)'債證日期', c.kc_rema_amt'目前未繳餘額', p.kc_yearlater_amt'年底後繳款',
               c.kc_rema_amt+p.kc_yearlater_amt as '預計呆帳金額',
			   x.kc_cert_cnt'債證檔案筆數', y.kc_all_cnt'全部檔案筆數',CONVERT(Date, y.kc_updt_date)'計算債證日期', q.wk_cap_remain'本金餘額'
			   --c.kc_idle_date, c.kc_idle_amt, c.kc_idle_type
FROM kcsd.kc_customerloan c
LEFT JOIN (SELECT kc_case_no,min(kc_doc_date) as kc_law_date FROM kcsd.kc_lawstatus WHERE kc_law_fmt In ('XA','C6','XU','CW') AND kc_doc_date BETWEEN @wk_strt_date AND @wk_stop_date group by kc_case_no) l on c.kc_case_no = l.kc_case_no
LEFT JOIN (SELECT kc_case_no,SUM(kc_pay_fee) as kc_yearlater_amt FROM kcsd.kc_loanpayment WHERE (kc_invo_date > @wk_stop_date or kc_invo_date Is Null) group by kc_case_no) p on c.kc_case_no = p.kc_case_no
LEFT JOIN (SELECT kc_case_no,count(*) as kc_cert_cnt ,min(kc_updt_date) as kc_updt_date FROM kcsd.kc_debtcertificate WHERE RIGHT(subdirectory,8) like '%A%' GROUP BY kc_case_no) x on c.kc_case_no = x.kc_case_no
LEFT JOIN (SELECT kc_case_no,count(*) as kc_all_cnt ,min(kc_updt_date) as kc_updt_date FROM kcsd.kc_debtcertificate GROUP BY kc_case_no) y on c.kc_case_no = y.kc_case_no
LEFT JOIN (SELECT kc_case_no,kc_loan_fee -ISNULL((SELECT Sum(p1.kc_pvpay_amt2) FROM kcsd.kc_customerloan c1 INNER JOIN kcsd.kc_loanpayment p1 ON c1.kc_case_no = p1.kc_case_no WHERE p1.kc_invo_date <= @wk_stop_date AND c1.kc_case_no = c.kc_case_no GROUP BY c1.kc_case_no),0) + c.kc_cred_fee + c.kc_rule_fee + c.kc_insu_sum as wk_cap_remain FROM kcsd.kc_customerloan c) q on c.kc_case_no = q.kc_case_no
WHERE c.kc_case_no not like '9%'
     AND c.kc_idle_date IS NULL
     AND c.kc_issu_code = '01' 
     AND c.kc_loan_stat not in ('C', 'E', 'X', 'Y', 'Z')
     AND EXISTS (
		SELECT 'x' 
		FROM kcsd.kc_lawstatus 
		WHERE kc_case_no = c.kc_case_no 
		     AND kc_law_fmt In('XA', 'C6','XU','CW') 
             AND kc_doc_date BETWEEN @wk_strt_date AND @wk_stop_date
     )
	 AND q.wk_cap_remain>0 --本金餘額>0
	 AND NOT EXISTS (  --未曾拉過D-T1 存證稅務
		SELECT *
		FROM kcsd.kc_lawstatus
		WHERE kc_case_no = c.kc_case_no
		AND kc_law_code='D'
		AND kc_law_fmt='T1'
	 )
ORDER BY c.kc_case_no
-- ==========================================================================================
-- 2016-12-20 取消估車條件 增加F估車逾期
-- 2016-12-07 估車條件
-- 2014-05-23 改寫
-- 2005-10-14 KC: 增加指定編號執行, 用來更新已結清的case
-- 2005-10-22 KC: 不管呆帳T
-- ==========================================================================================

CREATE        PROCEDURE [kcsd].[p_kc_updateloanstatus] @pm_case_no varchar(10)=NULL
AS
--Status: N: 新資料, C: 結案[待結案], D: 逾期, E: 逾期結清(末期逾期 >= 2 個月), F:估車逾期, G: 正常, X: 取消,P: 核准, R: 退件, S: 照會, T: 呆帳
IF (@pm_case_no = NULL)
BEGIN
	UPDATE kcsd.kc_customerloan SET kc_over_count = aa.逾期期數,kc_dday_date=aa.逾期日期,kc_dday_count=aa.逾期天數,kc_over_amt=aa.逾期金額,kc_pay_count=aa.實際繳款期數,kc_rema_amt=aa.未繳餘額,kc_break_amt2=aa.違約金,kc_loan_stat=aa.狀態 
	FROM kcsd.kc_customerloan,
	(
		SELECT aa.kc_case_no,aa.逾期期數,aa.逾期日期,aa.逾期天數,aa.逾期金額,aa.實際繳款期數,aa.未繳餘額,aa.違約金,aa.狀態
		FROM 
		(
			SELECT kc_case_no,
			c.kc_over_count,c.kc_dday_date,c.kc_dday_count,c.kc_over_amt,c.kc_pay_count,c.kc_rema_amt,c.kc_break_amt2,kc_loan_stat,
			--CASE WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE()) >0 THEN 'D' ELSE (CASE WHEN (SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) = 0  THEN (CASE WHEN (SELECT datediff(day,dateadd(mm,2,(SELECT min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no and kc_pay_date = (SELECT MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no))),MAX(kc_pay_date)) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no)=2 THEN 'E' ELSE 'C' END) ELSE 'G' END) END as 狀態,
			CASE 
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) = 0 
				THEN CASE WHEN (SELECT datediff(day,dateadd(mm,2,(SELECT min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no and kc_pay_date = (SELECT MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no))),MAX(kc_pay_date)) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no) >= 2 THEN 'E' ELSE 'C' END	
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_rece_code = 'A2') >0 THEN 'F' 
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE()) >0 THEN 'D' 
			WHEN (SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) <> 0 THEN 'G'
			ELSE 'D'
			END as 狀態,
			(SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期期數,
			(SELECT MIN(kc_expt_date)  FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期日期,
			(SELECT DATEDIFF(month,ISNULL(MIN(kc_expt_date),GETDATE()),GETDATE())  FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期天數,
			(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期金額,
			(SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL) AS 實際繳款期數,
			(SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) AS 未繳餘額,
			(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, getdate()) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE() AND kc_expt_fee > 0)+
			(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, kc_pay_date) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL AND kc_expt_date < kc_pay_date AND kc_expt_fee > 0) AS 違約金
			from kcsd.kc_customerloan c
			WHERE kc_loan_stat in ('N','G','D','F')
			GROUP BY c.kc_case_no,c.kc_over_count,c.kc_dday_date,c.kc_dday_count,c.kc_over_amt,c.kc_pay_count,c.kc_rema_amt,c.kc_break_amt2,kc_loan_stat
		) AS aa
		WHERE
		(aa.逾期期數<>aa.kc_over_count OR
		aa.逾期日期<>aa.kc_dday_date OR
		aa.逾期天數<>aa.kc_dday_count OR
		aa.逾期金額<>aa.kc_over_amt OR
		aa.實際繳款期數<>aa.kc_pay_count OR
		aa.未繳餘額<>aa.kc_rema_amt OR
		aa.違約金 <> aa.kc_break_amt2 OR
		aa.狀態 <> aa.kc_loan_stat)
	) AS AA
	WHERE kcsd.kc_customerloan.kc_case_no = AA.kc_case_no
END
ELSE
BEGIN
	UPDATE kcsd.kc_customerloan SET kc_over_count = aa.逾期期數,kc_dday_date=aa.逾期日期,kc_dday_count=aa.逾期天數,kc_over_amt=aa.逾期金額,kc_pay_count=aa.實際繳款期數,kc_rema_amt=aa.未繳餘額,kc_break_amt2=aa.違約金,kc_loan_stat=aa.狀態 
	FROM kcsd.kc_customerloan,
	(
		SELECT aa.kc_case_no,aa.逾期期數,aa.逾期日期,aa.逾期天數,aa.逾期金額,aa.實際繳款期數,aa.未繳餘額,aa.違約金,aa.狀態
		FROM 
		(
			SELECT kc_case_no,
			c.kc_over_count,c.kc_dday_date,c.kc_dday_count,c.kc_over_amt,c.kc_pay_count,c.kc_rema_amt,c.kc_break_amt2,kc_loan_stat,
			--CASE WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())  >0 THEN 'D' ELSE (CASE WHEN (SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) = 0  THEN (CASE WHEN (SELECT datediff(day,dateadd(mm,2,(SELECT min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no and kc_pay_date = (SELECT MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no))),MAX(kc_pay_date)) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no) >=2 THEN 'E' ELSE 'C' END) ELSE 'G' END) END as 狀態,
			CASE 
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) = 0 
				THEN CASE WHEN (SELECT datediff(day,dateadd(mm,2,(SELECT min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no and kc_pay_date = (SELECT MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no))),MAX(kc_pay_date)) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no) >= 2 THEN 'E' ELSE 'C' END	
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_rece_code = 'A2') >0 THEN 'F' 
			WHEN (SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE()) >0 THEN 'D' 
			WHEN (SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) <> 0 THEN 'G'
			ELSE 'D'
			END as 狀態,
			(SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期期數,
			(SELECT MIN(kc_expt_date)  FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期日期,
			(SELECT DATEDIFF(month,ISNULL(MIN(kc_expt_date),GETDATE()),GETDATE())  FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期天數,
			(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE())AS 逾期金額,
			(SELECT COUNT(kc_case_no) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL) AS 實際繳款期數,
			(SELECT ISNULL(SUM(kc_expt_fee),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL) AS 未繳餘額,
			(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, getdate()) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NULL AND kc_expt_date < GETDATE() AND kc_expt_fee > 0)+
			(SELECT	ISNULL(ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, kc_pay_date) )/1000.0, 0),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date IS NOT NULL AND kc_expt_date < kc_pay_date AND kc_expt_fee > 0) AS 違約金
			from kcsd.kc_customerloan c
			GROUP BY c.kc_case_no,c.kc_over_count,c.kc_dday_date,c.kc_dday_count,c.kc_over_amt,c.kc_pay_count,c.kc_rema_amt,c.kc_break_amt2,kc_loan_stat
		) AS aa
		WHERE
		(aa.逾期期數<>aa.kc_over_count OR
		aa.逾期日期<>aa.kc_dday_date OR
		aa.逾期天數<>aa.kc_dday_count OR
		aa.逾期金額<>aa.kc_over_amt OR
		aa.實際繳款期數<>aa.kc_pay_count OR
		aa.未繳餘額<>aa.kc_rema_amt OR
		aa.違約金 <> aa.kc_break_amt2 OR
		aa.狀態 <> aa.kc_loan_stat)
		AND aa.kc_case_no = @pm_case_no
	) AS AA
	WHERE kcsd.kc_customerloan.kc_case_no = AA.kc_case_no
END

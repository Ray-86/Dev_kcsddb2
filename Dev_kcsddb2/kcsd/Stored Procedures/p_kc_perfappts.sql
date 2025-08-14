-- =============================================
--  2021-07-12 新增單獨的分公司篩選
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_perfappts] @pm_strt_date datetime, @pm_stop_date DATETIME,@pm_area_code varchar(100)=NULL,@wk_area_code varchar(2) =NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_appt_date	datetime,
	@wk_pay_date	datetime,
	@wk_pay_fee		int,
	@wk_break_fee	int,
	@wk_sales_code	varchar(4),
	@wk_appt_type	varchar(1)

CREATE TABLE #tmp_perfappts
(
	kc_case_no		varchar(10),
	kc_appt_date	datetime,
	kc_pay_fee		int,
	kc_break_fee	int,
	kc_sales_code	varchar(4),
	kc_appt_type	varchar(1)
)

--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @wk_area_code = ''
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
end
else
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ' and kc_area_code = '+ @wk_area_code +')'
end
EXEC sp_executesql @SQL

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT	kc_case_no, kc_pay_date
	FROM	kcsd.kc_loanpayment
	WHERE	kc_pay_date BETWEEN @pm_strt_date AND DATEADD(dd, 10, @pm_stop_date)
	GROUP BY kc_case_no, kc_pay_date

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT  @wk_pay_fee = 0, @wk_break_fee = 0, @wk_appt_date = NULL, @wk_sales_code = NULL, @wk_appt_type = NULL
	
	SELECT	@wk_pay_fee = SUM(kc_pay_fee), @wk_break_fee = SUM(kc_break_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND		kc_pay_date = @wk_pay_date
	GROUP BY kc_case_no, kc_pay_date

	--收款日減10天範圍內 金額、違約金算最後一筆約收
	SELECT  TOP 1 @wk_appt_date = kc_appt_date, @wk_sales_code = kc_sales_code, @wk_appt_type = kc_appt_type
	FROM	kcsd.kc_apptschedule
	WHERE	kc_case_no = @wk_case_no
	AND		kc_appt_date > DATEADD(dd, -10, @wk_pay_date) AND kc_appt_date <= @wk_pay_date
	AND		kc_appt_stat IS NOT NULL
	ORDER BY kc_appt_date DESC

	BEGIN 
		INSERT	#tmp_perfappts
				(kc_case_no, kc_appt_date, kc_pay_fee, kc_break_fee, kc_sales_code, kc_appt_type)
		VALUES	(@wk_case_no, @wk_appt_date, @wk_pay_fee, @wk_break_fee, @wk_sales_code, @wk_appt_type)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date

END
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no

SELECT /*a.kc_case_no, a.kc_appt_date,*/ kc_sales_code, v_Employee.EmpName, v_Employee.AreaCode, kct_area.kc_area_desc,
COUNT(*) AS 委派數, COUNT(*) - COUNT(kc_visit_date) AS 未處理數, 
SUM(CASE WHEN kc_appt_type = 'A' THEN 1 ELSE 0 END) AS A數量, 
SUM(CASE WHEN kc_appt_type = 'B' THEN 1 ELSE 0 END) AS B數量,
SUM(CASE WHEN kc_appt_type = 'A' AND kc_appt_stat IN ('1','2','3','4','5','6','C','D') THEN 1 ELSE 0 END) AS A有效, 
SUM(CASE WHEN kc_appt_type = 'B' AND kc_appt_stat IN ('1','2','3','4','5','6','C','D') THEN 1 ELSE 0 END) AS B有效,
SUM(CASE WHEN kc_appt_type = 'A' THEN ISNULL(kc_appt_amt,0) ELSE 0 END) AS A派本, 
SUM(CASE WHEN kc_appt_type = 'B' THEN ISNULL(kc_appt_amt,0) ELSE 0 END) AS B派本,
SUM(CASE WHEN kc_appt_type = 'A' THEN ISNULL(kc_break_amt,0) ELSE 0 END) AS A派違, 
SUM(CASE WHEN kc_appt_type = 'B' THEN ISNULL(kc_break_amt,0) ELSE 0 END) AS B派違,
SUM(ISNULL(A收本, 0)) AS A收本, SUM(ISNULL(B收本, 0)) AS B收本, SUM(ISNULL(A收違, 0)) AS A收違, SUM(ISNULL(B收違, 0)) AS B收違
FROM kcsd.kc_apptschedule a
LEFT JOIN kcsd.v_Employee ON a.kc_sales_code = v_Employee.EmpCode
LEFT JOIN kcsd.kct_area ON v_Employee.AreaCode = kct_area.kc_area_code
LEFT JOIN (SELECT kc_case_no, kc_appt_date, 
		   CASE WHEN kc_appt_type = 'A' THEN SUM(kc_pay_fee) ELSE 0 END AS A收本,
		   CASE WHEN kc_appt_type = 'B' THEN SUM(kc_pay_fee) ELSE 0 END AS B收本,
		   CASE WHEN kc_appt_type = 'A' THEN SUM(kc_break_fee) ELSE 0 END AS A收違,
		   CASE WHEN kc_appt_type = 'B' THEN SUM(kc_break_fee) ELSE 0 END AS B收違
		   FROM #tmp_perfappts GROUP BY kc_case_no, kc_appt_date, kc_appt_type) perf ON a.kc_case_no = perf.kc_case_no and a.kc_appt_date = perf.kc_appt_date
WHERE a.kc_appt_date BETWEEN @pm_strt_date AND @pm_stop_date
AND kc_sales_code IS NOT NULL 
--AND kc_sales_code = '1227'
--AND (kc_appt_stat <> 'X' OR kc_appt_stat IS NULL)
AND v_Employee.AreaCode IN (select kc_user_area from #tmp_userperm)
GROUP BY /*a.kc_case_no, a.kc_appt_date,*/ kc_sales_code, v_Employee.EmpName, v_Employee.AreaCode, kct_area.kc_area_desc
ORDER BY kc_sales_code

DROP TABLE #tmp_perfappts

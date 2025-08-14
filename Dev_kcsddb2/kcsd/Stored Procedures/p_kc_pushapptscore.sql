-- =============================================
-- 2021-07-12 新增單獨的分公司篩選
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_pushapptscore] @pm_strt_date DATETIME, @pm_stop_date DATETIME,@pm_area_code varchar(100)=NULL,@wk_area_code varchar(2) =NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_pay_date	datetime,
	@wk_invo_date	datetime,
	@wk_break_fee	int,
	@wk_intr_fee	int,
	@wk_pay_fee		int,
	@wk_pusher_code	varchar(6),
	@wk_sales_code  varchar(4),
	@wk_appt_date	datetime,
	@wk_strt_date	datetime,
	@wk_stop_date	datetime,
	@wk_recog_amt	int,		--認列違約金
	--計算M0~MX用
	@wk_expt_fee	int,		
	@wk_pay_fee2	int,
	@wk_expt_date	datetime,
	@wk_expt_cont	int


CREATE TABLE #tmp_pushapptscore
(
	kc_case_no		varchar(10),
	kc_pay_date		datetime,
	kc_break_fee	int,
	kc_intr_fee		int,
	kc_pay_fee		int,
	kc_pusher_code	varchar(6),
	kc_sales_code	varchar(4),
	kc_appt_date	datetime,
	kc_recog_amt	int
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
	SELECT	l.kc_case_no,l.kc_pay_date,l.kc_invo_date
	FROM	kcsd.kc_loanpayment l, kcsd.kc_customerloan c
	WHERE	l.kc_case_no = c.kc_case_no AND
	l.kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date AND 
	l.kc_expt_date < l.kc_pay_date AND
	c.kc_area_code IN ( select kc_user_area from #tmp_userperm)
	GROUP BY l.kc_case_no,l.kc_pay_date,l.kc_invo_date

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date, @wk_invo_date

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_break_fee = 0, @wk_intr_fee = 0, @wk_pay_fee = 0, @wk_pusher_code=NULL, @wk_sales_code=NULL, @wk_appt_date=NULL
	
	--其他收入算違約金回收
	SELECT	@wk_break_fee = sum(kc_break_fee), @wk_intr_fee = sum(kc_intr_fee), @wk_pay_fee = sum(kc_pay_fee)
	FROM	kcsd.kc_loanpayment l
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = @wk_pay_date 
	AND kc_invo_date = @wk_invo_date
	AND l.kc_expt_date < l.kc_pay_date
	
	--找出當時催收人
	SELECT	@wk_pusher_code = kc_pusher_code, @wk_strt_date = kc_strt_date, @wk_stop_date = kc_stop_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	((kc_strt_date <= @wk_pay_date AND kc_stop_date >= @wk_pay_date) OR 
		 (kc_strt_date <= @wk_invo_date AND kc_stop_date >= @wk_invo_date))

	-- 是否目前還在催收
	IF	@wk_pusher_code IS NULL
		SELECT	@wk_pusher_code = kc_pusher_code, @wk_strt_date = kc_strt_date, @wk_stop_date = kc_stop_date
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	((kc_strt_date <= @wk_pay_date AND kc_stop_date IS NULL) OR 
			 (kc_strt_date <= @wk_invo_date AND kc_stop_date IS NULL))

	--找約收查訪
	SELECT @wk_sales_code = kc_sales_code, @wk_appt_date = kc_appt_date	
	FROM   kcsd.kc_apptschedule a
	WHERE  kc_case_no = @wk_case_no
	AND kc_appt_stat IS NOT NULL AND kc_appt_stat <> 'X'
	AND DATEDIFF(dd, kc_appt_date, @wk_pay_date) BETWEEN 0 and 10
	AND ((@wk_pay_date BETWEEN kc_appt_date AND kc_visit_date) OR
		 (@wk_invo_date BETWEEN kc_appt_date AND kc_visit_date))
	AND ((kc_appt_date >= @wk_strt_date AND kc_appt_date <= @wk_stop_date) OR
		 (kc_appt_date >= @wk_strt_date AND @wk_stop_date IS NULL))

	--不在約定-查訪區間 找入賬日期前一筆約訪
	IF @wk_sales_code IS NULL
		SELECT TOP 1 @wk_sales_code = kc_sales_code, @wk_appt_date = kc_appt_date
		FROM   kcsd.kc_apptschedule a
		WHERE  kc_case_no = @wk_case_no
		AND kc_appt_stat IS NOT NULL AND kc_appt_stat <> 'X'
		AND DATEDIFF(dd, kc_appt_date, @wk_pay_date) BETWEEN 0 and 10
		AND kc_appt_date < @wk_invo_date
		AND ((kc_appt_date >= @wk_strt_date AND kc_appt_date <= @wk_stop_date) OR
			 (kc_appt_date >= @wk_strt_date AND @wk_stop_date IS NULL))
		ORDER BY kc_appt_date DESC

	
	--計算M0~MX
	SELECT @wk_expt_fee = null, @wk_pay_fee2 = null,@wk_expt_date =null
	SELECT  TOP 1 @wk_expt_fee = kc_expt_fee, @wk_pay_fee2 = kc_pay_fee,@wk_expt_date = kc_expt_date  
	FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND KC_PAY_DATE < @pm_strt_date ORDER BY kc_expt_date DESC
	SELECT  @wk_expt_date = isnull(@wk_expt_date,(select kc_strt_date from kcsd.kc_customerloan where kc_case_no = @wk_case_no))
	IF (@wk_expt_fee  =  @wk_pay_fee2) and @wk_expt_fee is not null
		SELECT @wk_expt_cont = datediff(month,DATEADD(mm,1,@wk_expt_date),@pm_stop_date)
	ELSE
		SELECT @wk_expt_cont = datediff(month,@wk_expt_date,@pm_stop_date)
	IF @wk_expt_cont < 0 SELECT @wk_expt_cont = 0
	IF @wk_expt_cont > 3 SELECT @wk_expt_cont = 3

	--M0、M1 算認列違約金
	IF (@wk_expt_cont <= 1 AND @wk_break_fee > 200)
		SELECT @wk_recog_amt = @wk_break_fee - 200
	ELSE
		SELECT @wk_recog_amt = @wk_break_fee
	
	IF @wk_pusher_code IS NOT NULL AND SUBSTRING(@wk_pusher_code,1,1) ='P' AND @wk_sales_code IS NOT NULL
	BEGIN 
		INSERT	#tmp_pushapptscore
				(kc_case_no, kc_pay_date, kc_pay_fee, kc_break_fee, kc_intr_fee, kc_pusher_code, kc_sales_code, kc_appt_date, kc_recog_amt)
		VALUES	(@wk_case_no, @wk_pay_date, @wk_pay_fee, @wk_break_fee, @wk_intr_fee, @wk_pusher_code, @wk_sales_code, @wk_appt_date, @wk_recog_amt)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date, @wk_invo_date

END
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no


SELECT	a.kc_case_no, a.kc_appt_date, a.kc_sales_code, a.kc_appt_type, e.AreaCode as kc_area_code, kc_pay_date
, SUM(kc_pay_fee) AS kc_pay_fee, SUM(kc_break_fee) AS kc_break_fee, SUM(kc_intr_fee) AS kc_intr_fee, SUM(kc_recog_amt) AS kc_recog_amt
, b.kc_pusher_code, 
CASE WHEN kc_appt_type = 'A' THEN 1 ELSE 0 END AS kc_appt_acnt, 
CASE WHEN kc_appt_type = 'B' THEN 1 ELSE 0 END AS kc_appt_bcnt,
CASE WHEN kc_appt_type = 'A' AND kc_pay_date IS NOT NULL THEN 1 ELSE 0 END AS kc_effe_acnt,
CASE WHEN kc_appt_type = 'B' AND kc_pay_date IS NOT NULL THEN 1 ELSE 0 END AS kc_effe_bcnt,
c.kc_cust_nameu
FROM	kcsd.kc_apptschedule a
LEFT JOIN #tmp_pushapptscore b ON a.kc_case_no = b.kc_case_no and a.kc_appt_date = b.kc_appt_date
LEFT JOIN kcsd.kc_customerloan c ON a.kc_case_no = c.kc_case_no
LEFT JOIN kcsd.v_Employee e ON a.kc_sales_code = e.EmpCode
WHERE a.kc_appt_date BETWEEN @pm_strt_date AND @pm_stop_date
GROUP BY a.kc_case_no, a.kc_appt_date, a.kc_sales_code, a.kc_appt_type, e.AreaCode, kc_appt_type, kc_appt_stat, b.kc_pusher_code, 
		 kc_pay_date, c.kc_cust_nameu
UNION
SELECT	a.kc_case_no, a.kc_appt_date, a.kc_sales_code, a.kc_appt_type, e.AreaCode as kc_area_code, kc_pay_date
, SUM(kc_pay_fee) AS kc_pay_fee, SUM(kc_break_fee) AS kc_break_fee, SUM(kc_intr_fee) AS kc_intr_fee, SUM(kc_recog_amt) AS kc_recog_amt
, b.kc_pusher_code, 
CASE WHEN kc_appt_type = 'A' THEN 1 ELSE 0 END AS kc_appt_acnt, 
CASE WHEN kc_appt_type = 'B' THEN 1 ELSE 0 END AS kc_appt_bcnt,
CASE WHEN kc_appt_type = 'A' AND kc_pay_date IS NOT NULL THEN 1 ELSE 0 END AS kc_effe_acnt,
CASE WHEN kc_appt_type = 'B' AND kc_pay_date IS NOT NULL THEN 1 ELSE 0 END AS kc_effe_bcnt,
c.kc_cust_nameu
FROM	kcsd.kc_apptschedule a
LEFT JOIN #tmp_pushapptscore b ON a.kc_case_no = b.kc_case_no and a.kc_appt_date = b.kc_appt_date
LEFT JOIN kcsd.kc_customerloan c ON a.kc_case_no = c.kc_case_no
LEFT JOIN kcsd.v_Employee e ON a.kc_sales_code = e.EmpCode
WHERE a.kc_appt_date = b.kc_appt_date
and a.kc_appt_date < @pm_strt_date
GROUP BY a.kc_case_no, a.kc_appt_date, a.kc_sales_code, a.kc_appt_type, e.AreaCode, kc_appt_type, kc_appt_stat, b.kc_pusher_code, 
		 kc_pay_date, c.kc_cust_nameu
ORDER BY kc_sales_code, kc_case_no


DROP TABLE #tmp_pushapptscore
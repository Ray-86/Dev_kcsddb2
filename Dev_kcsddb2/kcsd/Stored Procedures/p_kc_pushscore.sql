-- ==========================================================================================
-- 20210329 更改約收成本計算方式 判斷入帳10日內是否有約訪登記
-- 20200120 委派日期
-- 20190919 增加約收成本欄位
-- 01/05/08 新增 kc_intr_fee 計算
-- 20160624 增加欄位,增加區域條件
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_pushscore] @pm_strt_date datetime, @pm_stop_date DATETIME,@pm_area_code varchar(100)=NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_area_code 	varchar(2),
	@wk_pay_date	datetime,
	@wk_pay_fee	int,
	@wk_break_fee	int,
	@wk_intr_fee	int,
	@wk_pusher_code	varchar(6),
	@wk_cust_nameu nvarchar(60),
	@wk_emp_name varchar(10),
	@wk_break_amt2 int,			--違約金上限
	@wk_break_over int,			--超收違約金
	@wk_rece_amt int,			--約收成本
	@wk_break_amts int	,		--實際計算違約金
	@wk_strt_date datetime,		--委派日期
	@wk_sales_code varchar(4),
	@wk_recog_amt	int,		--認列違約金
	--計算M0~MX用
	@wk_expt_fee	int,		
	@wk_pay_fee2	int,
	@wk_expt_date	datetime,
	@wk_expt_cont	int

CREATE TABLE #tmp_pushscore
(
	kc_case_no	varchar(10),
	kc_pay_date	datetime,
	kc_pay_fee	int,
	kc_break_fee	int,
	kc_intr_fee	int,
	kc_pusher_code	varchar(6),
	kc_cust_nameu nvarchar(60),
	kc_emp_name varchar(10),
	kc_break_amt2 int,
	kc_break_over int,
	kc_rece_amt int,
	kc_break_amts int,		
	kc_strt_date datetime,
	kc_recog_amt int
)

--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
EXEC sp_executesql @SQL

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT	l.kc_case_no,l.kc_pay_date
	FROM	kcsd.kc_loanpayment l, kcsd.kc_customerloan c
	WHERE	l.kc_case_no = c.kc_case_no AND
			l.kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date AND 
			c.kc_area_code IN ( select kc_user_area from #tmp_userperm)
			--AND l.kc_case_no = '1931402'
	GROUP BY l.kc_case_no,l.kc_pay_date

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pay_fee=0, @wk_break_fee=0, @wk_intr_fee=0, @wk_rece_amt=0, 
			@wk_pusher_code=NULL, @wk_strt_date=NULL, @wk_sales_code=NULL

	SELECT	@wk_pay_fee = sum(kc_pay_fee), @wk_break_fee = sum(kc_break_fee), @wk_intr_fee = sum(kc_intr_fee)
		, @wk_rece_amt = isnull((select 200 from [Zephyr.Sys].dbo.sys_user u where JobType in ('C','D') and u.UserSeq = l.kc_rece_code),0)
	FROM	kcsd.kc_loanpayment l
	WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date = @wk_pay_date
	GROUP BY kc_case_no,l.kc_rece_code
	
	--找出當時催收人
	SELECT	@wk_pusher_code = kc_pusher_code, @wk_strt_date = kc_strt_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date <= @wk_pay_date
	AND	kc_stop_date >= @wk_pay_date

	-- 是否目前還在催收
	IF	@wk_pusher_code IS NULL
		SELECT	@wk_pusher_code = kc_pusher_code, @wk_strt_date = kc_strt_date
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date <= @wk_pay_date
		AND	kc_stop_date IS NULL

	--入帳10日內是否有約訪登記
	SELECT @wk_sales_code = kc_sales_code
	FROM kcsd.kc_apptschedule
	WHERE kc_case_no = @wk_case_no
	AND kc_appt_stat IS NOT NULL AND kc_appt_stat <> 'X'
	AND DATEDIFF(dd, kc_appt_date, @wk_pay_date) between 0 and 10
	--違約金全列約收成本
	IF @wk_sales_code IS NOT NULL
		SELECT @wk_rece_amt = @wk_break_fee
	
	SELECT @wk_emp_name = DelegateName FROM kcsd.Delegate where DelegateCode = @wk_pusher_code
	SELECT @wk_area_code = kc_area_code ,@wk_cust_nameu = kc_cust_nameu,@wk_break_amt2 = kc_break_amt2 FROM kcsd.kc_customerloan where kc_case_no = @wk_case_no
	IF @wk_break_amt2 > 0 and @wk_break_amt2 <200 SELECT @wk_break_amt2 = 200
	IF (@wk_break_fee - @wk_break_amt2 < 1) SELECT @wk_break_over = null ELSE SELECT @wk_break_over = @wk_break_fee - @wk_break_amt2	

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
	
	--計算違約金
	IF (@wk_recog_amt - @wk_rece_amt >= 0)
		SELECT @wk_break_amts = @wk_recog_amt - @wk_rece_amt
	ELSE
		SELECT @wk_break_amts = 0

	IF @wk_pusher_code IS NOT NULL AND SUBSTRING(@wk_pusher_code,1,1) ='P'
	BEGIN 
		INSERT	#tmp_pushscore
				( kc_case_no, kc_pay_date, kc_pay_fee, kc_break_fee, kc_intr_fee, kc_pusher_code, kc_cust_nameu, kc_emp_name, kc_break_amt2, kc_break_over, kc_rece_amt, kc_break_amts, kc_strt_date, kc_recog_amt)
		VALUES	(@wk_case_no,@wk_pay_date,@wk_pay_fee,@wk_break_fee,@wk_intr_fee,@wk_pusher_code,@wk_cust_nameu,@wk_emp_name,@wk_break_amt2,@wk_break_over,@wk_rece_amt,@wk_break_amts,@wk_strt_date,@wk_recog_amt)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_pay_date

END
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_pushscore
ORDER BY kc_case_no

DROP TABLE #tmp_pushscore

-- ==========================================================================================
-- 20180314 增加月報表
-- 20170111 新增MP計算
-- 20160624 增加欄位,增加區域條件
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_pushonhand_push] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL, @pm_area_code varchar(100)=NULL, @pm_run_code varchar(10)=NULL
AS
DECLARE
	@wk_case_no		varchar(10),
	@wk_area_code	varchar(2),
	@wk_area_desc	varchar(10),
	@wk_pusher_code	varchar(6),
	@wk_strt_date	datetime,
	@wk_stop_date	datetime,
	@wk_pstrt_date	datetime,
	@wk_pstop_date	datetime,
	@wk_over_amt	int,
	@wk_prepay_sum	int,
	@wk_expt_fee	int,
	@wk_pay_fee		int,
	@wk_expt_date	datetime,
	@wk_expt_cont	int,
	@wk_pay_sum		int,
	@wk_pay_sum1	int,
	@wk_intr_sum	int,
	@wk_break_sum	INT,
	@wk_cust_nameu	nvarchar(60),
	@wk_emp_name	varchar(10),
	@wk_loan_desc	varchar(6),
	@wk_a2_date		datetime

CREATE TABLE #tmp_pushonhand
(
	kc_case_no		varchar(10),
	kc_area_code	varchar(2),
	kc_area_desc	varchar(10),
	kc_pusher_code	varchar(6),
	kc_strt_date	smalldatetime,
	kc_close_date	smalldatetime,
	kc_over_amt		int,
	kc_pay_sum		int,
	kc_pay_sum1		int,
	kc_intr_sum		int,
	kc_break_sum	int,
	kc_delay_code	varchar(1),
	kc_cust_nameu	nvarchar(60),
	kc_emp_name		varchar(10),
	kc_loan_desc	varchar(6)
)

CREATE TABLE #tmp_pushonhandPtoL
(
	kc_case_no			varchar(10),
	kc_pusher_code		varchar(6),
	kc_over_amt			int
)
DECLARE	
	@wk_case_no_push			varchar(10),
	@wk_pusher_code_push		varchar(4),
	@wk_strt_date_push          datetime
DECLARE c1 CURSOR FOR
	--第一次派法務
	SELECT * FROM
	(SELECT p.kc_case_no,MIN(p.kc_strt_date) as kc_strt_date
		FROM kcsd.kc_pushassign p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		WHERE p.kc_pusher_code LIKE 'L%'
		GROUP BY p.kc_case_no,kc_sales_code) S
	WHERE S.kc_strt_date between @pm_strt_date and @pm_stop_date

OPEN c1
FETCH NEXT FROM c1 INTO @wk_case_no_push,@wk_strt_date_push
WHILE (@@FETCH_STATUS = 0)
BEGIN
	--取轉法務前催收
	SELECT	TOP 1 @wk_pusher_code_push = kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no_push AND (kc_pusher_code LIKE 'P%' OR kc_pusher_code LIKE 'S%'OR kc_pusher_code LIKE 'C%') AND kc_strt_date < @wk_strt_date_push
	ORDER BY kc_strt_date DESC

	--取轉法務時 逾期金額、未繳餘額、違約金
	SELECT 
	@wk_over_amt = (SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < @wk_strt_date_push AND kc_perd_no < 50) -
				   (SELECT	ISNULL(SUM(kc_pay_fee), 0) FROM	kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND	kc_pay_date < @wk_strt_date_push)
	FROM kcsd.kc_customerloan c
	WHERE kc_case_no = @wk_case_no_push
	
	
	INSERT #tmp_pushonhandPtoL (kc_case_no,kc_pusher_code,kc_over_amt)
	VALUES (@wk_case_no_push,@wk_pusher_code_push,@wk_over_amt)

FETCH NEXT FROM c1 INTO @wk_case_no_push,@wk_strt_date_push
END
CLOSE c1
DEALLOCATE c1




--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
EXEC sp_executesql @SQL

--IF	@pm_case_no IS NULL
	DECLARE c1 CURSOR FOR
	SELECT p.kc_case_no,c.kc_area_code,a.kc_area_desc,p.kc_pusher_code,p.kc_strt_date,p.kc_stop_date
	FROM kcsd.kc_pushassign p,kcsd.kc_customerloan c,kcsd.kct_area a
	WHERE
	p.kc_case_no = c.kc_case_no AND
	(p.kc_pusher_code like 'P%' or p.kc_pusher_code like 'C%') 
	AND
	c.kc_area_code IN ( SELECT kc_user_area from #tmp_userperm ) AND
	c.kc_area_code = a.kc_area_code AND
	not EXISTS(
		SELECT 'X'
		FROM kcsd.kc_pushassign a
		where
		(
		(a.kc_strt_date < @pm_strt_date  AND kc_stop_date <@pm_strt_date ) OR (a.kc_strt_date > @pm_stop_date AND a.kc_stop_date > @pm_stop_date) OR (kc_strt_date > @pm_stop_date AND kc_stop_date IS NULL)
		)
		AND a.kc_case_no = p.kc_case_no
		AND a.kc_pusher_code = p.kc_pusher_code
		AND a.kc_strt_date = p.kc_strt_date
		AND isnull(a.kc_stop_date,'') = isnull(p.kc_stop_date,'')
	)

OPEN c1
FETCH NEXT FROM c1 INTO @wk_case_no,@wk_area_code,@wk_area_desc,@wk_pusher_code,@wk_strt_date,@wk_stop_date
WHILE (@@FETCH_STATUS = 0)
BEGIN

	SELECT @wk_over_amt = 0
	SELECT @wk_pay_sum = 0

	--取日期
	if @wk_strt_date < @pm_strt_date
		select @wk_pstrt_date = @pm_strt_date
	else
		select @wk_pstrt_date = @wk_strt_date
	
	if @wk_stop_date < @pm_stop_date or @wk_stop_date is null
		select @wk_pstop_date = isnull(@wk_stop_date,@pm_stop_date)
	else
		select @wk_pstop_date = @pm_stop_date
	
	--計算M0~MX
	SELECT @wk_expt_fee = null, @wk_pay_fee = null,@wk_expt_date =null
	SELECT  TOP 1 @wk_expt_fee = kc_expt_fee, @wk_pay_fee = kc_pay_fee,@wk_expt_date = kc_expt_date  from kcsd.kc_loanpayment where kc_case_no =@wk_case_no and KC_PAY_DATE < @pm_strt_date order by kc_expt_date desc
	SELECT  @wk_expt_date = isnull(@wk_expt_date,(select kc_strt_date from kcsd.kc_customerloan where kc_case_no = @wk_case_no))
	SELECT @wk_a2_date = MIN(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_rece_code = 'A2'
	IF (@wk_expt_fee  =  @wk_pay_fee) and @wk_expt_fee is not null
		SELECT @wk_expt_cont = datediff(month,DATEADD(mm,1,@wk_expt_date),@pm_stop_date)
	ELSE
		SELECT @wk_expt_cont = datediff(month,@wk_expt_date,@pm_stop_date)
	IF @wk_expt_cont < 0 SELECT @wk_expt_cont = 0
	IF @wk_expt_cont > 3 SELECT @wk_expt_cont = 3

	-- 計算委託金額
	SELECT	@wk_over_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_expt_date <= @wk_pstop_date
	AND	kc_perd_no < 50

	SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date < @wk_pstrt_date

	SELECT	@wk_over_amt = @wk_over_amt - @wk_prepay_sum
	IF	@wk_over_amt < 0  SELECT @wk_over_amt = 0

	-- 計算回收金額
	SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
			@wk_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
			@wk_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
	FROM	kcsd.kc_loanpayment

	WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date
		AND	kc_expt_date <= @wk_pstop_date
		--AND	kc_expt_date < kc_pay_date 

	--取委派期間收取的歸責費
	SELECT	@wk_pay_sum1 = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)- ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0)		
	FROM	kcsd.kc_otherpayment
	WHERE	kc_case_no = @wk_case_no
	AND		kc_offset_type = '01'
	AND	kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date

	--新增至table
	IF	@wk_over_amt > 0 or @wk_pay_sum > 0
	BEGIN
		SELECT @wk_emp_name ='',@wk_cust_nameu='',@wk_loan_desc=''
		SELECT @wk_emp_name = DelegateName FROM kcsd.Delegate WHERE DelegateCode = @wk_pusher_code
		SELECT @wk_cust_nameu = c.kc_cust_nameu,@wk_loan_desc = l.kc_loan_desc FROM kc_customerloan c LEFT JOIN kc_loanstatus l ON c.kc_loan_stat = l.kc_loan_stat WHERE c.kc_case_no = @wk_case_no
		INSERT #tmp_pushonhand
			 (kc_case_no, kc_area_code, kc_area_desc, kc_pusher_code, kc_strt_date, kc_close_date, kc_over_amt, kc_pay_sum,kc_pay_sum1, kc_intr_sum, kc_break_sum, kc_delay_code,kc_cust_nameu,kc_emp_name,kc_loan_desc)
		VALUES (@wk_case_no, @wk_area_code, @wk_area_desc, @wk_pusher_code, @wk_strt_date, @wk_stop_date, @wk_over_amt, @wk_pay_sum,@wk_pay_sum1, @wk_intr_sum,  @wk_break_sum, @wk_expt_cont,@wk_cust_nameu,@wk_emp_name,@wk_loan_desc)
	END
	
	--MP計算
	IF @wk_a2_date IS NOT NULL AND @wk_a2_date <= @wk_pstop_date
	BEGIN
		-- 計算委託金額 = 貸款金額-報表開始前所繳金額
		SELECT	@wk_over_amt = ISNULL(kc_loan_fee,0)
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND		kc_pay_date < @wk_pstrt_date

		SELECT	@wk_over_amt = @wk_over_amt - @wk_prepay_sum
		IF	@wk_over_amt < 0  SELECT @wk_over_amt = 0
		
		-- 計算回收金額 = 報表期間所繳金額(不含A2前)
		SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
				@wk_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
				@wk_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
		FROM	kcsd.kc_loanpayment

		WHERE	kc_case_no = @wk_case_no
		AND		kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date
		AND		kc_pay_date >= @wk_a2_date	--A2之後的算在MP
	
		--取委派期間收取的歸責費
		SELECT	@wk_pay_sum1 = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)- ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0)		
		FROM	kcsd.kc_otherpayment
		WHERE	kc_case_no = @wk_case_no
		AND		kc_offset_type = '01'
		AND		kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date
		AND		kc_pay_date >= @wk_a2_date	--A2之後的算在MP
		
		--新增至table MP
		--不把委派金額0的排除
		SELECT @wk_emp_name ='',@wk_cust_nameu='',@wk_loan_desc=''
		SELECT @wk_emp_name = DelegateName FROM kcsd.Delegate WHERE DelegateCode = @wk_pusher_code
		SELECT @wk_cust_nameu = c.kc_cust_nameu,@wk_loan_desc = l.kc_loan_desc FROM kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus l ON c.kc_loan_stat = l.kc_loan_stat WHERE c.kc_case_no = @wk_case_no
		INSERT #tmp_pushonhand
			 (kc_case_no, kc_area_code, kc_area_desc, kc_pusher_code, kc_strt_date, kc_close_date, kc_over_amt, kc_pay_sum,kc_pay_sum1, kc_intr_sum, kc_break_sum, kc_delay_code,kc_cust_nameu,kc_emp_name,kc_loan_desc)
		VALUES (@wk_case_no, @wk_area_code, @wk_area_desc, @wk_pusher_code, @wk_strt_date, @wk_stop_date, @wk_over_amt, @wk_pay_sum,@wk_pay_sum1, @wk_intr_sum,  @wk_break_sum, SUBSTRING(@wk_pusher_code,1,1),@wk_cust_nameu,@wk_emp_name,@wk_loan_desc)
	END
	
FETCH NEXT FROM c1 INTO @wk_case_no,@wk_area_code,@wk_area_desc,@wk_pusher_code,@wk_strt_date,@wk_stop_date
END
CLOSE c1
DEALLOCATE c1

--直接移除當月份轉派且無回收金額的資料(委派金額算給下一個催收人) 連續刪5次
DECLARE @_i INT
SET @_i = 0
WHILE (@_i < 5)
BEGIN
	DELETE FROM #tmp_pushonhand
	WHERE EXISTS
		(SELECT b.kc_case_no
		FROM #tmp_pushonhand b
		WHERE b.kc_delay_code not in ('P','C')
		GROUP BY b.kc_case_no
		 HAVING count(b.kc_case_no)>1
		 AND #tmp_pushonhand.kc_case_no = b.kc_case_no
		 AND #tmp_pushonhand.kc_strt_date = MIN(b.kc_strt_date)
		)
	AND kc_pay_sum = 0
	AND kc_intr_sum = 0
	AND kc_break_sum = 0
	AND kc_delay_code not in ('P','C')
	Set @_i=@_i+1
 END

IF	@pm_run_code = 'EXECUTE'
BEGIN
	
	DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_pushonhand_push where kc_push_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_pushonhand_push
		SELECT convert(varchar(6),@pm_strt_date,112) as kc_pusher_date,p.kc_area_code,c.kc_prod_type,p.kc_pusher_code,'' as kc_user_name,count(p.kc_case_no) as kc_push_cnt,sum(p.kc_over_amt) as kc_over_amt,SUM( CASE WHEN kc_pay_sum > 0  THEN 1 ELSE 0 END) as kc_pay_cnt,sum(kc_pay_sum) as kc_pay_sum,sum(kc_pay_sum1) as kc_pay_sum1,sum(kc_intr_sum) as kc_intr_sum,Sum([kc_pay_sum]-[kc_intr_sum]) as kc_pay_amt,sum(kc_break_sum) as kc_break_sum,0 as kc_close_cnt,0 as kc_scores_point,0 as kc_scores_point1,o.kc_over_sum,o.kc_over_amt
		FROM #tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		left join (
		SELECT ss.*,SUM(dd.kc_over_amt) as kc_over_amt from 
		(SELECT kc_pusher_code,SUM(kc_over_amt) as kc_over_sum from #tmp_pushonhand where kc_delay_code not in ('P','C') group by kc_pusher_code) as ss
		left join (select p.kc_pusher_code,sum(p.kc_over_amt) as kc_over_amt from #tmp_pushonhandPtoL p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no group by c.kc_area_code,c.kc_prod_type,c.kc_push_sort,c.kc_sales_code,c.kc_case_no,c.kc_cust_nameu,p.kc_pusher_code) as dd on dd.kc_pusher_code = ss.kc_pusher_code
		group by ss.kc_pusher_code , ss.kc_over_sum
		) o on p.kc_pusher_code = o.kc_pusher_code
		WHERE p.kc_delay_code not in ('P','C')
		GROUP BY p.kc_pusher_code,p.kc_area_code,c.kc_prod_type,o.kc_over_sum,o.kc_over_amt
		ORDER by p.kc_pusher_code,p.kc_area_code,c.kc_prod_type
	END
END
ELSE
BEGIN

	SELECT	* 
	FROM	#tmp_pushonhand
	ORDER BY kc_pusher_code,kc_case_no 
END
DROP TABLE #tmp_pushonhand

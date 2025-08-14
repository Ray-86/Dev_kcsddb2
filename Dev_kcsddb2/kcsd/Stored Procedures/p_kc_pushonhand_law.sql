-- ==========================================================================================
-- 20171201	增加業務處理費用
-- 20170926 增加計算規費歸責費
-- 20170220 增加產生月報資料
-- 20160624 增加欄位,增加區域條件
-- 20200507 程序費新增K/K0
-- 20211124 新增查訪成本、認列違約金計算
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_pushonhand_law] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL,@pm_area_code varchar(100)=NULL,@pm_run_code varchar(10)=NULL
AS
DECLARE	
	@wk_case_no			varchar(10),
	@wk_area_code		varchar(2),
	@wk_area_desc		varchar(10),
	@wk_pusher_code		varchar(6),
	@wk_strt_date		datetime,
	@wk_stop_date		datetime,
	@wk_pstrt_date		datetime,
	@wk_pstop_date		datetime,
	@wk_over_amt		int,
	@wk_prepay_sum		int,
	@wk_expt_fee		int,
	@wk_pay_fee			int,
	@wk_expt_date		datetime,
	@wk_expt_cont		int,
	@wk_pay_sum			int,
	@wk_pay_sum1		int,
	@wk_pay_sum2		int,
	@wk_intr_sum		int,
	@wk_break_sum		int,
	@wk_law_sum			int,
	@wk_buy_date		datetime,
	@wk_loan_desc		varchar(6),
	@wk_cust_nameu		nvarchar(60),
	@wk_emp_name		varchar(10),
	@wk_emp_code		varchar(4),
	@wk_law_amt			int,
	@wk_law_amt1		int,
	@wk_sales_amt		int,
	@wk_appt_cost		int,
	@wk_recog_amt		int,
	@wk_break_sum2		int

CREATE TABLE #tmp_pushonhand
(
	kc_case_no			varchar(10),
	kc_area_code		varchar(2),
	kc_area_desc		varchar(10),
	kc_pusher_code		varchar(6),
	kc_strt_date		datetime,
	kc_close_date		datetime,
	kc_over_amt			int,
	kc_pay_sum			int,
	kc_pay_sum1			int,
	kc_pay_sum2			int,
	kc_intr_sum			int,
	kc_break_sum		int,
	kc_law_sum			int,
	kc_sales_sum		int,
	kc_delay_code		varchar(1),
	kc_buy_date			datetime,
	kc_cust_nameu		nvarchar(60),
	kc_emp_name			varchar(10),
	kc_loan_desc		varchar(6),
	kc_recog_amt        int
)

--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
EXEC sp_executesql @SQL

	DECLARE c1 CURSOR FOR
	SELECT p.kc_case_no,c.kc_area_code,a.kc_area_desc,p.kc_pusher_code,p.kc_strt_date,p.kc_stop_date
	FROM kcsd.kc_pushassign p,kcsd.kc_customerloan c,kcsd.kct_area a
	WHERE
	p.kc_case_no = c.kc_case_no AND
	c.kc_area_code = a.kc_area_code AND
	p.kc_pusher_code LIKE 'L%' AND
	c.kc_area_code IN ( SELECT kc_user_area from #tmp_userperm ) AND
	not EXISTS(
		SELECT 'X'
		FROM kcsd.kc_pushassign a
		WHERE
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

	SELECT @wk_over_amt = 0, @wk_pay_sum = 0, @wk_pay_sum1 = 0, @wk_pay_sum2 = 0, @wk_area_code = null, @wk_buy_date=null, @wk_law_sum = 0, @wk_law_amt = 0, @wk_law_amt1 = 0, @wk_sales_amt = 0, @wk_appt_cost = 0, @wk_recog_amt = 0, @wk_break_sum2 = 0

	--取日期
	if @wk_strt_date < @pm_strt_date
		select @wk_pstrt_date = @pm_strt_date
	else
		select @wk_pstrt_date = @wk_strt_date
	
	if @wk_stop_date < @pm_stop_date or @wk_stop_date is null
		select @wk_pstop_date = isnull(@wk_stop_date,@pm_stop_date)
	else
		select @wk_pstop_date = @pm_stop_date
	
	select @wk_area_code = kc_area_code,@wk_buy_date=kc_buy_date from kcsd.kc_customerloan where kc_case_no = @wk_case_no

	--計算M0~MX
	SELECT @wk_expt_fee = null, @wk_pay_fee = null,@wk_expt_date =null
	SELECT  TOP 1 @wk_expt_fee = kc_expt_fee, @wk_pay_fee = kc_pay_fee,@wk_expt_date = kc_expt_date  from kcsd.kc_loanpayment where kc_case_no =@wk_case_no and KC_PAY_DATE < @pm_strt_date order by kc_expt_date desc
	SELECT  @wk_expt_date = isnull(@wk_expt_date,(select kc_strt_date from kcsd.kc_customerloan where kc_case_no = @wk_case_no))
	IF (@wk_expt_fee  =  @wk_pay_fee) and @wk_expt_fee is not null
		SELECT @wk_expt_cont = datediff(month,DATEADD(mm,1,@wk_expt_date),@pm_stop_date)
	ELSE
		SELECT @wk_expt_cont = datediff(month,@wk_expt_date,@pm_stop_date)
	IF @wk_expt_cont < 0 SELECT @wk_expt_cont = 0

	-- 計算委託金額
	SELECT 	@wk_over_amt = kc_perd_fee*kc_loan_perd 
	FROM		kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date < @wk_pstrt_date
	SELECT	@wk_over_amt = @wk_over_amt - @wk_prepay_sum
	IF @wk_expt_cont < 0 SELECT @wk_expt_cont = 0
	IF @wk_expt_cont > 3 SELECT @wk_expt_cont = 3

	-- 計算回收金額
	SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
			@wk_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
			@wk_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)	
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND		kc_pay_date BETWEEN  @wk_pstrt_date AND @wk_pstop_date

	--取委派期間收取的歸責費
	SELECT	@wk_pay_sum1 = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)- ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0)		
	FROM	kcsd.kc_otherpayment
	WHERE	kc_case_no = @wk_case_no
	AND		kc_offset_type = '01'
	AND		kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date

	--取委派期間收取的規費
	SELECT	@wk_pay_sum2 = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)- ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0)		
	FROM	kcsd.kc_otherpayment
	WHERE	kc_case_no = @wk_case_no
	AND		kc_offset_type = '02'
	AND		kc_pay_date BETWEEN @wk_pstrt_date AND @wk_pstop_date

	--取委派期間業務處理收取的違約金
	SELECT	@wk_sales_amt = ISNULL(SUM(ISNULL(kc_break_amt, 0)), 0)
	FROM	kcsd.SalesBonus
	WHERE	kc_case_no = @wk_case_no
	AND		kc_input_date BETWEEN @wk_pstrt_date AND @wk_pstop_date

	--結清後取得程序費用
	IF @wk_pay_sum = @wk_over_amt
	BEGIN
		SELECT @wk_law_amt = ISNULL(SUM(ISNULL(kc_law_amt, 0)), 0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no and ((kc_law_code ='C' and kc_law_fmt in ('C0','C5','C7','CF','CK')) or (kc_law_code ='A' and kc_law_fmt in ('XB','XD')) or (kc_law_code ='G' and kc_law_fmt ='A7') or (kc_law_code ='X' and kc_law_fmt ='T5') or (kc_law_code ='E'))
 		SELECT @wk_law_amt1 =ISNULL(SUM(ISNULL(kc_law_amt1, 0)), 0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no and ((kc_law_code ='C' and kc_law_fmt in ('C5','CA','CC','CI','CJ')) or (kc_law_code in('F','4')) or (kc_law_code ='C' and kc_law_fmt in ('CF' ))or (kc_law_code ='K' and kc_law_fmt in ('K0' )))
		SELECT @wk_law_sum = @wk_law_amt + @wk_law_amt1
	END

	SELECT @wk_emp_name = '', @wk_emp_code = ''
	SELECT @wk_emp_name = DelegateName, @wk_emp_code = DelegateUser FROM kcsd.Delegate WHERE DelegateCode = @wk_pusher_code

	--計算查訪成本、認列違約金
	IF @wk_law_sum > 0
	BEGIN
		SELECT @wk_appt_cost = COUNT(*) * 200 FROM kcsd.kc_apptschedule 
		WHERE kc_case_no = @wk_case_no
		AND kc_appt_stat <> 'X'
		AND kc_appt_date BETWEEN @wk_strt_date AND @wk_stop_date	
	END
	--取最後一筆繳款日的違約金 
	SELECT TOP 1 @wk_break_sum2 = kc_break_fee
	FROM (
		SELECT	ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0) as kc_break_fee, kc_pay_date
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND		kc_pay_date BETWEEN  @wk_pstrt_date AND @wk_pstop_date
		GROUP BY kc_pay_date
	) X
	ORDER BY kc_pay_date DESC
	--認列違約金
	SELECT @wk_recog_amt = @wk_break_sum2 - @wk_appt_cost
	IF @wk_recog_amt < 0
		SELECT @wk_recog_amt = 0
	SELECT @wk_recog_amt = @wk_recog_amt + (@wk_break_sum - @wk_break_sum2)

	--新增至table
	IF	@wk_over_amt > 0 or @wk_pay_sum > 0 or @wk_pay_sum1 > 0 or @wk_pay_sum2 > 0
	BEGIN
		SELECT @wk_cust_nameu='',@wk_loan_desc=''		
		SELECT @wk_cust_nameu = c.kc_cust_nameu,@wk_loan_desc = l.kc_loan_desc FROM kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus l ON c.kc_loan_stat = l.kc_loan_stat WHERE c.kc_case_no = @wk_case_no		
		INSERT #tmp_pushonhand
			   ( kc_case_no, kc_area_code, kc_area_desc, kc_pusher_code, kc_strt_date, kc_close_date, kc_over_amt, kc_pay_sum,kc_pay_sum1, kc_pay_sum2, kc_intr_sum, kc_break_sum, kc_law_sum, kc_sales_sum, kc_delay_code, kc_buy_date, kc_cust_nameu, kc_emp_name, kc_loan_desc, kc_recog_amt)
		VALUES (@wk_case_no,@wk_area_code,@wk_area_desc,@wk_pusher_code,@wk_strt_date, @wk_stop_date,@wk_over_amt,@wk_pay_sum,@wk_pay_sum1,@wk_pay_sum2,@wk_intr_sum,@wk_break_sum,@wk_law_sum,@wk_sales_amt,@wk_expt_cont,@wk_buy_date,@wk_cust_nameu,@wk_emp_name,@wk_loan_desc,@wk_recog_amt)
	END
FETCH NEXT FROM c1 INTO @wk_case_no,@wk_area_code,@wk_area_desc,@wk_pusher_code,@wk_strt_date,@wk_stop_date
END
CLOSE c1
DEALLOCATE c1

--直接移除當月份轉派且無回收金額(委派金額算給下一個催收人) 連續刪5次
DECLARE @_i INT
SET @_i = 0
WHILE (@_i < 5)
BEGIN
	DELETE FROM #tmp_pushonhand
	WHERE EXISTS
		(SELECT b.kc_case_no
		FROM #tmp_pushonhand b
		GROUP BY b.kc_case_no
		 HAVING count(b.kc_case_no)>1
		 AND #tmp_pushonhand.kc_case_no = b.kc_case_no
		 AND #tmp_pushonhand.kc_strt_date = MIN(b.kc_strt_date)
		)
	AND kc_pay_sum = 0
	AND kc_intr_sum = 0
	AND kc_break_sum = 0	
	Set @_i=@_i+1
END


IF	@pm_run_code = 'EXECUTE'
BEGIN
	
	DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_pushonhand_law where kc_push_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_pushonhand_law
		SELECT convert(varchar(6),@pm_strt_date,112) as kc_pusher_date,p.kc_area_code,c.kc_prod_type,p.kc_pusher_code,'' as kc_user_name,count(p.kc_case_no) as kc_push_cnt,sum(p.kc_over_amt) as kc_over_amt,SUM( CASE WHEN kc_pay_sum > 0  THEN 1 ELSE 0 END) as kc_pay_cnt,sum(kc_pay_sum) as kc_pay_sum,sum(kc_pay_sum1) as kc_pay_sum1,sum(kc_intr_sum) as kc_intr_sum,Sum([kc_pay_sum]-[kc_intr_sum]) as kc_pay_amt,sum(kc_break_sum) as kc_break_sum
		FROM #tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		GROUP BY p.kc_pusher_code,p.kc_area_code,c.kc_prod_type
		ORDER by p.kc_pusher_code,p.kc_area_code,c.kc_prod_type
	END

END
ELSE
BEGIN
	SELECT	* 
	FROM	#tmp_pushonhand
	ORDER BY kc_pusher_code,kc_case_no
END



-- 20200629 測試報表

/*

IF	@pm_run_code = 'EXECUTE'
BEGIN
	
	DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_pushonhand_law where kc_push_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_pushonhand_law


		SELECT  c.kc_case_no,p.kc_area_code,p.kc_over_amt as kc_over_amt_a01,c.kc_buy_date ,c.kc_birth_date , (case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20
		FROM #tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		where c.kc_buy_date between '2019-01-01' and '2019-12-31'
		and c.kc_prod_type = '01'
		union
		SELECT  c.kc_case_no,p.kc_area_code,p.kc_over_amt as kc_over_amt_a07,c.kc_buy_date ,c.kc_birth_date , (case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20
		FROM #tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
		where c.kc_buy_date between '2019-01-01' and '2019-12-31'
		and c.kc_prod_type = '07'


	END

END
ELSE
BEGIN

	SELECT	c.kc_case_no,p.kc_area_code,p.kc_over_amt as a01 ,0 as a07,c.kc_buy_date ,c.kc_birth_date , (case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20
	FROM	#tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
	where c.kc_buy_date between '2019-01-01' and '2019-12-31'
	and c.kc_prod_type = '01'
	union
    SELECT	c.kc_case_no,p.kc_area_code,0 as a01,p.kc_over_amt as a07,c.kc_buy_date ,c.kc_birth_date , (case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20
	FROM	#tmp_pushonhand p left join kcsd.kc_customerloan c on c.kc_case_no = p.kc_case_no
	where c.kc_buy_date between '2019-01-01' and '2019-12-31'
	and c.kc_prod_type = '07'
END
*/


DROP TABLE #tmp_pushonhand

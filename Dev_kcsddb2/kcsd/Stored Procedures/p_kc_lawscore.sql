-- ==========================================================================================
-- 01/05/08 新增 kc_intr_fee 計算
-- 20160624 增加欄位,增加區域條件
-- 20200507 程序費新增 K/K0
-- 20211122 新增查訪成本、認列違約金
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_lawscore] @pm_strt_date datetime, @pm_stop_date datetime,@pm_user_code varchar(100)=NULL,@pm_area_code varchar(100)=NULL
AS

DECLARE	@wk_case_no		varchar(10),
	@wk_area_code 		varchar(2),
	@wk_pay_date		datetime,
	@wk_pay_fee			int,
	@wk_break_fee		int,
	@wk_intr_fee		int,
	@wk_pusher_code		varchar(6),
	@wk_cust_nameu		nvarchar(60),
	@wk_emp_name		varchar(10),
	@wk_emp_code		varchar(4),
	@wk_rece_code		varchar(2),
	@wk_loan_desc		varchar(10),
	@wk_strt_date		datetime,
	@wk_stop_date		datetime,
	@wk_law_amt			int,
	@wk_law_amt1		int,
	@wk_prepay_sum		int,
	@wk_pay_daten		datetime,
	@wk_appt_cost		int,
	@wk_recog_amt		int


CREATE TABLE #tmp_pushscore
(
	kc_case_no			varchar(10),
	kc_pay_date			datetime,
	kc_pay_fee			int,
	kc_break_fee		int,
	kc_intr_fee			int,
	kc_pusher_code		varchar(6),
	kc_cust_nameu		nvarchar(60),
	kc_emp_name			varchar(10),
	kc_rece_code		varchar(2),
	kc_loan_desc		varchar(10),
	kc_strt_date		datetime,
	kc_law_amt			int,
	kc_appt_cost		int,
	kc_recog_amt		int
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
FOR	SELECT	l.kc_case_no,l.kc_pay_date
	FROM	kcsd.kc_loanpayment l, kcsd.kc_customerloan c
	WHERE	l.kc_case_no = c.kc_case_no AND
			l.kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date AND 
			c.kc_area_code IN ( select kc_user_area from #tmp_userperm)
	GROUP BY l.kc_case_no,l.kc_pay_date
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pay_daten

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pay_date=NULL, @wk_pay_fee=0, @wk_break_fee=0, @wk_intr_fee=0,@wk_pusher_code=NULL,@wk_strt_date = NULL,@wk_law_amt = 0,@wk_law_amt1 = 0,@wk_appt_cost = 0, @wk_recog_amt = 0

	SELECT	@wk_pay_date = kc_pay_date, @wk_pay_fee = sum(kc_pay_fee), @wk_break_fee = sum(kc_break_fee), @wk_intr_fee = sum(kc_intr_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no AND
			kc_pay_date = @wk_pay_daten AND
			kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	GROUP BY kc_case_no,kc_pay_date

	-- 找出當時催收人
	SELECT	@wk_pusher_code = kc_pusher_code, @wk_strt_date = kc_strt_date, @wk_stop_date = kc_stop_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no AND
			kc_strt_date <= @wk_pay_date AND
			kc_stop_date >= @wk_pay_date

	-- 是否目前還在催收
	IF	@wk_pusher_code IS NULL
		SELECT	@wk_pusher_code = kc_pusher_code,@wk_strt_date = kc_strt_date
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no AND
				kc_strt_date <= @wk_pay_date AND
				kc_stop_date IS NULL

	IF @wk_pusher_code IS NOT NULL AND SUBSTRING(@wk_pusher_code,1,1) ='L'
	BEGIN 

		SELECT @wk_emp_name = DelegateName, @wk_emp_code = DelegateUser FROM kcsd.Delegate WHERE DelegateCode = @wk_pusher_code
		SELECT @wk_area_code = c.kc_area_code,@wk_cust_nameu = c.kc_cust_nameu, @wk_loan_desc = l.kc_loan_desc FROM kc_customerloan c LEFT JOIN kc_loanstatus l ON c.kc_loan_stat = l.kc_loan_stat WHERE c.kc_case_no = @wk_case_no
	
		--取C3 TYPE
		SELECT @wk_rece_code = CASE WHEN kc_rece_code = 'C3' THEN 'C3' END FROM kc_loanpayment l ,kc_customerloan c WHERE l.kc_case_no = c.kc_case_no AND c.kc_case_no = @wk_case_no AND kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	
		--取程序費
		IF (SELECT c.KC_PERD_FEE * c.KC_LOAN_PERD- sum(l.KC_PAY_FEE) as kc_expt_amt FROM kc_loanpayment l,kc_customerloan c WHERE l.kc_case_no = c.kc_case_no AND l.kc_case_no = @wk_case_no AND l.KC_PAY_DATE <= @wk_pay_date group by c.KC_PERD_FEE , c.KC_LOAN_PERD) = 0
		BEGIN 
			SELECT @wk_law_amt = ISNULL(Sum(ISNULL(kc_law_amt,0)),0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no and ((kc_law_code ='C' and kc_law_fmt in ('C0','C5','C7','CF','CK')) or (kc_law_code ='A' and kc_law_fmt in ('XB','XD')) or (kc_law_code ='G' and kc_law_fmt ='A7') or (kc_law_code ='X' and kc_law_fmt ='T5') or (kc_law_code ='E'))
 			SELECT @wk_law_amt1 = ISNULL(Sum(ISNULL(kc_law_amt1,0)),0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no and ((kc_law_code ='C' and kc_law_fmt in ('C5','CA','CC','CI','CJ')) or (kc_law_code in('F','4')) or (kc_law_code ='C' and kc_law_fmt in ('CF' ))or (kc_law_code ='K' and kc_law_fmt in ('K0' )))
		END

		--取查訪成本 有程序費才算 一件*200
		IF @wk_law_amt > 0 OR @wk_law_amt1 > 0
		BEGIN
			SELECT @wk_appt_cost = COUNT(*) * 200 FROM kcsd.kc_apptschedule 
			WHERE kc_case_no = @wk_case_no
			AND kc_appt_stat <> 'X'
			AND kc_appt_date BETWEEN @wk_strt_date AND @wk_stop_date
		END
		--認列違約金
		IF @wk_break_fee > @wk_appt_cost
		BEGIN
			SELECT @wk_recog_amt = @wk_break_fee - @wk_appt_cost
		END

		INSERT	#tmp_pushscore
				(kc_case_no, kc_pay_date,kc_pay_fee, kc_break_fee, kc_intr_fee, kc_pusher_code, kc_cust_nameu, kc_emp_name, kc_rece_code, kc_loan_desc, kc_strt_date,kc_law_amt, kc_appt_cost, kc_recog_amt)
		VALUES	(@wk_case_no,@wk_pay_date,@wk_pay_fee,@wk_break_fee,@wk_intr_fee,@wk_pusher_code,@wk_cust_nameu,@wk_emp_name,@wk_rece_code,@wk_loan_desc,@wk_strt_date,@wk_law_amt+@wk_law_amt1,@wk_appt_cost,@wk_recog_amt)
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pay_daten
END
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no


SELECT	*
FROM	#tmp_pushscore
ORDER BY kc_pusher_code


-- 20200629 測試報表

/*
select * ,(case  when  DATEADD (year , 20,x.kc_birth_date )< x.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20 from (
SELECT	p.kc_case_no, c.kc_area_code ,sum(kc_pay_fee)-sum(kc_intr_fee) as a01,0 as a07  ,kc_birth_date,kc_buy_date
FROM	#tmp_pushscore p
left join kcsd.kc_customerloan c on  p.kc_case_no = c.kc_case_no
where c.kc_buy_date between '2019-01-01' and '2019-12-31'
AND c.kc_prod_type = '01'
group by p.kc_case_no, c.kc_area_code , c.kc_birth_date , c.kc_buy_date
union
SELECT	p.kc_case_no,c.kc_area_code  ,0 as a01,SUM(kc_pay_fee)-sum(kc_intr_fee) as a07  ,kc_birth_date,kc_buy_date
FROM	#tmp_pushscore p
left join kcsd.kc_customerloan c on  p.kc_case_no = c.kc_case_no
where c.kc_buy_date between '2019-01-01' and '2019-12-31'
AND c.kc_prod_type = '07' 
group by p.kc_case_no, c.kc_area_code , c.kc_birth_date , c.kc_buy_date
) as x*/



DROP TABLE #tmp_pushscore

-- ==========================================================================================
-- 2016-02-03 (停用)轉法務對象平均分派給法催L01~L07(暫時不派給L04)
-- 2014-02-05 轉法務條件改為需連續兩個月無繳款且須停留在協商2個月以上
-- 2013-12-28 帳齡5個月以上, 且最近繳款日距今日在4個月前
-- 2013-04-16 改為只由逾3案件轉法務，包含逾期D與正常件G
-- 01/05/08 法務指派日改為當月1日, 前期結束日為上月最後1日
-- 08/12/06 KC: 指派結束日為執行當日之前1日
-- 08/05/06 KC: 指派開始日為執行當日
-- 07/16/06 KC: 已離職不指派
-- 9/1/05: 改為法務1,法務2,法務3, 不再指派到個人
-- 
-- previous:
-- 轉法務條件:
-- 1. 已有催款人
-- 2. 非法務
-- 3. 非外包
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_law(old)]
	@pm_run_code varchar(20)=NULL, @pm_age_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_due_date	datetime,		/* age_date+1 */
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */
	@wk_lpay_date	datetime,		/* 最後付款日 */
	@wk_lawyer_code	varchar(6),		/* 法務催款人 */
	@wk_pusher_code	varchar(6),		/* 原催款人 */
	@wk_circle_count int,			/* 目前輪到人員 */
	@wk_circle_limit int,			/* 共多少法務輪流 */
	@wk_row_count	int,	
	@wk_break_amt	int,			/* 違約金 */
	@wk_today_date	datetime,
	@wk_lstop_date	datetime,		-- 上月最後一天
	@wk_pstrt_date	datetime,		-- 本月第一天
	@wk_2mpay_cnt int,
	@wk_2mstay_cnt INT,
	@wk_pusher_count INT	

CREATE TABLE #tmp_pushassign_law
(kc_case_no	varchar(10),
kc_expt_sum	int,			/* 逾期金額 */
kc_arec_amt	int,			/* 未繳金額 */
kc_dday_count	int,			/* 逾期月數 */
kc_lpay_date	datetime,		/* 上次繳款日 */
kc_pusher_code	varchar(6),	/* 原催款人 */
kc_lawyer_code	varchar(6),		/* 新法務人員 */
kc_pusher_amt	int,			/* 指派金額 */
kc_break_amt	int,			/* 違約金 */
kc_strt_date	datetime,
kc_2mpay_cnt int,
kc_2mstay_cnt int,	
kc_pusher_type	varchar(10)
)

-- 預設為LA
SELECT	@wk_case_no=NULL, @wk_circle_count = 0, @wk_lawyer_code = 'LA'
-- 本月第一天
SELECT	@wk_pstrt_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
-- 上月最後一天
SELECT	@wk_lstop_date = DATEADD(day, -1, @wk_pstrt_date)
-- 分配法務輪流1~7 初始值1
SELECT @wk_pusher_count = 1;

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = @wk_lstop_date
END

SELECT	@wk_today_date = convert(varchar(10), getdate(), 101)

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

DECLARE	cursor_case_no_law	CURSOR
FOR	SELECT	c.kc_case_no
	FROM	kcsd.kc_customerloan c
	WHERE
		c.kc_buy_date <= @pm_age_date
	AND	c.kc_pusher_code LIKE 'S%'
	AND	c.kc_pusher_code <> 'S0'
	AND	c.kc_pusher_date < @wk_pstrt_date
	ORDER BY kc_case_no

print @wk_pstrt_date
OPEN cursor_case_no_law
FETCH NEXT FROM cursor_case_no_law INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL,	@wk_pusher_code = NULL, @wk_break_amt = 0

	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT
	--計算天數違約金
	EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt OUTPUT, @wk_due_date
	--計算最後繳款日
	SELECT	@wk_lpay_date = MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_pay_date < GETDATE()
	--兩個月前至今是否有繳款 (0 = 無任何繳款)
	--SELECT @wk_2mpay_cnt  = COUNT(*) FROM kcsd.kc_loanpayment  WHERE kc_case_no = @wk_case_no AND kc_pay_date BETWEEN DATEADD(mm,-2,@wk_due_date) AND @wk_due_date
	--是否已停留兩個月 (0 = 大於2個月)
	--SELECT @wk_2mstay_cnt  = COUNT(*) FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no AND kc_pusher_date BETWEEN DATEADD(mm,-2,@wk_due_date) AND @wk_due_date

	--兩個月前至今是否有繳款 (0 = 無任何繳款)
	SELECT @wk_2mpay_cnt = COUNT(kc_case_no) FROM kcsd.kc_loanpayment  WHERE kc_case_no = @wk_case_no AND kc_pay_date BETWEEN DATEADD(mm,-2,getdate()) AND getdate()
	--已停留月份
	SELECT @wk_2mstay_cnt = Datediff(mm,(SELECT MAX(kc_stop_date) FROM kcsd.kc_pushassign WHERE kc_case_no = @wk_case_no AND kc_pusher_code LIKE 'P%'),@wk_lstop_date)


	--兩個月前至今無任何繳款且已停留兩個月
	IF	@wk_2mpay_cnt = 0 AND @wk_2mstay_cnt >=2
	BEGIN

		--取得基本資料
		SELECT	@wk_pusher_code = kc_pusher_code
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no
/*
		SELECT	@wk_row_count = @wk_circle_count + 1			

		SET ROWCOUNT @wk_row_count

		SELECT	@wk_lawyer_code = kc_emp_code
		FROM	#tmp_law_pusher
		ORDER BY kc_emp_code
			
		SET ROWCOUNT 0

		SELECT	@wk_circle_count = (@wk_circle_count+1 ) % @wk_circle_limit
*/
		--轉法務對象平均分派給法催L01~L07(暫時不派給L04)
/*
		SELECT @wk_pusher_code = 'L0' + CONVERT(varchar(1),@wk_pusher_count)
		SELECT @wk_pusher_count = @wk_pusher_count + 1
		--排除L04
		IF @wk_pusher_count = 4
		BEGIN
			SELECT @wk_pusher_count = @wk_pusher_count + 1
		END
		--1~7
		IF @wk_pusher_count > 7
		BEGIN
			SELECT @wk_pusher_count = 1
		END
*/

		INSERT	#tmp_pushassign_law
			(kc_case_no, kc_expt_sum, kc_arec_amt,
			kc_dday_count, kc_lpay_date,
			kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,
			kc_strt_date,kc_2mpay_cnt,kc_2mstay_cnt,kc_pusher_type)

		VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,

			DATEDIFF(month, @wk_dday_date, @pm_age_date), @wk_lpay_date,
			@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
			@wk_pstrt_date,@wk_2mpay_cnt,@wk_2mstay_cnt,'轉法務')

		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			-- 結束原來指派
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = @wk_lstop_date
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL

			--新增法務指派
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_pusher_amt, kc_break_amt,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, @wk_pstrt_date, @wk_lawyer_code, 'MX',
				@wk_over_amt, @wk_break_amt,
				USER, GETDATE())

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_pstrt_date,
				kc_delay_code = 'MX'
			WHERE	kc_case_no = @wk_case_no
		END
	END
	ELSE
	BEGIN
		INSERT	#tmp_pushassign_law
			(kc_case_no, kc_expt_sum, kc_arec_amt,
			kc_dday_count, kc_lpay_date,
			kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,
			kc_strt_date,kc_2mpay_cnt,kc_2mstay_cnt,kc_pusher_type)

		VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,

			DATEDIFF(month, @wk_dday_date, @pm_age_date), @wk_lpay_date,
			@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
			@wk_pstrt_date,@wk_2mpay_cnt,@wk_2mstay_cnt,'不轉法務')
	END		

	FETCH NEXT FROM cursor_case_no_law INTO @wk_case_no
END

DROP TABLE #tmp_pushassign_law

--SELECT * FROM #tmp_pushassign_law
/*
SELECT *
FROM	#tmp_pushassign_law
ORDER BY kc_case_no

DEALLOCATE	cursor_case_no_law

DROP TABLE #tmp_law_pusher
*/

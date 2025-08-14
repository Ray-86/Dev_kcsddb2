-- ==========================================================================================
-- 2017-05-31 去除排除L04條件
-- 2016-11-28 新增轉出人員L08,09
-- 2016-02-03 轉法務LA條件為 需連續三個月無繳款且委派滿三個月(排除D1,D2)
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_LtoLA(old)]
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
	@wk_lstop_date	datetime,		-- 委派停止日
	@wk_pstrt_date	datetime,		-- 委派開始日
	@wk_area_code	varchar(2),		-- 公司別
	@wk_month_first_date	datetime,		-- 本月第一天
	@wk_month_last_date	datetime,		-- 上月最後一天
	@wk_2mpay_cnt int,
	@wk_2mstay_cnt int,
	@wk_3mlawstatus_cnt int	

CREATE TABLE #tmp_pushassign_LtoLA
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
-- 委派開始日
SELECT	@wk_pstrt_date = convert(varchar(10), getdate(), 101)
-- 委派停止日
SELECT	@wk_lstop_date = DATEADD(day, -1, @wk_pstrt_date)
-- 本月第一天
SELECT	@wk_month_first_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
-- 上月最後一天
SELECT	@wk_month_last_date = DATEADD(day, -1, @wk_pstrt_date)

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = @wk_month_last_date
END

SELECT	@wk_today_date = convert(varchar(10), getdate(), 101)

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

DECLARE	cursor_case_no_LtoLA	CURSOR
FOR	SELECT	c.kc_case_no
	FROM	kcsd.kc_customerloan c
	WHERE
		c.kc_pusher_code IN('L01','L02','L03','L04','L05','L06','L07','L08','L09')
	AND	c.kc_pusher_date < @wk_pstrt_date
	ORDER BY kc_case_no

print @wk_pstrt_date
OPEN cursor_case_no_LtoLA
FETCH NEXT FROM cursor_case_no_LtoLA INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL,	@wk_pusher_code = NULL, @wk_break_amt = 0

	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT
	--計算天數違約金
	EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt OUTPUT, @wk_due_date
	--計算最後繳款日
	SELECT	@wk_lpay_date = MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_pay_date < GETDATE()
	--三個月前至今是否有繳款 (0 = 無任何繳款)
	SELECT @wk_2mpay_cnt = COUNT(kc_case_no) FROM kcsd.kc_loanpayment  WHERE kc_case_no = @wk_case_no AND kc_pay_date BETWEEN DATEADD(mm,-3,getdate()) AND getdate()
	--已停留月份
	SELECT @wk_2mstay_cnt = Datediff(mm,(SELECT MAX(kc_strt_date) FROM kcsd.kc_pushassign WHERE kc_case_no = @wk_case_no AND kc_pusher_code LIKE 'L0%'),@wk_lstop_date)
	--三個月內催告有拉紀錄 (0 = 無任何紀錄)
	SELECT @wk_3mlawstatus_cnt = COUNT(kc_case_no) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no AND (kc_law_date BETWEEN DATEADD(mm,-3,getdate()) AND getdate()) AND kc_law_fmt IN ('CF','CJ','CK','K0','K1','K2','K3','K4','K6','K9','KB','KE','T2','T5','X5','X6','XB','XH')
	
	--已停留三個月 且三個月前至今無任何繳款 且催告沒有登記
	IF	@wk_2mstay_cnt >=3 AND @wk_2mpay_cnt = 0 AND @wk_3mlawstatus_cnt = 0
	BEGIN

		--取得基本資料
		SELECT	@wk_pusher_code = kc_pusher_code,@wk_area_code = kc_area_code
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no


		INSERT	#tmp_pushassign_LtoLA
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
				kc_pusher_amt, kc_break_amt, kc_updt_user, kc_updt_date , kc_area_code)
			VALUES	(@wk_case_no, @wk_pstrt_date, @wk_lawyer_code, 'MX',
				@wk_over_amt, @wk_break_amt, USER, GETDATE(), @wk_area_code)

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_pstrt_date,
				kc_delay_code = 'MX'
			WHERE	kc_case_no = @wk_case_no
		END
	END
	ELSE
	BEGIN
		INSERT	#tmp_pushassign_LtoLA
			(kc_case_no, kc_expt_sum, kc_arec_amt,
			kc_dday_count, kc_lpay_date,
			kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,
			kc_strt_date,kc_2mpay_cnt,kc_2mstay_cnt,kc_pusher_type)

		VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,

			DATEDIFF(month, @wk_dday_date, @pm_age_date), @wk_lpay_date,
			@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
			@wk_pstrt_date,@wk_2mpay_cnt,@wk_2mstay_cnt,'不轉法務')
	END		

	FETCH NEXT FROM cursor_case_no_LtoLA INTO @wk_case_no
END
	CLOSE cursor_case_no_LtoLA
	SELECT * FROM #tmp_pushassign_LtoLA
	DROP TABLE #tmp_pushassign_LtoLA

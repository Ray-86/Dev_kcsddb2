-- ==========================================================================================
-- 2016-02-03 LA轉L(排除L04)新件
-- 2017-05-31 去除排除L04條件
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_LAtoLN(old)]
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
	@wk_area_code	varchar(2),		-- 公司別
	@wk_today_date	datetime,
	@wk_lstop_date	datetime,		-- 上月最後一天
	@wk_pstrt_date	datetime,		-- 本月第一天
	@wk_yesterday_date	DATETIME,   -- 前一天
	@wk_2mpay_cnt int,
	@wk_2mstay_cnt int,
	@wk_pusher_count INT	

CREATE TABLE #tmp_pushassign_LAtoL
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
SELECT	@wk_case_no=NULL, @wk_circle_count = 0, @wk_lawyer_code = 'LA',@wk_pusher_count = 1
-- 本月第一天
SELECT	@wk_today_date = DATEADD(dd, DATEDIFF(dd,0,getdate()), 0)
-- 本月第一天
SELECT	@wk_pstrt_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
-- 上月最後一天
SELECT	@wk_lstop_date = DATEADD(day, -1, @wk_pstrt_date)
-- 執行前一天
SELECT	@wk_yesterday_date = DATEADD(day, -1, GETDATE())

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = @wk_lstop_date
END

--SELECT	@wk_today_date = convert(varchar(10), getdate(), 101)

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

DECLARE	cursor_case_no_LAtoLN	CURSOR
FOR	SELECT DISTINCT p.kc_case_no
	FROM kcsd.kc_pushassign p
	WHERE p.kc_pusher_code = 'LA'
	AND p.kc_strt_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)  --@wk_pstrt_date
	AND p.kc_stop_date IS NULL
	AND p.kc_updt_date BETWEEN (DATEADD(mm, DATEDIFF(mm,0,getdate()), 0) + 9) AND (DATEADD(mm, DATEDIFF(mm,0,getdate()), 0) + 10) --當月10號更新
	ORDER BY p.kc_case_no

print @wk_pstrt_date
OPEN cursor_case_no_LAtoLN
FETCH NEXT FROM cursor_case_no_LAtoLN INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL,	@wk_pusher_code = NULL, @wk_break_amt = 0

	--取得基本資料
	SELECT	@wk_pusher_code = kc_pusher_code , @wk_area_code = kc_area_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
	
	--派給L01~L07
	SELECT @wk_lawyer_code = 'L0' + CONVERT(varchar(1),@wk_pusher_count)
	SELECT @wk_pusher_count = @wk_pusher_count + 1
	----排除L04
	--IF @wk_pusher_count = 4
	--BEGIN
	--	SELECT @wk_pusher_count = @wk_pusher_count + 1
	--END
	--1~7
	IF @wk_pusher_count > 7
	BEGIN
		SELECT @wk_pusher_count = 1
	END

	INSERT	#tmp_pushassign_LAtoL
		(kc_case_no, kc_expt_sum, kc_arec_amt,
		kc_dday_count, kc_lpay_date,
		kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,
		kc_strt_date,kc_2mpay_cnt,kc_2mstay_cnt,kc_pusher_type)

	VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,

		DATEDIFF(month, @wk_dday_date, @pm_age_date), @wk_lpay_date,
		@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
		@wk_today_date,@wk_2mpay_cnt,@wk_2mstay_cnt,'轉法務')

	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		-- 結束原來指派
		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @wk_yesterday_date
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL

		--新增法務指派
		INSERT	kcsd.kc_pushassign
			(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
			kc_pusher_amt, kc_break_amt, kc_updt_user, kc_updt_date, kc_area_code)
		VALUES	(@wk_case_no, @wk_today_date, @wk_lawyer_code, 'MX',
			@wk_over_amt, @wk_break_amt, USER, GETDATE(), @wk_area_code)

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_today_date,
			kc_delay_code = 'MX', kc_push_sort = 'X'
		WHERE	kc_case_no = @wk_case_no
	END
		
	FETCH NEXT FROM cursor_case_no_LAtoLN INTO @wk_case_no
END
	CLOSE cursor_case_no_LAtoLN
	--SELECT * FROM #tmp_pushassign_LAtoL
	DROP TABLE #tmp_pushassign_LAtoL

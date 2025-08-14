

-- ==========================================================================================
-- 2017-10-20 改為每月15日派至L01~L10
-- 2017-05-31 去除排除L04條件
-- 2016-02-03 LA轉L(排除L04)新件
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_LAtoL]
	@pm_run_code varchar(20)=NULL, @pm_age_date datetime=NULL
AS
DECLARE	
	@wk_case_no		VARCHAR(10),
	@wk_due_date		DATETIME,		/* age_date+1 */
	@wk_over_amt		INT,			/* 逾期金額 */
	@wk_arec_amt		INT,			/* 未繳金額 */
	@wk_dday_date		DATETIME,		/* dummy for p_kc_getoveramt */
	@wk_lpay_date		DATETIME,		/* 最後付款日 */
	@wk_lawyer_code		VARCHAR(6),		/* 法務催款人 */
	@wk_pusher_code		VARCHAR(6),		/* 原催款人 */
	@wk_circle_count	INT,			/* 目前輪到人員 */
	@wk_circle_limit	INT,			/* 共多少法務輪流 */
	@wk_row_count		INT,	
	@wk_break_amt		INT,			/* 違約金 */
	@wk_area_code		VARCHAR(2),		-- 公司別
	@wk_today_date		DATETIME,
	@wk_lstop_date		DATETIME,		-- 上月最後一天
	@wk_pstrt_date		DATETIME,		-- 本月第一天
	@wk_yesterday_date	DATETIME,		-- 前一天
	@wk_2mpay_cnt		INT,
	@wk_2mstay_cnt		INT

CREATE TABLE #tmp_pushassign_LAtoL
(
	kc_case_no			VARCHAR(10),
	kc_expt_sum			INT,			/* 逾期金額 */
	kc_arec_amt			INT,			/* 未繳金額 */
	kc_dday_count		INT,			/* 逾期月數 */
	kc_lpay_date		DATETIME,		/* 上次繳款日 */
	kc_pusher_code		VARCHAR(6),		/* 原催款人 */
	kc_lawyer_code		VARCHAR(6),		/* 新法務人員 */
	kc_pusher_amt		INT,			/* 指派金額 */
	kc_break_amt		INT,			/* 違約金 */
	kc_strt_date		DATETIME,
	kc_2mpay_cnt		INT,
	kc_2mstay_cnt		INT,	
	kc_pusher_type		VARCHAR(10)
)

-- 預設為LA
SELECT	@wk_case_no=NULL, @wk_lawyer_code = 'LA',@wk_circle_count = 1
-- 本月第一天
SELECT	@wk_today_date = DATEADD(DAY, DATEDIFF(dd,0,GETDATE()), 0)
-- 本月第一天
SELECT	@wk_pstrt_date = DATEADD(MONTH, DATEDIFF(mm,0,GETDATE()), 0)
-- 上月最後一天
SELECT	@wk_lstop_date = DATEADD(DAY, -1, @wk_pstrt_date)
-- 執行前一天
SELECT	@wk_yesterday_date = DATEADD(DAY, -1, GETDATE())
--取得總共委派個數
SELECT @wk_circle_limit = COUNT(*) FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = @wk_lstop_date
END

SELECT	@wk_due_date = DATEADD(DAY, 1, @pm_age_date)

DECLARE	cursor_case_no_LAtoL	CURSOR
FOR	
	SELECT kc_case_no
	FROM kcsd.kc_customerloan
	WHERE kc_pusher_code = 'LA'
	ORDER BY kc_case_no
print @wk_pstrt_date
OPEN cursor_case_no_LAtoL
FETCH NEXT FROM cursor_case_no_LAtoL INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL,	@wk_pusher_code = NULL, @wk_break_amt = 0

	--取得基本資料
	SELECT	@wk_pusher_code = kc_pusher_code , @wk_area_code = kc_area_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
	
	--取得委派人員
	SELECT @wk_lawyer_code = DelegateCode FROM ( 
		SELECT ROW_NUMBER() OVER (ORDER BY DelegateCode) AS RowId, * FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 
	) AS A WHERE A.RowId = @wk_circle_count
	SELECT @wk_circle_count = @wk_circle_count + 1

	IF @wk_circle_count > @wk_circle_limit
	BEGIN
		SELECT @wk_circle_count = 1
	END

	INSERT	#tmp_pushassign_LAtoL
		(kc_case_no, kc_expt_sum, kc_arec_amt,
		kc_dday_count, kc_lpay_date,
		kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,
		kc_strt_date,kc_2mpay_cnt,kc_2mstay_cnt,kc_pusher_type)

	VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,
		DATEDIFF(MONTH, @wk_dday_date, @pm_age_date), @wk_lpay_date,
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
		
	FETCH NEXT FROM cursor_case_no_LAtoL INTO @wk_case_no
END
	CLOSE cursor_case_no_LAtoL
	SELECT * from #tmp_pushassign_LAtoL
	DROP TABLE #tmp_pushassign_LAtoL

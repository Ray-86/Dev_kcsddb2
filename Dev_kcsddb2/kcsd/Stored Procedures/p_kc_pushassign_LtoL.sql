
-- ==========================================================================================
-- 2020-06-05 新增'AK3','AK5','AK7','CCQ','CCR','CCS','CCT'不轉出
-- 2018-03-22 未超過半年不轉出
-- 2017-10-20 改為每年5/1及11/1執行 將365日內未繳錢轉出 若有90日有催告(E/A4,G/A7,A/X6,C/CF,C/CL,C/CJ,A/XB,A/XC,A/XF,KK0)
-- 2017-05-31 去除排除L04條件
-- 2016-11-28 新增轉出人員L08,09
-- 2016-02-03 轉法務LA條件為 需連續三個月無繳款且委派滿三個月(排除D1,D2)
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_LtoL] @pm_run_code VARCHAR(20) = NULL, @pm_age_date DATETIME = NULL
AS
DECLARE	
	@wk_case_no				VARCHAR(10),
	@wk_due_date			DATETIME,		/* age_date+1 */
	@wk_over_amt			INT,			/* 逾期金額 */
	@wk_arec_amt			INT,			/* 未繳金額 */
	@wk_dday_date			DATETIME,		/* dummy for p_kc_getoveramt */
	@wk_lpay_date			DATETIME,		/* 最後付款日 */
	@wk_lawyer_code			VARCHAR(6),		/* 法務催款人 */
	@wk_pusher_code			VARCHAR(6),		/* 原催款人 */
	@wk_circle_count		INT,			/* 目前輪到人員 */
	@wk_circle_limit		INT,			/* 共多少法務輪流 */
	@wk_row_count			INT,	
	@wk_break_amt			INT,			/* 違約金 */
	@wk_today_date			DATETIME,
	@wk_lstop_date			DATETIME,		-- 委派停止日
	@wk_pstrt_date			DATETIME,		-- 委派開始日
	@wk_area_code			VARCHAR(2),		-- 公司別
	@wk_month_first_date	DATETIME,		-- 本月第一天
	@wk_month_last_date		DATETIME,		-- 上月最後一天
	@wk_total_pay_count		int,			-- 過去365天共繳次數
	@wk_total_law_count		int,			-- 過去90天登記催告代碼
	@wk_car_stat			varchar(1),		-- 車況
	@wk_max_date			DATETIME,
	@wk_push_sort			VARCHAR(2)

CREATE TABLE #tmp_pushassign_LtoL
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
	kc_max_date			DATETIME,
	kc_push_sort		VARCHAR(2),
	kc_pusher_type		VARCHAR(10)
)

-- 預設為LA
SELECT	@wk_case_no=NULL, @wk_lawyer_code = 'LA', @wk_circle_count = 1, @wk_circle_limit = 1
-- 委派開始日
SELECT	@wk_pstrt_date = CONVERT(VARCHAR(10), GETDATE(), 101)
-- 委派停止日
SELECT	@wk_lstop_date = DATEADD(DAY, -1, @wk_pstrt_date)
-- 本月第一天
SELECT	@wk_month_first_date = DATEADD(MONTH, DATEDIFF(mm,0,GETDATE()), 0)
-- 上月最後一天
SELECT	@wk_month_last_date = DATEADD(DAY, -1, @wk_pstrt_date)

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL
BEGIN
	SELECT	@pm_age_date = @wk_month_last_date
END
SELECT	@wk_today_date = CONVERT(varchar(10), GETDATE(), 101)
SELECT	@wk_due_date = DATEADD(DAY, 1, @pm_age_date)

DECLARE	cursor_case_no_LtoL	CURSOR
FOR	
	SELECT DelegateCode FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1
OPEN cursor_case_no_LtoL
FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_pusher_code

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--取得總共委派個數
	SELECT @wk_circle_limit = COUNT(*) FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 AND DelegateCode <> @wk_pusher_code
	SELECT @wk_circle_count = 1

	DECLARE	cursor_case_no_LtoL_sub	CURSOR
	FOR	
		SELECT	kc_case_no
		FROM	kcsd.kc_customerloan c
		WHERE	kc_pusher_code = @wk_pusher_code
				AND kc_pusher_date < CONVERT(VARCHAR(10),GETDATE(),111)
		ORDER BY kc_case_no
	OPEN cursor_case_no_LtoL_sub
	FETCH NEXT FROM cursor_case_no_LtoL_sub INTO @wk_case_no

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		SELECT	@wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL, @wk_break_amt = 0
		EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT
		--計算天數違約金
		EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt OUTPUT, @wk_due_date
		--計算最後繳款日
		SELECT	@wk_lpay_date = MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_pay_date < GETDATE()
		--過去365天共繳次數
		SELECT @wk_total_pay_count = COUNT(kc_case_no) FROM kcsd.kc_loanpayment  WHERE kc_case_no = @wk_case_no AND kc_pay_date BETWEEN DATEADD(DAY, -365, GETDATE()) AND GETDATE()
		--過去90天登記催告代碼
		SELECT @wk_total_law_count = COUNT(kc_case_no) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no AND (kc_law_date BETWEEN DATEADD(DAY, -90, GETDATE()) AND GETDATE()) AND kc_law_code+kc_law_fmt IN 
		('EA4','GA7','AX5','AX6','CCF','CCL','CCJ','AXB','AXC','AXF','KK0','CCA','CCB','CCC','CCD','CCI','CCK','CCP','CCN','CCM','AK3','AK5','AK7','CCQ','CCR','CCS','CCT')
		--最後委派日
		SELECT @wk_max_date = max(kc_strt_date) FROM kcsd.kc_pushassign WHERE kc_case_no = @wk_case_no
		--車況
		SELECT @wk_car_stat = ISNULL(kc_car_stat,'') FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
		--分類
		SELECT @wk_push_sort = ISNULL(kc_push_sort,'') FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
		--PRINT @wk_pusher_code + '-' + @wk_case_no + '-' + CONVERT(VARCHAR(10),@wk_total_law_count) + '-' + CONVERT(VARCHAR(10),@wk_total_pay_count) + '-' + ISNULL(@wk_car_stat,'X')
		--過去365天至今無任何繳款 且 過去90天沒有催告登記 且 車況不為載回
		IF	@wk_total_pay_count = 0 AND @wk_total_law_count = 0 AND @wk_car_stat <> 'C' AND (DATEADD(MONTH, -6, @wk_month_first_date) > @wk_max_date)
		BEGIN
			--取得基本資料
			SELECT	@wk_area_code = kc_area_code
			FROM	kcsd.kc_customerloan
			WHERE	kc_case_no = @wk_case_no

			--取得委派人員
			SELECT @wk_lawyer_code = DelegateCode FROM ( 
				SELECT ROW_NUMBER() OVER (ORDER BY DelegateCode) AS RowId, * FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 AND DelegateCode <> @wk_pusher_code
			) AS A WHERE A.RowId = @wk_circle_count
			SELECT @wk_circle_count = @wk_circle_count + 1
			IF @wk_circle_count > @wk_circle_limit
			BEGIN
				SELECT @wk_circle_count = 1
			END

			INSERT	#tmp_pushassign_LtoL
				(kc_case_no, kc_expt_sum, kc_arec_amt,kc_dday_count, kc_lpay_date,kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,kc_strt_date,kc_max_date,kc_push_sort,kc_pusher_type)
			VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,DATEDIFF(MONTH, @wk_dday_date, @pm_age_date), @wk_lpay_date,@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,@wk_pstrt_date,@wk_max_date,@wk_push_sort,'轉派')

			IF	@pm_run_code = 'EXECUTE'
			BEGIN
				-- 結束原來指派
				UPDATE	kcsd.kc_pushassign
				SET	kc_stop_date = @wk_lstop_date
				WHERE	kc_case_no = @wk_case_no
					AND	kc_stop_date IS NULL

				--新增法務指派
				INSERT	kcsd.kc_pushassign
					(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,kc_pusher_amt, kc_break_amt, kc_updt_user, kc_updt_date , kc_area_code)
					VALUES	(@wk_case_no, @wk_pstrt_date, @wk_lawyer_code, 'MX',@wk_over_amt, @wk_break_amt, USER, GETDATE(), @wk_area_code)

				UPDATE	kcsd.kc_customerloan
				SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_pstrt_date
				WHERE	kc_case_no = @wk_case_no
			END
		END
		ELSE
		BEGIN
			INSERT	#tmp_pushassign_LtoL
				(kc_case_no, kc_expt_sum, kc_arec_amt,kc_dday_count, kc_lpay_date,kc_pusher_code, kc_lawyer_code, kc_pusher_amt, kc_break_amt,kc_strt_date,kc_max_date,kc_push_sort,kc_pusher_type)
			VALUES	(@wk_case_no, @wk_over_amt, @wk_arec_amt,DATEDIFF(MONTH, @wk_dday_date, @pm_age_date), @wk_lpay_date,@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,@wk_pstrt_date,@wk_max_date,@wk_push_sort,'不轉派')
		END		

		FETCH NEXT FROM cursor_case_no_LtoL_sub INTO @wk_case_no
	END
	CLOSE cursor_case_no_LtoL_sub
	DEALLOCATE cursor_case_no_LtoL_sub
	FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_pusher_code
END
CLOSE cursor_case_no_LtoL
DEALLOCATE cursor_case_no_LtoL
SELECT * FROM #tmp_pushassign_LtoL
DROP TABLE #tmp_pushassign_LtoL

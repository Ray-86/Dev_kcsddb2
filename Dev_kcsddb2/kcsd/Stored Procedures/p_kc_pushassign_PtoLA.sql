
-- ==========================================================================================
-- 2017-10-20 改為每月10日派到LA
-- 2017-05-31 去除排除L04條件
-- 2016-12-20 取消估車派走條件，改為逾期4期轉走
-- 2016-11-28 取消S0改直接派至L01~L09(不含L04) 並取消@wk_fig3_amt條件
-- 2015-10-14 取消新派件增加催告S代碼
-- 2015-09-03 新派件增加催告S代碼(所有地址)
-- 2015-07-06 新派件增加催告S代碼
-- 2014-04-08 取消估車件條件並改為估車件一率不委派
-- 2013-12-28 逾三個月指派給S0 協商暫存區
-- 2012-12-25 逾三個月指派給P09~PA9
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_PtoLA]
	@pm_run_code varchar(20)=NULL, @pm_age_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
    @wk_prod_type	varchar(2),
	@wk_due_date	datetime,		-- age_date+1
	@wk_over_amt	int,			-- 逾期金額
	@wk_arec_amt	int,			-- 未繳金額
	@wk_dday_date	datetime,		-- dummy for p_kc_getoveramt
	@wk_lpay_date	datetime,		-- 最後付款日
	@wk_lawyer_code	varchar(6),		-- 法務催款人
	@wk_pusher_count int,			-- 法務順序
	@wk_pusher_code	varchar(6),		-- 原催款人員
	@wk_break_amt	int,			-- 違約金
	@wk_today_date	datetime,		-- 今天日期
	@wk_lstop_date	datetime,		-- 上月最後一天
	@wk_pstrt_date	datetime,		-- 本月第一天
	@wk_area_code	varchar(2),		-- 分公司
	@wk_loan_stat	varchar(1),		-- 狀態
	@wk_fig0_date	datetime,		-- 
	@wk_fig0_amt	int,			-- 委派條件A1
	@wk_fig1_amt	int,			-- 委派條件A1
	@wk_fig2_amt	int,			-- 委派條件A2
	@wk_fig3_amt	int,			-- 委派條件B1
	@wk_fig4_amt	INT,			-- 委派條件B2
	@wk_fig5_amt	INT				-- 委派條件Carstat
	

CREATE TABLE #tmp_pushassign_PtoL
(kc_case_no	varchar(10),
kc_prod_type varchar(2),
kc_loan_stat	varchar(1),
kc_expt_sum	int,			-- 逾期金額 
kc_arec_amt	int,			-- 未繳金額 
kc_dday_date	datetime,		--  應繳日期
kc_lpay_date	datetime,		-- 上次繳款日
kc_age_date 	datetime,		-- 上月最後一天
kc_dday_count	int,			-- 逾期月數 
kc_lpay_count	int,			-- 最近繳款日逾期月數 
kc_pusher_code	varchar(6),	-- 原催款人員
kc_d3er_code	varchar(6),		-- 新催款人員 
kc_pusher_amt	int,			-- 指派金額 
kc_break_amt	int,			-- 違約金 
kc_strt_date	datetime,
kc_area_code	varchar(2),		--公司別
kc_fig0_date	datetime,		--最後估車入帳日
kc_fig0_amt		int,
kc_fig1_amt		int,
kc_fig2_amt		int,
kc_fig3_amt		int,
kc_fig4_amt		int,
kc_pusher_type	varchar(10)
)


-- INIT  預設為LA
SELECT	@wk_case_no=NULL, @wk_lawyer_code = 'LA',@wk_pusher_count = 1
-- 本月第一天
SELECT	@wk_pstrt_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
-- 上月最後一天
SELECT	@wk_lstop_date = DATEADD(mm, DATEDIFF(mm,0,getdate()), -1)

-- 參數為Null: 預設帳齡計算基準日為 上月最後一天
IF	@pm_age_date IS NULL 
BEGIN
	SELECT	@pm_age_date = @wk_lstop_date
END

SELECT	@wk_today_date = convert(varchar(10), getdate(), 101)

SELECT	@wk_due_date = DATEADD(day, 1, @pm_age_date)

DECLARE	cursor_case_no_PtoLA	CURSOR
FOR	

SELECT distinct	c.kc_case_no,c.kc_prod_type
	FROM	kcsd.kc_customerloan c
	WHERE
	(
	c.kc_buy_date <= @pm_age_date
	AND	c.kc_pusher_code IS NOT NULL
	AND	c.kc_pusher_code LIKE 'P%'
	AND	c.kc_loan_stat IN ('D','F')
	)
	ORDER BY c.kc_case_no

OPEN cursor_case_no_PtoLA
FETCH NEXT FROM cursor_case_no_PtoLA INTO @wk_case_no,@wk_prod_type

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @wk_over_amt = 0, @wk_arec_amt = 0, @wk_lpay_date = NULL, @wk_pusher_code = NULL, @wk_break_amt = 0,
		 @wk_fig0_amt = null,@wk_fig1_amt = null,@wk_fig2_amt = null,@wk_fig3_amt = null,@wk_fig4_amt = null
	-- 計算帳齡
	EXECUTE kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT
	IF	@wk_dday_date IS NULL
	BEGIN
		SELECT	@wk_dday_date = @pm_age_date
	END
	-- 計算天數違約金
	EXECUTE kcsd.p_kc_updateloanstatus_sub1 @wk_case_no, @wk_break_amt OUTPUT, @wk_due_date
	-- 計算最後繳款日
	SELECT @wk_lpay_date = MAX(kc_pay_date) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no	AND kc_pay_date < GETDATE()
	--檢查是否有選 (催款書、催告函、律函(催))
	SELECT @wk_fig1_amt = Count(kc_case_no) from kcsd.kc_lawstatus where kc_case_no = @wk_case_no and kc_law_code in ('B','L','O') 
	--檢查委派日前是否有查訪完成
	SELECT @wk_fig2_amt = Count(kc_case_no) from kcsd.kc_apptschedule where kc_case_no = @wk_case_no and kc_appt_type in( 'B','D') and kc_visit_outc is not null and kc_appt_date <= DATEADD(mm, DATEDIFF(mm,0,getdate()), 0)
	--檢查是否為C車已載回
	SELECT @wk_fig5_amt = Count(kc_case_no) from kcsd.kc_customerloan where kc_case_no = @wk_case_no and kc_car_stat = 'C'
	--取得分公司，16波波提前轉出
	SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where kc_case_no = @wk_case_no
	IF	(
		--非波波，帳齡4個月(含)以上
		(DATEDIFF(month, @wk_dday_date, @pm_age_date) >= 4)
		AND (@wk_lpay_date IS NULL OR DATEDIFF(month, @wk_lpay_date, @pm_age_date) >= 2) 		--最近繳款日至前一個月月底在2個月(含)以上
		AND	@wk_fig1_amt > 0	--沒寄信不派
		AND	((@wk_fig2_amt > 0 and @wk_prod_type != '10') or (@wk_prod_type = '10'))	--沒查訪不派
		AND	@wk_fig5_amt = 0	--車已載回不派
		)
	BEGIN
		-- 取得基本資料
		SELECT	@wk_pusher_code = kc_pusher_code,@wk_area_code=kc_area_code,@wk_loan_stat=kc_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		INSERT	#tmp_pushassign_PtoL
			(kc_case_no, kc_prod_type, kc_loan_stat,kc_expt_sum, kc_arec_amt,kc_dday_date,kc_lpay_date,kc_age_date,
			kc_dday_count,kc_lpay_count,
			kc_pusher_code, kc_d3er_code, kc_pusher_amt, kc_break_amt,
			kc_strt_date,kc_area_code,kc_fig0_amt,kc_fig1_amt,kc_fig2_amt,kc_fig3_amt,kc_fig4_amt,kc_pusher_type)
		VALUES	(@wk_case_no,@wk_prod_type,@wk_loan_stat, @wk_over_amt, @wk_arec_amt,@wk_dday_date, @wk_lpay_date, @pm_age_date,
			DATEDIFF(month, @wk_dday_date, @pm_age_date),
			DATEDIFF(month, @wk_lpay_date, @pm_age_date),
			@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
			@wk_pstrt_date,@wk_area_code,@wk_fig0_amt,@wk_fig1_amt,@wk_fig2_amt,@wk_fig3_amt,@wk_fig4_amt,'轉法務')

		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			-- 結束原來指派
			UPDATE kcsd.kc_pushassign SET kc_stop_date = @wk_lstop_date
			WHERE kc_case_no = @wk_case_no AND kc_stop_date IS NULL
			-- 新增法務指派
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code, kc_pusher_amt, kc_break_amt, kc_updt_user, kc_updt_date, kc_area_code)
			VALUES	(@wk_case_no, @wk_pstrt_date, @wk_lawyer_code, 'MX',@wk_over_amt, @wk_break_amt,USER, GETDATE() , @wk_area_code)

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_pstrt_date, kc_delay_code = 'MX',kc_push_sort = 'X'
			WHERE	kc_case_no = @wk_case_no
			
		END
	END
	ELSE
	BEGIN
		INSERT	#tmp_pushassign_PtoL
			(kc_case_no, kc_prod_type, kc_loan_stat,kc_expt_sum, kc_arec_amt,kc_dday_date,kc_lpay_date,kc_age_date,
			kc_dday_count,kc_lpay_count,
			kc_pusher_code, kc_d3er_code, kc_pusher_amt, kc_break_amt,
			kc_strt_date,kc_area_code,kc_fig0_amt,kc_fig1_amt,kc_fig2_amt,kc_fig3_amt,kc_fig4_amt,kc_pusher_type)
		VALUES	(@wk_case_no,@wk_prod_type,@wk_loan_stat, @wk_over_amt, @wk_arec_amt,@wk_dday_date, @wk_lpay_date, @pm_age_date,
			DATEDIFF(month, @wk_dday_date, @pm_age_date),
			DATEDIFF(month, @wk_lpay_date, @pm_age_date),
			@wk_pusher_code, @wk_lawyer_code, @wk_over_amt, @wk_break_amt,
			@wk_pstrt_date,@wk_area_code,@wk_fig0_amt,@wk_fig1_amt,@wk_fig2_amt,@wk_fig3_amt,@wk_fig4_amt,'不轉法務')
	END

	FETCH NEXT FROM cursor_case_no_PtoLA INTO @wk_case_no,@wk_prod_type
END

SELECT *
FROM	#tmp_pushassign_PtoL
ORDER BY kc_case_no

DEALLOCATE	cursor_case_no_PtoLA



--exec kcsd.p_kc_pushassign_PtoLA 'E'
-- ==========================================================================================
--2023-12-25 改依照M0/M1/M2委派分類
--2019-12-01 改為全公司案件派全部催收
--2019-09-17 高雄案件全改派回高雄
--2019-04-30 變更為逾期11天委派
--2019-01-30 增加苗栗派給台北
--2018-12-27 高雄1/3給台南
--2018-08-31 新竹全數派給台北
--2018-08-01 改派件寫法(可依公司別分比例派件)
--2017-11-21 增加特殊委派條件第三方公司助催
--2016/11/04 委派條件統一為7(便利商店)
--2014/02/26 新增宜蘭派件
--2013-08-29 委派增加紀錄當期應繳日
--2013-08-15 高雄、彰化、嘉義、屏東改為平均
--2012-10-25 新指派案件 狀態改為NULL
--2012-09-01 新竹改為平均
--07/10/2010 桃園也改為平均 P71, P72
--09/01/2008 高屏06改為全指派給P61
--01/12/2008 舊指派結束日改為->新指派日前1日
--01/05/2008 高屏06由台北催
--12/15/2007 指派日/結束日由 GETDATE 改為當日凌晨,以解決當日指派當日收款問題
--11/03/2003 KC: 業務換區以 kc_pusherarea 處理
--03/17/2004 KC: 依法務, 換區, 業務的順序處理
--10/02/2005 KC: 轉換 P1
--03/18/2006 KC: 台中也改為 P21, P22, P23 */
-- ==========================================================================================
CREATE	PROCEDURE [kcsd].[p_kc_pushassign] @pm_run_code varchar(10)=NULL, @pm_pusher_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_type	varchar(2), --催收分類
	@wk_pusher_code	varchar(6),	-- M0 
	@wk_pusher_date	datetime,	-- 指派日
	@wk_sales_code	varchar(6),	-- 業務換區用
	@wk_area_code	varchar(2),	-- 業務換區用

	@wk_pay_type	varchar(4),
	@wk_dday_date	datetime,
	@wk_delay_code	varchar(4),
	@wk_expt_date	datetime,	--當期因繳日
	@wk_row_cnt_M0		int,		-- 筆數
	@wk_row_cnt_M1		int,		-- 筆數
	@wk_row_cnt_M2		int,		-- 筆數
	@wk_row_cnt_P2		int,		-- 筆數
	@wk_row_count_M0	int,	-- M0分派用
	@wk_row_count_M1	int,	-- M1分派用
	@wk_row_count_M2	int,	-- M2分派用
	@wk_row_count_P2	int,	-- 移工分派用
	@wk_over_amt		int

CREATE TABLE #tmp_pushassign_test
(kc_case_no	varchar(10),
kc_area_code varchar(10),
kc_delay_code	varchar(4),
kc_pusher_code	varchar(6),
kc_pusher_date	smalldatetime,
kc_over_amt		int,
kc_expt_date	smalldatetime
)

SELECT	@wk_case_no=NULL,@wk_pusher_type=NULL, @wk_pusher_code=NULL,	@wk_sales_code=NULL, @wk_pusher_date=NULL,	@wk_delay_code=NULL,@wk_row_cnt_M0 = 0,@wk_row_cnt_M1 = 0,@wk_row_cnt_M2 = 0,@wk_row_cnt_P2 = 0

--SELECT	@wk_row_count  = DATEPART(y, GETDATE())-1	--簡易亂數
SELECT @wk_row_count_M0 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_M1 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_M2 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_P2 =  Round(RAND() * 1000, 0) --亂數

DECLARE	cursor_case_no	CURSOR FOR
SELECT kc_case_no,kc_pusher_type FROM (
	SELECT	c.kc_case_no,c.kc_over_amt,'P' as kc_pusher_type
		FROM	kcsd.kc_customerloan c
		left join [kcsd].[kc_cpdata] cp on c.kc_cp_no = cp.kc_cp_no
		WHERE	kc_loan_stat IN ('D')
		AND c.kc_prod_type not in ('13','14')
		AND NOT EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS NULL)
		AND datediff(day,(SELECT DATEADD(day, -3, MAX(kc_pay_date)) as kc_pay_date FROM kcsd.kc_loanpayment WHERE kc_pay_type = '7' AND kc_pay_date < GETDATE()),kc_dday_date) < 0
	union
	SELECT	c.kc_case_no,c.kc_over_amt,'P' as kc_pusher_type
		FROM	kcsd.kc_customerloan c
		WHERE	kc_loan_stat IN ('F')
		AND c.kc_prod_type not in ('13','14')
		AND NOT EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS NULL)
	union
	SELECT	c.kc_case_no,c.kc_over_amt,'P2' as kc_pusher_type
		FROM	kcsd.kc_customerloan c
		WHERE	kc_loan_stat IN ('D','F')
		AND c.kc_prod_type = '13'
		AND NOT EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS NULL)
) AS ss



ORDER BY kc_pusher_type DESC,kc_over_amt DESC

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pusher_type

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL,@wk_dday_date = NULL, @wk_pay_type = NULL, @wk_sales_code = NULL, @wk_area_code = NULL, @wk_over_amt = 0
	
	/* 尚未有催款人, 則自動指派 */
	IF NOT EXISTS		
		(SELECT	'X'
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL)
	BEGIN
		SELECT	@wk_dday_date = kc_dday_date, @wk_pay_type = kc_pay_type, @wk_sales_code = kc_sales_code, @wk_area_code = kc_area_code,	@wk_over_amt = kc_over_amt
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		--取逾期代碼M0~MX
		EXECUTE kcsd.p_kc_pushassign_calcm @wk_case_no, @wk_delay_code OUTPUT

		IF @wk_delay_code = 'MX' 
		BEGIN
		SELECT @wk_delay_code = 'M2' 
		END

		print (CONVERT(varchar(100),@wk_case_no)+'    '+ CONVERT(varchar(100),@wk_delay_code)+'    ' + CONVERT(varchar(100),@wk_row_count_M1)+'    '+ CONVERT(varchar(100),@wk_row_cnt_M1)+'    '+ CONVERT(varchar(100),@wk_pusher_type)+'    ')
		--委派
		IF @wk_pusher_type = 'P2'
		BEGIN
		EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_P2 OUTPUT,@wk_row_cnt_P2 OUTPUT,@wk_pusher_type
		END
		ELSE
		BEGIN
		IF @wk_delay_code = 'M0'
		BEGIN
		EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_M0 OUTPUT,@wk_row_cnt_M0 OUTPUT,@wk_pusher_type
		END
		ELSE IF @wk_delay_code = 'M1'
		BEGIN
		EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_M1 OUTPUT,@wk_row_cnt_M1 OUTPUT,@wk_pusher_type
		END
		ELSE
		BEGIN
		EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_M2 OUTPUT,@wk_row_cnt_M2 OUTPUT,@wk_pusher_type
		END
		END

		IF	@wk_pusher_code IS NOT NULL
		BEGIN
			--取得指派日凌晨
			IF @pm_pusher_date IS NULL
			BEGIN
				SELECT @wk_pusher_date = CONVERT(varchar(20), GETDATE(), 23)
			END
			ELSE
			BEGIN
				SELECT @wk_pusher_date = @pm_pusher_date
			END 
			--取當期應繳日
			SELECT @wk_expt_date = min(kc_expt_date) FROM kcsd.kc_loanpayment WHERE kc_case_no  = @wk_case_no AND kc_pay_date IS NULL

			IF	@pm_run_code = 'EXECUTE'
			BEGIN
				-- 1.結束先前指派, 停派日為 新指派日前1日
				UPDATE	kcsd.kc_pushassign
				SET	kc_stop_date = DATEADD(day, -1, @wk_pusher_date)
				WHERE	kc_case_no = @wk_case_no
				AND	kc_stop_date IS NULL		

				-- 2.新增指派
				INSERT	kcsd.kc_pushassign
					(kc_case_no,kc_area_code, kc_strt_date, kc_pusher_code, kc_delay_code,kc_updt_user, kc_updt_date,kc_expt_date)
				VALUES	(@wk_case_no,@wk_area_code, @wk_pusher_date, @wk_pusher_code, @wk_delay_code,USER, GETDATE(),@wk_expt_date )

				-- 3.修改主檔
				UPDATE kcsd.kc_customerloan
				SET	kc_pusher_code = @wk_pusher_code,
					kc_pusher_date = @wk_pusher_date,
					kc_delay_code = @wk_delay_code,
					kc_push_sort = 'X',
					kc_updt_user = USER,
					kc_updt_date = GETDATE()
				WHERE kc_case_no = @wk_case_no
			END

			ELSE
			BEGIN
				--存測試資料
				INSERT	#tmp_pushassign_test
					(kc_case_no,kc_area_code, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt,kc_expt_date)
				VALUES	(@wk_case_no, @wk_area_code, @wk_delay_code, @wk_pusher_code, @wk_pusher_date, @wk_over_amt,@wk_expt_date)	
			END
		END	
	END
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pusher_type
END

DEALLOCATE	cursor_case_no

	SELECT	*
	FROM	#tmp_pushassign_test
	ORDER BY kc_over_amt DESC
	
	--金額合計
	SELECT kc_pusher_code,count(*) as cnt,sum(kc_over_amt) as kc_over_amt
	FROM	#tmp_pushassign_test
	group by kc_pusher_code
	order by kc_pusher_code

DROP TABLE #tmp_pushassign_test


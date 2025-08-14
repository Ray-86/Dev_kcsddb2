-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_pushassign_M0toM1] @pm_run_code varchar(10)=NULL, @pm_pusher_date datetime=NULL
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
		WHERE	kc_loan_stat IN ('D','F')
		AND c.kc_prod_type not in ('13','14')
		AND  EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS  NULL
			and kc_delay_code = 'M0')
		AND datediff(day,(SELECT DATEADD(day, -30, MAX(kc_pay_date)) as kc_pay_date FROM kcsd.kc_loanpayment WHERE kc_pay_type = '7' AND kc_pay_date < GETDATE()),kc_dday_date) < 0
) AS ss




ORDER BY kc_pusher_type DESC,kc_over_amt DESC

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pusher_type

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL,@wk_dday_date = NULL, @wk_pay_type = NULL, @wk_sales_code = NULL, @wk_area_code = NULL, @wk_over_amt = 0
	
		SELECT	@wk_dday_date = kc_dday_date, @wk_pay_type = kc_pay_type, @wk_sales_code = kc_sales_code, @wk_area_code = kc_area_code,	@wk_over_amt = kc_over_amt
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		--取逾期代碼M0~MX
		EXECUTE kcsd.p_kc_pushassign_calcm @wk_case_no, @wk_delay_code OUTPUT

		IF @wk_delay_code = 'MX' 
		BEGIN
		SELECT @wk_delay_code = 'M1' 
		END

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



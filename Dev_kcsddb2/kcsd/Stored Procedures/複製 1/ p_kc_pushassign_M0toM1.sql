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
	@wk_id_no	varchar(20),	-- ID
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
	@wk_over_amt		int,
	@wk_old_delay_code	varchar(4), -- 舊

	@wk_IsEnable_pmp int


CREATE TABLE #tmp_pushassign_test
(kc_case_no	varchar(10),
kc_area_code varchar(10),
kc_delay_code	varchar(4),
kc_pusher_code	varchar(6),
kc_pusher_date	smalldatetime,
kc_over_amt		int,
kc_expt_date	smalldatetime,
kc_old_delay_code varchar(4)
)


SELECT	@wk_case_no=NULL,@wk_pusher_type=NULL,@wk_id_no=NULL, @wk_pusher_code=NULL,	@wk_sales_code=NULL, @wk_pusher_date=NULL,	@wk_delay_code=NULL,@wk_row_cnt_M0 = 0,@wk_row_cnt_M1 = 0,@wk_row_cnt_M2 = 0,@wk_row_cnt_P2 = 0

--SELECT	@wk_row_count  = DATEPART(y, GETDATE())-1	--簡易亂數
SELECT @wk_row_count_M0 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_M1 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_M2 =  Round(RAND() * 1000, 0) --亂數
SELECT @wk_row_count_P2 =  Round(RAND() * 1000, 0) --亂數

DECLARE	cursor_case_no	CURSOR FOR

SELECT  kc_case_no,kc_pusher_type,kc_delay_code FROM (

SELECT	c.kc_case_no,c.kc_over_amt,'P' as kc_pusher_type,p.kc_delay_code
		FROM	kcsd.kc_customerloan c
		left join [kcsd].[kc_cpdata] cp on c.kc_cp_no = cp.kc_cp_no
		left join [kcsd].kc_pushassign p on c.kc_case_no = p.kc_case_no  AND p.kc_stop_date IS  NULL
		WHERE	kc_loan_stat IN ('D') and ISNULL(kc_car_stat,'') not in ('C')
		AND c.kc_prod_type not in ('13','14')
		AND  EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS  NULL
			and kc_pusher_code like 'P%'
			and kc_delay_code not in ('M9','MP'))
UNION
	SELECT	c.kc_case_no,c.kc_over_amt,'P2' as kc_pusher_type,p.kc_delay_code
		FROM	kcsd.kc_customerloan c
		left join [kcsd].[kc_cpdata] cp on c.kc_cp_no = cp.kc_cp_no
		left join [kcsd].kc_pushassign p on c.kc_case_no = p.kc_case_no  AND p.kc_stop_date IS  NULL
		WHERE		(kc_loan_stat IN ('D','F') or kc_car_stat in ('C') )
		AND c.kc_prod_type  in ('13')
		AND  EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS  NULL
			and kc_pusher_code like 'P%'
			and kc_delay_code not in ('M9','MP')
			and kc_strt_date <=  DATEADD(DD,-2,GETDATE())
			)
UNION

	SELECT	c.kc_case_no,c.kc_over_amt,'P3' as kc_pusher_type,p.kc_delay_code
		FROM	kcsd.kc_customerloan c
		left join [kcsd].[kc_cpdata] cp on c.kc_cp_no = cp.kc_cp_no
		left join [kcsd].kc_pushassign p on c.kc_case_no = p.kc_case_no  AND p.kc_stop_date IS  NULL
		WHERE		(kc_loan_stat IN ('F') or kc_car_stat in ('C'))
		AND c.kc_prod_type not in ('13','14')
		AND  EXISTS
			(SELECT	'X' 
			FROM kcsd.kc_pushassign p
			WHERE	p.kc_case_no = c.kc_case_no
			AND	p.kc_stop_date IS  NULL
			and kc_pusher_code like 'P%'
			and kc_delay_code not in ('M9','MP'))


) AS ss
--where kc_case_no = '2222221'


ORDER BY kc_pusher_type DESC,kc_over_amt DESC

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_pusher_type,@wk_old_delay_code

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL,@wk_dday_date = NULL, @wk_pay_type = NULL, @wk_sales_code = NULL, @wk_area_code = NULL, @wk_over_amt = 0
	
		SELECT	@wk_dday_date = kc_dday_date, @wk_pay_type = kc_pay_type, @wk_sales_code = kc_sales_code, @wk_area_code = kc_area_code ,@wk_over_amt = kc_over_amt ,@wk_id_no = kc_id_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		--取逾期代碼M0~MX
		EXECUTE kcsd.p_kc_pushassign_calcm @wk_case_no, @wk_delay_code OUTPUT

		IF @wk_pusher_type = 'P3' 
		BEGIN
		SELECT @wk_delay_code = 'M9' 
		END

		IF @wk_old_delay_code <> @wk_delay_code or @wk_pusher_type = 'P3' 
		BEGIN
------------------------------
		select  top(1) @wk_pusher_code =  p.kc_pusher_code from kcsd.kc_pushassign p
		left join kcsd.kc_customerloan c on p.kc_case_no = c.kc_case_no
		where kc_stop_date is null and kc_id_no = @wk_id_no and p.kc_delay_code = @wk_delay_code order by p.kc_strt_date 


		if @wk_pusher_code is null
		BEGIN

		--車輛狀態 = C車已載回 或 繳款狀態 = F估車逾期，無條件轉M9
		IF @wk_pusher_type = 'P3' 
		BEGIN
		--SELECT @wk_delay_code = 'M9' 
	    		--M2轉M3 或 M3轉M2 給同一人交辦
				IF(@wk_old_delay_code = 'M2' or @wk_old_delay_code = 'M3')
					BEGIN
						select @wk_pusher_code = kc_pusher_code from kcsd.kc_customerloan where kc_case_no = @wk_case_no
					END
				ELSE
					BEGIN
						--其它由M2名單抽選
						EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, 'M2', @wk_row_count_M2 OUTPUT,@wk_row_cnt_M2 OUTPUT,@wk_pusher_type
					END
		END
		--委派
		ELSE IF @wk_pusher_type = 'P' 
		BEGIN

		--M3案件，逾期金額要為0才轉出
		IF @wk_over_amt <> 0 and @wk_old_delay_code = 'M3' 
			BEGIN
				select @wk_pusher_code = NULL 
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
						select @wk_IsEnable_pmp = ISNULL(IsEnable_pmp,0) from kcsd.kc_customerloan c left join kcsd.kc_caragentbranchProd p on c.kc_comp_code = p.kc_agent_code and c.kc_prod_type = p.kc_prod_type where c.kc_case_no = @wk_case_no
						IF(@wk_old_delay_code = 'M1' and @wk_delay_code = 'M2' and @wk_IsEnable_pmp = 1)
							BEGIN
							select @wk_pusher_code = 'PMP' , @wk_delay_code = 'MP'
							END
						--M2轉M3 或 M3轉M2 給同一人交辦
						ELSE IF((@wk_old_delay_code = 'M2' and @wk_delay_code = 'M3') or (@wk_old_delay_code = 'M3' and @wk_delay_code = 'M2'))
							BEGIN
								select @wk_pusher_code = kc_pusher_code from kcsd.kc_customerloan where kc_case_no = @wk_case_no
							END
						ELSE
							BEGIN
								--其它由M2名單抽選
								EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, 'M2', @wk_row_count_M2 OUTPUT,@wk_row_cnt_M2 OUTPUT,@wk_pusher_type
							END
					END
			END
		END
		--移工委派
		ELSE IF @wk_pusher_type = 'P2' 
		BEGIN

		--M3案件，逾期金額要為0才轉出
		IF @wk_over_amt <> 0 and @wk_old_delay_code = 'M3' 
			BEGIN
				select @wk_pusher_code = NULL 
			END
		ELSE
			BEGIN
				IF @wk_delay_code = 'M0' or @wk_delay_code = 'M1'
					BEGIN
						EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_P2 OUTPUT,@wk_row_cnt_P2 OUTPUT,@wk_pusher_type
					END
				ELSE
					BEGIN		
						select @wk_IsEnable_pmp = ISNULL(IsEnable_pmp,0) from kcsd.kc_customerloan c left join kcsd.kc_caragentbranchProd p on c.kc_comp_code = p.kc_agent_code and c.kc_prod_type = p.kc_prod_type where c.kc_case_no = @wk_case_no
						IF(@wk_old_delay_code = 'M1' and @wk_delay_code = 'M2' and @wk_IsEnable_pmp = 1)
							BEGIN
							select @wk_pusher_code = 'PMP' , @wk_delay_code = 'MP'
							END
						--M2轉M3 或 M3轉M2 給同一人交辦
						ELSE IF((@wk_old_delay_code = 'M2' and @wk_delay_code = 'M3') or (@wk_old_delay_code = 'M3' and @wk_delay_code = 'M2'))
							BEGIN
								select @wk_pusher_code = kc_pusher_code from kcsd.kc_customerloan where kc_case_no = @wk_case_no
							END
						ELSE
							BEGIN
								EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, @wk_delay_code, @wk_row_count_P2 OUTPUT,@wk_row_cnt_P2 OUTPUT,@wk_pusher_type
							END
					END
			END
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

				--4.存測試資料
				INSERT	#tmp_pushassign_test
					(kc_case_no,kc_area_code, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt,kc_expt_date,kc_old_delay_code)
				VALUES	(@wk_case_no, @wk_area_code, @wk_delay_code, @wk_pusher_code, @wk_pusher_date, @wk_over_amt,@wk_expt_date,@wk_old_delay_code)	
			END

			ELSE
			BEGIN
				--存測試資料
				INSERT	#tmp_pushassign_test
					(kc_case_no,kc_area_code, kc_delay_code, kc_pusher_code, kc_pusher_date, kc_over_amt,kc_expt_date,kc_old_delay_code)
				VALUES	(@wk_case_no, @wk_area_code, @wk_delay_code, @wk_pusher_code, @wk_pusher_date, @wk_over_amt,@wk_expt_date,@wk_old_delay_code)	
			END
		END


--------------------------
		END
	FETCH NEXT FROM cursor_case_no INTO  @wk_case_no,@wk_pusher_type,@wk_old_delay_code
END

		
DEALLOCATE	cursor_case_no

	SELECT	*
	FROM	#tmp_pushassign_test
	ORDER BY kc_over_amt DESC
	
	--金額合計
	SELECT kc_delay_code,kc_pusher_code,count(*) as cnt,sum(kc_over_amt) as kc_over_amt
	FROM	#tmp_pushassign_test
	group by kc_delay_code,kc_pusher_code
	order by kc_delay_code,kc_pusher_code

DROP TABLE #tmp_pushassign_test
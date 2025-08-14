-- ==========================================================================================
-- 07/28/07 KC: 改用sub_pushassign, not tested yet
-- 07/01/06 KC: 臨時, push_sort E%, L01~L05 全轉給L04
-- 05/01/06 KC: modify from pushassign_draw_old, no tmpnopv2 needed
-- 02/11/06 KC: 隨機抓取指定案件指派給指定的人
-- 		@pm_run_code: TEST/EXECUTE
--		@pm_pusher_new: 指派給誰
--		@pm_draw_amt: 指派幾件
-- 		由 kc_tmpnopv2 的 kc_case_no 欄位抓 P1~PX 候選人
-- ==========================================================================================
CREATE         PROCEDURE [kcsd].[p_kc_pushassign_draw(停用)]
	@pm_run_code varchar(10)=NULL,
	@pm_pusher_old varchar(10)=NULL,
	@pm_pusher_new varchar(3)=NULL,
	@pm_draw_amt int=0
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code varchar(6),
	@wk_delay_code	varchar(4),
	@wk_cand_row	int,
	@wk_draw_count	int,
	@wk_row_count	int

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_delay_code='MA'

IF	@pm_pusher_old IS NULL
OR	@pm_pusher_new IS NULL
	RETURN

CREATE TABLE #tmp_draw
(kc_pusher_old	varchar(6),
kc_pusher_new	varchar(6),
kc_case_no	varchar(10),
kc_row_count	int,
kc_cand_row	int
)

SELECT	@wk_pusher_code = RTRIM(@pm_pusher_old)

BEGIN
	SELECT	@wk_cand_row=0, @wk_row_count=0, @wk_draw_count=0

-- 正常 draw
/*	SELECT	@wk_row_count = COUNT(*)
	FROM	kcsd.kc_customerloan
	WHERE	kc_pusher_code = @wk_pusher_code
	AND	kc_loan_stat <> 'C'
	AND	kc_loan_stat <> 'E'
	AND	kc_push_sort LIKE 'E%' */

-- KC: 外包轉回
	SELECT	@wk_row_count = COUNT(*)
	FROM	kcsd.kc_customerloan c, kcsd.kc_tmpnopv2 t
	WHERE	c.kc_pusher_code = @wk_pusher_code
	AND	c.kc_case_no = t.kc_case_no
	AND	c.kc_loan_stat <> 'C'
	AND	c.kc_loan_stat <> 'E'

	WHILE	@wk_draw_count < @pm_draw_amt
	BEGIN
		SELECT	@wk_cand_row = ROUND(RAND() * @wk_row_count + 1, 0)

		SET ROWCOUNT @wk_cand_row

-- 正常 draw
/*		SELECT	@wk_case_no = kc_case_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_pusher_code = @wk_pusher_code
		AND	kc_loan_stat <> 'C'
		AND	kc_loan_stat <> 'E'
		AND	kc_push_sort LIKE 'E%' */	
-- KC: 外包轉回
		SELECT	@wk_case_no = t.kc_case_no
		FROM	kcsd.kc_customerloan c, kcsd.kc_tmpnopv2 t
		WHERE	c.kc_pusher_code = @wk_pusher_code
		AND	c.kc_case_no = t.kc_case_no
		AND	c.kc_loan_stat <> 'C'
		AND	c.kc_loan_stat <> 'E'

		SET ROWCOUNT 0

		INSERT	#tmp_draw
			(kc_pusher_old, kc_pusher_new, kc_case_no, kc_row_count, kc_cand_row)
		VALUES	(@wk_pusher_code, @pm_pusher_new, @wk_case_no, @wk_row_count, @wk_cand_row)

		/* SELECT	@wk_pusher_code, @wk_row_count, @wk_cand_row, @wk_case_no */

		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			/*
			-- 結束先前指派指派
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL		

			-- 新增指派
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, GETDATE(), RTRIM(@pm_pusher_new), @wk_delay_code,
				USER, GETDATE() )

			-- 修改主檔
			UPDATE	kcsd.kc_customerloan

			SET	kc_pusher_code = @pm_pusher_new, kc_pusher_date = GETDATE(),

				kc_delay_code = @wk_delay_code,
				kc_updt_user = USER, kc_updt_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no */

			EXECUTE	kcsd.p_kc_pushassign_sub_assign @wk_case_no, @pm_pusher_new, @wk_delay_code
		END

		SELECT	@wk_draw_count = @wk_draw_count + 1, @wk_row_count = @wk_row_count - 1
	END

	/* SELECT	@wk_cand_row = RAND()* */	
END

SELECT	*
FROM	#tmp_draw

DROP TABLE #tmp_draw

-- ==========================================================================================
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_pushsimu_sub]
	@pm_pusher_old varchar(10)=NULL,
	@pm_pusher_new varchar(3)=NULL,
	@pm_push_sort varchar(4)=NULL,
	@pm_draw_amt int=0
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code varchar(6),
	@wk_delay_code	varchar(4),
	@wk_cand_row	int,
	@wk_draw_count	int,
	@wk_dup_count	int,
	@wk_row_count	int,
	@wk_over_amt	int,
	@wk_over_sum	int

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_delay_code='MA'

IF	@pm_pusher_old IS NULL
OR	@pm_pusher_new IS NULL
OR	@pm_push_sort IS NULL
OR	@pm_draw_amt <= 0
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
	SELECT	@wk_cand_row=0, @wk_row_count=0, @wk_draw_count=0,
		@wk_dup_count = 0, @wk_over_sum = 0

-- 正常 draw
	SELECT	@wk_row_count = COUNT(*)
	FROM	kcsd.kc_customerloan
	WHERE	kc_pusher_code = @pm_pusher_old
	AND	kc_push_sort = @pm_push_sort
	AND	kc_loan_stat = 'D'
	AND	kc_case_no NOT IN 	(SELECT	kc_case_no
					FROM	kcsd.kc_pushsimu_result)

	WHILE	@wk_draw_count < @pm_draw_amt
	BEGIN
		SELECT	@wk_cand_row = ROUND(RAND() * @wk_row_count + 1, 0)

		SET ROWCOUNT @wk_cand_row

-- 正常 draw
-- KC: 外包轉回
		SELECT	@wk_case_no = kc_case_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_pusher_code = @pm_pusher_old
		AND	kc_push_sort = @pm_push_sort
		AND	kc_loan_stat = 'D'
		AND	kc_case_no NOT IN 	(SELECT	kc_case_no
						FROM	kcsd.kc_pushsimu_result)

		SET ROWCOUNT 0

		INSERT	#tmp_draw
			(kc_pusher_old, kc_pusher_new, kc_case_no, kc_row_count, kc_cand_row)
		VALUES	(@wk_pusher_code, @pm_pusher_new, @wk_case_no, @wk_row_count, @wk_cand_row)

		--SELECT	@wk_pusher_code, @wk_row_count, @wk_cand_row, @wk_case_no

		-- Assign
		SELECT	@wk_over_amt = 0

		SELECT	@wk_over_amt = kc_over_amt
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		SELECT	@wk_over_sum = @wk_over_sum + @wk_over_amt

		IF NOT EXISTS(	SELECT	kc_case_no
				FROM	kcsd.kc_pushsimu_result
				WHERE	kc_case_no = @wk_case_no
			)
			INSERT	kcsd.kc_pushsimu_result
				(kc_case_no, kc_pusher_old, kc_pusher_new, kc_over_amt)
			VALUES
				(@wk_case_no, @pm_pusher_old, @pm_pusher_new, @wk_over_amt)
		ELSE
			SELECT	@wk_dup_count = @wk_dup_count + 1

		SELECT	@wk_draw_count = @wk_draw_count + 1, @wk_row_count = @wk_row_count - 1
	END

	UPDATE	kcsd.kc_pushsimu_plan
	SET	kc_over_amt = @wk_over_sum, kc_case_qty = (@wk_draw_count-@wk_dup_count)
	WHERE	kc_pusher_code = @pm_pusher_new
END

SELECT	*
FROM	#tmp_draw

DROP TABLE #tmp_draw

-- ==========================================================================================
-- 07/08/06 KC: copy from pushassign_draw
--		Need handle 2 cases:
--		* 催收人新增, 平均分派派給他
--		* 催收人減少, 平均拉出去給別人
--		-- use p_kc_pushassign_sub_assign
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_pushassign_draw3_sortavg(保留舊的)]
	@pm_run_code varchar(10)=NULL,
	@pm_push_sort varchar(4)=NULL
AS
DECLARE	@wk_case_no		varchar(10),
	@wk_pusher_count	int,
	@wk_case_count		int,
	@wk_case_need		int,
	@wk_sort_avg		int,
	@wk_pusher_old		varchar(6),
	@wk_pusher_new		varchar(6),
--	@wk_pusher_code varchar(6),
	@wk_delay_code	varchar(4),
	@wk_cand_row	int,
	@wk_draw_count	int,
	@wk_row_count	int

--SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_delay_code='MA'
SELECT	@wk_delay_code='MA'

IF	@pm_push_sort IS NULL
	RETURN

CREATE TABLE #tmp_draw
(kc_pusher_old	varchar(6),
kc_pusher_new	varchar(6),
kc_case_no	varchar(10),
kc_row_count	int,
kc_cand_row	int
)

CREATE TABLE #tmp_pusher
(
kc_emp_code	varchar(10),
kc_case_count	int,
kc_case_need	int
)
-- ==========
-- 取得 pusher
INSERT	#tmp_pusher
SELECT	DelegateCode, 0, 0
FROM	kcsd.Delegate
WHERE	DelegateCode LIKE 'P%'
AND	IsEnable = 1
ORDER BY DelegateCode

SELECT	@wk_pusher_count = COUNT(*)
FROM	#tmp_pusher
-- ==========

--SELECT	@wk_pusher_code = RTRIM(@pm_pusher_old)

--	SELECT	@wk_cand_row=0, @wk_row_count=0, @wk_draw_count=0

-- 正常 draw
-- 小心條件 P0% 且非 P0
	SELECT	@wk_case_count = COUNT(*)
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat <> 'C'
	AND	kc_loan_stat <> 'E'
	AND	kc_push_sort = @pm_push_sort
	AND	kc_pusher_code LIKE 'P0%'
	AND	kc_pusher_code <> 'P0'

	SELECT	@wk_sort_avg = @wk_case_count / @wk_pusher_count

	SELECT	@wk_sort_avg AS wk_avg,
		@wk_case_count AS wk_count, @wk_pusher_count AS wk_pusher


/* SELECT	c.kc_pusher_code, COUNT(c.kc_case_no)
FROM	kcsd.kc_customerloan c, #tmp_pusher p
WHERE	c.kc_pusher_code = p.kc_emp_code
AND	c.kc_loan_stat <> 'C'
AND	c.kc_loan_stat <> 'E'
AND	c.kc_push_sort = @pm_push_sort
GROUP BY c.kc_pusher_code	*/

DECLARE	cursor_draw3_pusher	CURSOR
FOR	SELECT	kc_emp_code
	FROM	#tmp_pusher

OPEN cursor_draw3_pusher
FETCH NEXT FROM cursor_draw3_pusher INTO @wk_pusher_new


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_case_count = COUNT(*)
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat <> 'C'
	AND	kc_loan_stat <> 'E'
	AND	kc_push_sort = @pm_push_sort
	AND	kc_pusher_code = @wk_pusher_new
		
	--SELECT	@wk_pusher_old, @wk_case_count
	UPDATE	#tmp_pusher
	SET	kc_case_count = @wk_case_count, kc_case_need = @wk_sort_avg - @wk_case_count
	WHERE	kc_emp_code = @wk_pusher_new

	FETCH NEXT FROM cursor_draw3_pusher INTO @wk_pusher_new
END
CLOSE	cursor_draw3_pusher

SELECT	*
FROM	#tmp_pusher

-- reopen cursor
OPEN cursor_draw3_pusher
FETCH NEXT FROM cursor_draw3_pusher INTO @wk_pusher_new


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_case_no = NULL, @wk_pusher_old = NULL

	-- SELECT	@wk_case_count = kc_case_count
	SELECT	@wk_case_need = kc_case_need
	FROM	#tmp_pusher
	WHERE	kc_emp_code = @wk_pusher_new

	-- Skip if below avg (don't need anything)
	IF	@wk_case_need <= 0
	BEGIN
		FETCH NEXT FROM cursor_draw3_pusher INTO @wk_pusher_new
		CONTINUE
	END

	SELECT	@wk_draw_count = 0
	WHILE	( @wk_draw_count < @wk_case_need )
	BEGIN
		SELECT	@wk_row_count = -SUM(kc_case_need)
		FROM	#tmp_pusher
		WHERE	kc_case_need < 0

		-- Pick 1
		SELECT	@wk_cand_row = ROUND(RAND() * @wk_row_count + 1, 0)

		SET ROWCOUNT @wk_cand_row

		-- Get case
		SELECT	@wk_case_no = c.kc_case_no
		FROM	kcsd.kc_customerloan c, #tmp_pusher p
		WHERE	c.kc_pusher_code = p.kc_emp_code
		AND	c.kc_loan_stat <> 'C'
		AND	c.kc_loan_stat <> 'E'
		AND	c.kc_push_sort = @pm_push_sort
		AND	p.kc_case_need < 0
		ORDER BY c.kc_case_no

		SET ROWCOUNT 0

		SELECT	@wk_pusher_old = kc_pusher_code
		FROM	kcsd.kc_customerloan
		WHERE	kc_case_no = @wk_case_no

		INSERT	#tmp_draw
			(kc_pusher_old, kc_pusher_new, kc_case_no, kc_row_count, kc_cand_row)
		VALUES	(@wk_pusher_old, @wk_pusher_new, @wk_case_no, @wk_row_count, @wk_cand_row)

		UPDATE	#tmp_pusher
		SET	kc_case_need = kc_case_need - 1
		WHERE	kc_emp_code = @wk_pusher_new

		UPDATE	#tmp_pusher
		SET	kc_case_need = kc_case_need + 1
		WHERE	kc_emp_code = @wk_pusher_old

		-- SELECT	@wk_case_need = @wk_case_need - 1
		SELECT	@wk_draw_count = @wk_draw_count + 1

		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			EXECUTE	kcsd.p_kc_pushassign_sub_assign @wk_case_no, @wk_pusher_new
		END
	END

	FETCH NEXT FROM cursor_draw3_pusher INTO @wk_pusher_new
END

DEALLOCATE	cursor_draw3_pusher

SELECT	*
FROM	#tmp_pusher

SELECT	*
FROM	#tmp_draw

DROP TABLE #tmp_draw

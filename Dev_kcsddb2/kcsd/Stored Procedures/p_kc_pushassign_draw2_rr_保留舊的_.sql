-- ==========================================================================================
-- 07/01/06 KC: modify from pushassign_draw, 改為 RR, 依 push_sort, rema_amt 排序, RR 分配
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_draw2_rr(保留舊的)]
	@pm_run_code varchar(10)=NULL,
	@pm_pusher_old varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code varchar(6),
	@wk_delay_code	varchar(4),
	@wk_cand_row	int,		-- 這次的 RR 催收員
	@wk_row_count	int,		-- counter
	@wk_row_limit	int		-- Number of RR pusher

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_delay_code='MA',
	@wk_cand_row=0, @wk_row_count=0


IF	@pm_pusher_old IS NULL
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
kc_emp_code	varchar(10)
)

-- ==========
-- 取得法務人員
INSERT	#tmp_pusher
SELECT	DelegateCode
FROM	kcsd.Delegate
WHERE	DelegateCode LIKE 'L%'
AND	IsEnable = 1
ORDER BY DelegateCode

SELECT	@wk_row_limit = COUNT(*)
FROM	#tmp_pusher
-- ==========

DECLARE	cursor_pusher_draw	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_pusher_code = @pm_pusher_old
	AND	kc_loan_stat <> 'C'
	AND	kc_loan_stat <> 'E'
	AND	(kc_push_sort NOT LIKE 'E%' OR kc_push_sort IS NULL)
	ORDER BY kc_push_sort ASC, kc_rema_amt DESC, kc_case_no

OPEN cursor_pusher_draw
FETCH NEXT FROM cursor_pusher_draw INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	-- ==========
	-- Get New Pusher by RR
	SELECT	@wk_cand_row = (@wk_row_count % @wk_row_limit) + 1

	SET ROWCOUNT @wk_cand_row

	SELECT	@wk_pusher_code = kc_emp_code
	FROM	#tmp_pusher
	ORDER BY kc_emp_code

	SET ROWCOUNT 0
	-- ==========

	INSERT	#tmp_draw
		(kc_pusher_old, kc_pusher_new, kc_case_no, kc_row_count, kc_cand_row)
	VALUES	(@wk_pusher_code, @wk_pusher_code, @wk_case_no, @wk_row_count, @wk_cand_row)


		IF	@pm_run_code = 'EXECUTE'
		BEGIN
		/* 結束先前指派指派 */
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL		

			/* 新增指派 */
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, GETDATE(), RTRIM(@wk_pusher_code), @wk_delay_code,
				USER, GETDATE() )

			/* 修改主檔 */
			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = GETDATE(),
				kc_delay_code = @wk_delay_code,
				kc_updt_user = USER, kc_updt_date = GETDATE()
			WHERE	kc_case_no = @wk_case_no
		END

	SELECT	@wk_row_count = @wk_row_count + 1

	FETCH NEXT FROM cursor_pusher_draw INTO @wk_case_no
END

DEALLOCATE	cursor_pusher_draw

-- SELECT	*
-- FROM	#tmp_draw t
SELECT	t.*, c.kc_push_sort, c.kc_rema_amt
FROM	#tmp_draw t, kc_customerloan c
WHERE	t.kc_case_no = c.kc_case_no
ORDER BY kc_row_count


DROP TABLE #tmp_draw

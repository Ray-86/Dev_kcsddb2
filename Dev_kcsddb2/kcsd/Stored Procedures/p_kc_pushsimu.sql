CREATE     PROCEDURE [kcsd].[p_kc_pushsimu]
	@pm_pusher_old varchar(6)=NULL,
	@pm_push_sort	varchar(4)=NULL,
	@pm_pusher_rate int=0,
	@pm_new_sort	varchar(4)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code varchar(6),

	@wk_case_total	int,
	@wk_give_count	int,
	@wk_draw_amt	int

SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL, @wk_draw_amt = 0


-- 刪除無意義資料
DELETE
FROM	kcsd.kc_pushsimu_plan
WHERE	kc_pusher_rate = 0

-- Clear last result
DELETE
FROM	kcsd.kc_pushsimu_result

SELECT	@wk_case_total = COUNT(*)
FROM	kcsd.kc_customerloan
WHERE	kc_pusher_code = @pm_pusher_old
AND	kc_push_sort = @pm_push_sort
AND	kc_loan_stat = 'D'

SELECT	@wk_give_count = ROUND(@wk_case_total * @pm_pusher_rate / 100.0, 0)

--SELECT	@wk_give_count

-- ==========
-- ==========

UPDATE	kcsd.kc_pushsimu_plan
SET	kc_case_qty =  ROUND(@wk_give_count* kc_pusher_rate /100.0, 0)

IF	@pm_new_sort IS NOT NULL
UPDATE	kcsd.kc_pushsimu_plan
SET	kc_push_sort = @pm_new_sort

DECLARE	cursor_pusher_simu	CURSOR
FOR	SELECT	kc_pusher_code, kc_case_qty
	FROM	kcsd.kc_pushsimu_plan
	ORDER BY kc_pusher_code

OPEN cursor_pusher_simu
FETCH NEXT FROM cursor_pusher_simu INTO @wk_pusher_code, @wk_draw_amt

WHILE (@@FETCH_STATUS = 0)
BEGIN
--	SELECT	@wk_pusher_code, @wk_draw_amt

	-- ==========
	-- 執行計算
	-- ==========
	EXECUTE	kcsd.p_kc_pushsimu_sub @pm_pusher_old, @wk_pusher_code, @pm_push_sort, @wk_draw_amt

	FETCH NEXT FROM cursor_pusher_simu INTO @wk_pusher_code, @wk_draw_amt
END

DEALLOCATE	cursor_pusher_simu

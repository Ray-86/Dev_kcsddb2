-- ==========================================================================================
-- 2014/01/14 取消使用者限制 (只依dy2 報表權限控管)
-- 06/09/07 KC:	hard code 執行權限 for tmchen, ydsung
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_pushsimu_exercise]	@pm_run_code varchar(10)='TEST'
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_old	varchar(20),
	@wk_pusher_oldp	varchar(20),
	@wk_pusher_new	varchar(20),
	@wk_push_sort	varchar(4)
/*
IF	USER <> 'kcsd'
--AND	USER <> 'tmchen'	-- 陳東木
--AND	USER <> 'ydsung'	-- 宋育德
AND	USER <> 'yelin'	-- 林
AND	USER <> 'ylchen'	-- 陳玉麟
BEGIN
	RAISERROR ('---- [KC] 無執行權限 !!!',18,2) --WITH SETERROR
	RETURN
END
*/

CREATE TABLE #tmp_pushsimu_exe
(kc_case_no	varchar(10),
kc_pusher_old	varchar(20),
kc_pusher_new	varchar(20)
)

SELECT	@wk_case_no=NULL,
	@wk_pusher_old=NULL, @wk_pusher_oldp=NULL, @wk_pusher_new=NULL,
	@wk_push_sort=NULL

DECLARE	cursor_case_no_pushsimu_exe	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_pushsimu_result
	ORDER BY kc_case_no

OPEN cursor_case_no_pushsimu_exe
FETCH NEXT FROM cursor_case_no_pushsimu_exe INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_old = NULL, @wk_pusher_oldp = NULL,
		@wk_pusher_new = NULL

	SELECT	@wk_pusher_old = kc_pusher_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_pusher_oldp = kc_pusher_old, @wk_pusher_new = kc_pusher_new
	FROM	kcsd.kc_pushsimu_result
	WHERE	kc_case_no = @wk_case_no
	
	-- 檢查重複執行
	IF	@wk_pusher_old = @wk_pusher_oldp
	BEGIN
		INSERT	#tmp_pushsimu_exe
			(kc_case_no, kc_pusher_old, kc_pusher_new)
		VALUES	(@wk_case_no, @wk_pusher_old, @wk_pusher_new)
			
		-- Really RUN
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			--SELECT	''
			EXECUTE	kcsd.p_kc_pushassign_sub_assign @wk_case_no, @wk_pusher_new

			SELECT	@wk_push_sort = NULL		
			-- 取得新 push sort
			SELECT	@wk_push_sort = kc_push_sort
			FROM	kcsd.kc_pushsimu_plan
			WHERE	kc_pusher_code = @wk_pusher_new

			-- 修改 push_sort
			UPDATE	kcsd.kc_customerloan
			SET	kc_push_sort = @wk_push_sort
			WHERE	kc_case_no = @wk_case_no
		END
	END	

	FETCH NEXT FROM cursor_case_no_pushsimu_exe INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_pushsimu_exe

IF	@pm_run_code <> 'EXECUTE'
	SELECT	*
	FROM	#tmp_pushsimu_exe

DROP TABLE #tmp_pushsimu_exe

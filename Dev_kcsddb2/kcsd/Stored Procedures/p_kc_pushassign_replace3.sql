-- ==========================================================================================
-- Usage: 改帳用(更換催收人員) (2010-0501)
--    1. 將 tmp_nopv2 裡面的件全部給 pusher_new
--    2. (改帳)直接修改 kc_pushassign & kc_customerloan, 不做停派後新派
-- ==========================================================================================

CREATE  PROCEDURE [kcsd].[p_kc_pushassign_replace3]
	@pm_run_code varchar(20)=NULL,	
	@pm_pusher_new varchar(6)=NULL	/* 新催款人 */
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_pusher_old	varchar(20),
	@wk_count	int

/* 至少要有原催款人 */
IF	@pm_pusher_new IS NULL
	RETURN

SELECT	@wk_case_no=NULL, @wk_count = 0

CREATE TABLE #tmp_assign_replace
(kc_case_no	varchar(10) NOT NULL,
kc_strt_date	datetime NULL,
kc_pusher_old	varchar(20)
)

DECLARE	cursor_case_no_replace	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_tmpnopv2
	WHERE	kc_case_no < '10'	-- 08, 09 only
	--AND	kc_case_no = '0823962'
	ORDER BY kc_case_no


OPEN cursor_case_no_replace
FETCH NEXT FROM cursor_case_no_replace INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_strt_date = NULL, @wk_pusher_old = NULL

	SELECT	@wk_strt_date = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_pusher_old = kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_date
	/* Do it or test only */
	IF	@pm_run_code = 'EXECUTE'
	BEGIN	
		-- 修改指派 kc_pushassign
		UPDATE	kcsd.kc_pushassign
		SET	kc_pusher_code = @pm_pusher_new
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date = @wk_strt_date

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = @pm_pusher_new
		WHERE	kc_case_no = @wk_case_no
	END

	SELECT	@wk_count = @wk_count + 1

	INSERT	#tmp_assign_replace
		(kc_case_no, kc_strt_date, kc_pusher_old)
	VALUES	(@wk_case_no, @wk_strt_date, @wk_pusher_old)

	FETCH NEXT FROM cursor_case_no_replace INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_replace

SELECT	*
FROM	#tmp_assign_replace
ORDER BY kc_case_no

DROP TABLE #tmp_assign_replace

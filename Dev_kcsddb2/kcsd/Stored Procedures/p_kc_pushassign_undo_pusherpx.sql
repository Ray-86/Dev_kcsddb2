CREATE   PROCEDURE [kcsd].[p_kc_pushassign_undo_pusherpx] @pm_case_no varchar(10)
AS
DECLARE	@wk_pusher_code	varchar(6),
	@wk_strt_last	datetime,
	@wk_strt_last2	datetime

/* only KC can run this!! */
IF	USER <> 'kcsd'
OR	@pm_case_no IS NULL
BEGIN
	SELECT	'USER =' + USER + ', case_no=' + @pm_case_no
	RETURN
END

SELECT	@wk_strt_last = NULL, @wk_strt_last2 = NULL

/* Check Consistency */
/* 抓最後一筆 */
SELECT	@wk_strt_last = MAX(kc_strt_date)
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no
AND	kc_stop_date IS NULL
AND	kc_pusher_code NOT LIKE 'P%'

/* Error */
IF	@wk_strt_last IS NULL
/*OR	DATEPART(hour, @wk_strt_last) = 0 */
BEGIN
	SELECT	@pm_case_no + ':錯誤, pushassign stop date NOT NULL, 或人工指派!!'
	RETURN
END

SELECT	@wk_pusher_code = c.kc_pusher_code
FROM	kcsd.kc_customerloan c, kcsd.kc_pushassign p
WHERE	c.kc_case_no = p.kc_case_no
AND	c.kc_pusher_code = p.kc_pusher_code
AND	c.kc_pusher_date = p.kc_strt_date
AND	c.kc_pusher_date = @wk_strt_last

IF	@wk_pusher_code IS NULL
BEGIN
	SELECT	@pm_case_no + ':錯誤, pushassign vs customerloan 資料不符!!'
	RETURN
END


/* 開始處理 */

/* 抓倒數第2筆 */
SELECT	@wk_strt_last2 = MAX(kc_strt_date)
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no
AND	kc_pusher_code LIKE 'P%'

/* 抓倒數第2筆的催款人 */
SELECT	@wk_pusher_code = kc_pusher_code
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no
AND	kc_strt_date = @wk_strt_last2
AND	kc_pusher_code LIKE 'P%'

/* 寫入開始 */
/* 清除倒數第2筆的結束日 */
	UPDATE	kcsd.kc_pushassign
	SET	kc_stop_date = NULL, kc_updt_date = @wk_strt_last2
	WHERE	kc_case_no = @pm_case_no
	AND	kc_strt_date = @wk_strt_last2
	AND	kc_pusher_code LIKE 'P%'

/* 刪除最後一筆 */
	DELETE
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @pm_case_no
	AND	kc_strt_date = @wk_strt_last
	AND	kc_pusher_code NOT LIKE 'P%'

	/* 更改主檔 */
	UPDATE	kcsd.kc_customerloan
	SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = @wk_strt_last2
	WHERE	kc_case_no = @pm_case_no

	SELECT	@pm_case_no, @wk_pusher_code, @wk_strt_last, @wk_strt_last2

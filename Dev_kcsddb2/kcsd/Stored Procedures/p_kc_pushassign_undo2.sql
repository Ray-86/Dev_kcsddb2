CREATE   PROCEDURE [kcsd].[p_kc_pushassign_undo2] @pm_case_no varchar(10), @pm_oper_mode varchar(10)='UNDO_STOP'
AS
DECLARE	@wk_pusher_code	varchar(6),
	@wk_pusher_tmp	varchar(6),
	@wk_strt_last	datetime,		/* 最後一筆的開始日期 */
	@wk_stop_last	datetime,		/* 最後一筆的結束日期 */
	@wk_delay_code	varchar(4)

/* only KC can run this!! */
IF	USER <> 'kcsd'
OR	@pm_case_no IS NULL
BEGIN
	SELECT	'USER =' + USER + ', case_no=' + @pm_case_no
	RETURN
END

SELECT	@wk_strt_last = NULL, @wk_pusher_tmp=NULL,
	@wk_delay_code = NULL

/* Check Consistency */
/* 抓最後一筆的開始日期 & 催款人 */
SELECT	@wk_strt_last = MAX(kc_strt_date)
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no

/* Error */
IF	@wk_strt_last IS NULL
BEGIN
	SELECT	@pm_case_no + ':錯誤, 完全沒有 pushassign !!'
	RETURN
END

/* 抓催款人 & 結束日期 */
SELECT	@wk_pusher_code = kc_pusher_code, @wk_stop_last = kc_stop_date,
	@wk_delay_code = kc_delay_code
FROM	kcsd.kc_pushassign
WHERE	kc_case_no = @pm_case_no
ANd	kc_strt_date = @wk_strt_last

IF	@wk_stop_last IS NULL
BEGIN
	/* 新指派,未結案 */
	SELECT	@pm_case_no + ' KC: 新指派,未結案!!'
	RETURN
END

/* 已結案 */
/* 檢查資料, 檢查主檔是否無催款人 */
SELECT	@wk_pusher_tmp = c.kc_pusher_code
FROM	kcsd.kc_customerloan c
WHERE	c.kc_case_no = @pm_case_no

IF	@wk_pusher_tmp IS NOT NULL
BEGIN
	SELECT	@pm_case_no + ':錯誤, pushassign vs customerloan 資料不符!!'
	RETURN
END

/* 寫入開始 */
/* 清除最後一筆的結束日 */
	UPDATE	kcsd.kc_pushassign
	SET	kc_stop_date = NULL, kc_updt_date = @wk_strt_last
	WHERE	kc_case_no = @pm_case_no
	AND	kc_strt_date = @wk_strt_last

/* 更改主檔 */
	UPDATE	kcsd.kc_customerloan
	SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = @wk_strt_last,
		kc_delay_code = @wk_delay_code
	WHERE	kc_case_no = @pm_case_no

SELECT	@pm_case_no, @wk_pusher_code, @wk_strt_last, @wk_delay_code

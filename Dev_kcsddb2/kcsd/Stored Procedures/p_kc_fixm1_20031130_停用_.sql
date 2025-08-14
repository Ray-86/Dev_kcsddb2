/* 12/2/2003 執行 to fix mistake in 11/30/2003 */
CREATE  PROCEDURE [kcsd].[p_kc_fixm1_20031130(停用)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_count	int,
	@wk_strt_last	datetime,
	@wk_strt_last2	datetime,
	@wk_pusher_code	varchar(10)

SELECT	@wk_case_no=NULL, @wk_count = 0, @wk_pusher_code = NULL

/* Result count = 194 - 手動修改 11 = 183 */
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_pushassign
	WHERE	kc_delay_code = 'M1'
	AND	kc_updt_date BETWEEN '11/30/2003' AND '12/2/2003'
	AND	kc_case_no NOT IN			/* 已手動修改者,不再更改 */
		(SELECT	kc_case_no
		FROM	kcsd.kc_pushassign
		WHERE	kc_delay_code = 'M1'
		AND	kc_updt_date BETWEEN '11/30/2003' AND '12/2/2003'
		AND	DATEPART(hour, kc_strt_date) = 0	/* 手動修改 */
		)
	GROUP BY kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL

	/* 抓最後一筆 */
	SELECT	@wk_strt_last = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_stop_date IS NULL

	/* 抓倒數第2筆 */
	SELECT	@wk_strt_last2 = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date < @wk_strt_last

	/* 抓倒數第2筆的催款人 */
	SELECT	@wk_pusher_code = kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_last2

	/* 清除倒數第2筆的結束日 */
	UPDATE	kcsd.kc_pushassign
	SET	kc_stop_date = NULL
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_last2

	/* 刪除最後一筆 */
	DELETE
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_last

	/* 更改主檔 */
	UPDATE	kcsd.kc_customerloan
	SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = @wk_strt_last2
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_case_no
	/*
	SELECT	*
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	(kc_strt_date = @wk_strt_last2
	OR	kc_strt_date = @wk_strt_last)

	SELECT	@wk_pusher_code*/

	SELECT	@wk_count = @wk_count + 1	

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	@wk_count

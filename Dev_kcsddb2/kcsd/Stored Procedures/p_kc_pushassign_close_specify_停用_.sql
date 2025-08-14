/* 指定某些case回收 (case_no 在 kc_tmpnopv2), 可指定收回日*/
CREATE   PROCEDURE [kcsd].[p_kc_pushassign_close_specify(停用)]
	@pm_run_code varchar(10)=NULL, @pm_close_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_pusher_code	varchar(6),
	@wk_delay_code	varchar(4),
	@wk_count	int

SELECT	@wk_case_no=NULL, @wk_count = 0

/* 抓上月最後一天 */
IF	@pm_close_date IS NULL
BEGIN
	SELECT	@pm_close_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
	SELECT	@pm_close_date = DATEADD(day, -1, @pm_close_date)
END

CREATE TABLE #tmp_assignclose
(
kc_case_no	varchar(10) not null,
kc_strt_date	datetime not null,
kc_pusher_code	varchar(6) not null,
kc_delay_code	varchar(4) not null,
)

DECLARE	cursor_case_no_close	CURSOR
FOR	SELECT DISTINCT kc_case_no
	FROM	kcsd.kc_tmpnopv2
	ORDER BY kc_case_no

OPEN cursor_case_no_close
FETCH NEXT FROM cursor_case_no_close INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_strt_date = NULL, @wk_pusher_code = NULL,
		@wk_delay_code = NULL

	SELECT	@wk_strt_date = kc_strt_date, @wk_pusher_code = kc_pusher_code,
		@wk_delay_code = kc_delay_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_stop_date IS NULL

	INSERT	#tmp_assignclose
		(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code)
	VALUES	(@wk_case_no, @wk_strt_date, @wk_pusher_code, @wk_delay_code)

	/* 執行指派結束 */
	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @pm_close_date,
			kc_updt_user = USER, kc_updt_date = GETDATE()
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = NULL, kc_pusher_date = NULL,
			kc_delay_code = NULL
		WHERE	kc_case_no = @wk_case_no
	END
		SELECT	@wk_count = @wk_count + 1

	FETCH NEXT FROM cursor_case_no_close INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_close

SELECT	t.*
FROM	#tmp_assignclose t
ORDER BY t.kc_case_no

DROP TABLE #tmp_assignclose

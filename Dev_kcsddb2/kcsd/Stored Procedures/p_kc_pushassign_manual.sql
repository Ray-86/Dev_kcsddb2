/*
手動指定轉指派 (M1 only):
input: kc_tmpnopv2 (case no of cases to subcon)
param:	@pm_run_code:
	@pm_pusher_code
	@pm_pusher_date: 指派日
*/
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_manual]
	@pm_run_code varchar(20)=NULL,
	@pm_pusher_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code	varchar(6)		/* 新催款人 */

IF	@pm_pusher_date IS NULL
	RETURN

CREATE TABLE #tmp_pushassign_subcon
(kc_case_no	varchar(10),
kc_pusher_code	varchar(6)
)

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no_subcon	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_tmpnopv2
	ORDER BY kc_case_no

OPEN cursor_case_no_subcon
FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = kc_pusher_code
	FROM	kc_tmpnopv2
	WHERE	kc_case_no = @wk_case_no

	IF	@pm_run_code = 'EXECUTE'
	AND	@wk_pusher_code IS NOT NULL
	BEGIN
		/* 結束原來指派 */
		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @pm_pusher_date
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL

		/* 新增指派 */
		INSERT	kcsd.kc_pushassign
			(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
			kc_updt_user, kc_updt_date)
		VALUES	(@wk_case_no, @pm_pusher_date, @wk_pusher_code, 'M1',
			USER, GETDATE())

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = @wk_pusher_code, kc_pusher_date = @pm_pusher_date,
			kc_delay_code = 'M1'
		WHERE	kc_case_no = @wk_case_no
	END

	INSERT	#tmp_pushassign_subcon
		(kc_case_no, kc_pusher_code)
	VALUES	(@wk_case_no, @wk_pusher_code)

	FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no
END

SELECT	*
FROM	#tmp_pushassign_subcon
ORDER BY kc_case_no

DEALLOCATE	cursor_case_no_subcon

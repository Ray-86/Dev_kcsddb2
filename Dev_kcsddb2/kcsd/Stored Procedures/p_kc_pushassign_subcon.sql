/*
轉外包:
input: kc_tmpnopv2 (case no of cases to subcon)
param:	@pm_run_code:
	@pm_pusher_date: 外包日期
*/
CREATE  PROCEDURE [kcsd].[p_kc_pushassign_subcon]
	@pm_run_code varchar(20)=NULL,
	@pm_pusher_code varchar(10)=NULL,
	@pm_pusher_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code	varchar(6)		/* 原催款人 */

IF	@pm_pusher_date IS NULL
OR	@pm_pusher_code IS NULL
	RETURN

CREATE TABLE #tmp_pushassign_subcon
(kc_case_no	varchar(10)
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
		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			/* 結束原來指派 */
			UPDATE	kcsd.kc_pushassign
			SET	kc_stop_date = @pm_pusher_date
			WHERE	kc_case_no = @wk_case_no
			AND	kc_stop_date IS NULL

			/* 新增法務指派 */
			INSERT	kcsd.kc_pushassign
				(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,
				kc_updt_user, kc_updt_date)
			VALUES	(@wk_case_no, @pm_pusher_date, @pm_pusher_code, 'M1',
				USER, GETDATE())

			UPDATE	kcsd.kc_customerloan
			SET	kc_pusher_code = @pm_pusher_code, kc_pusher_date = @pm_pusher_date,
				kc_delay_code = 'M1'
			WHERE	kc_case_no = @wk_case_no


			/* 外包需額外修改的欄位 (Push Subcontractor) */
			IF	@pm_pusher_code LIKE 'Z%'
			BEGIN
				INSERT	kcsd.kc_lawstatus
					(kc_case_no, kc_law_date, kc_law_code)
				VALUES	(@wk_case_no, @pm_pusher_date, 'Z')

				UPDATE	kcsd.kc_customerloan
				SET	kc_boro_code = @pm_pusher_code, kc_boro_date = @pm_pusher_date,
					kc_boro_stat = 'O', kc_boro_memo = '外包處理'
				WHERE	kc_case_no = @wk_case_no
			END
		END
	INSERT	#tmp_pushassign_subcon
		(kc_case_no)
	VALUES	(@wk_case_no)

	FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no
END

SELECT	*
FROM	#tmp_pushassign_subcon
ORDER BY kc_case_no

DEALLOCATE	cursor_case_no_subcon

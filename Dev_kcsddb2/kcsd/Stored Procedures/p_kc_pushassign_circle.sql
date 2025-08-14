/*
手動指定轉指派 RR:
input: kc_tmpnopv2 (case no of cases to subcon)
param:	@pm_run_code:

*/
CREATE PROCEDURE [kcsd].[p_kc_pushassign_circle]
	@pm_run_code varchar(20)=NULL,
	@pm_pusher_code varchar(6)=NULL,
	@pm_total_no	int=1,
	@pm_pick_no	int=0
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pusher_code	varchar(6),		/* 新催款人 */
	@wk_count	int

CREATE TABLE #tmp_pushassign_subcon
(kc_case_no	varchar(10),
kc_pusher_code	varchar(6)
)

SELECT	@wk_case_no=NULL, @wk_count = 0

DECLARE	cursor_case_no_subcon	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_tmpnopv2
	ORDER BY kc_case_no

OPEN cursor_case_no_subcon
FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF	@wk_count = @pm_pick_no
	BEGIN
		INSERT	#tmp_pushassign_subcon
			(kc_case_no, kc_pusher_code)
		VALUES	(@wk_case_no, @pm_pusher_code)

		IF	@pm_run_code = 'EXECUTE'
		BEGIN
			UPDATE	kcsd.kc_tmpnopv2
			SET	kc_pusher_code = @pm_pusher_code
			WHERE	kc_case_no = @wk_case_no
		END
	END

	SELECT	@wk_count = ( @wk_count + 1 ) % @pm_total_no

	FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no
END

SELECT	*
FROM	#tmp_pushassign_subcon
ORDER BY kc_case_no

DEALLOCATE	cursor_case_no_subcon

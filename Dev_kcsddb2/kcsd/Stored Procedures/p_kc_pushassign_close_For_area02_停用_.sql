
CREATE PROCEDURE [kcsd].[p_kc_pushassign_close_For_area02(停用)]
AS

DECLARE	@wk_case_no AS varchar(10), @i AS INT

DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT kc_case_no
	FROM kcsd.kc_customerloan 
	WHERE kc_area_code IN ('02','11','12','14') and kc_pusher_code like 'P%' and kc_loan_stat IN ('D','G')
   	
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN

	UPDATE kcsd.kc_customerloan SET kc_pusher_code = NULL,kc_pusher_date = NULL	WHERE kc_case_no = @wk_case_no
	UPDATE kcsd.kc_pushassign SET kc_stop_date = CONVERT(VARCHAR(10),GETDATE(),120)	WHERE kc_case_no = @wk_case_no and kc_stop_date is null

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END
DEALLOCATE	cursor_case_no

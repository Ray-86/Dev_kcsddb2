CREATE PROCEDURE [kcsd].[p_kc_calendar_autoadd(停用)]
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_cale_date	smalldatetime

SELECT	@wk_case_no=NULL, @wk_cale_date=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_cale_date
	FROM	kcsd.kc_calendar_queue

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_cale_date


WHILE (@@FETCH_STATUS = 0)
BEGIN
	INSERT	kcsd.kc_calendar
		(kc_case_no, kc_cale_date)
	VALUES	(@wk_case_no, @wk_cale_date)

	DELETE	kcsd.kc_calendar_queue
	WHERE	kc_case_no = @wk_case_no
	AND	kc_cale_date = @wk_cale_date

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_cale_date
END

DEALLOCATE	cursor_case_no

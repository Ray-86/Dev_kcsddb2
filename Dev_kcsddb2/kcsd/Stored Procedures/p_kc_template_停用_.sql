CREATE PROCEDURE [kcsd].[p_kc_template(停用)]
AS
DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	


	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

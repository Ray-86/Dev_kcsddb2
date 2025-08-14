CREATE  PROCEDURE [kcsd].[p_kc_xtrigger_clear] AS
DECLARE	@wk_obj_name	varchar(100),
	@wk_sql		nvarchar(300)

SELECT	@wk_obj_name=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	name
	FROM	sysobjects
	WHERE	name like 'ins_%'
	OR	name like 'upd_%'
	OR	name like 'del_%'

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_obj_name


WHILE (@@FETCH_STATUS = 0)
BEGIN
	
	/*SELECT	@wk_obj_name*/

	SELECT	@wk_sql = 'drop trigger ' + @wk_obj_name
	EXECUTE sp_executesql @wk_sql

	FETCH NEXT FROM cursor_case_no INTO @wk_obj_name
END

DEALLOCATE	cursor_case_no

CREATE  PROCEDURE [kcsd].[p_kc_conflictcount] AS
DECLARE	@wk_obj_name	varchar(100),
	@wk_sql		nvarchar(300)

SELECT	@wk_obj_name=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	name
	FROM	sysobjects
	WHERE	name like '%onflict%'
	AND	xtype = 'U'

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_obj_name


WHILE (@@FETCH_STATUS = 0)
BEGIN
	
	/*SELECT	@wk_obj_name*/

	SELECT	@wk_sql = 'SELECT ''' + @wk_obj_name + ''', COUNT(*) FROM ' + @wk_obj_name
	EXECUTE sp_executesql @wk_sql

	FETCH NEXT FROM cursor_case_no INTO @wk_obj_name
END

DEALLOCATE cursor_case_no

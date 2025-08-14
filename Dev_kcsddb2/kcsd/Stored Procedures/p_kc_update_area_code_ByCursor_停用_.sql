CREATE PROCEDURE [kcsd].[p_kc_update_area_code_ByCursor(停用)]
AS

DECLARE	@wk_case_no AS varchar(10),	@wk_area_code AS varchar(2), @i AS INT

--kc_pushassign
DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT distinct TOP 20000 c.kc_case_no, c.kc_area_code
	FROM kcsd.kc_customerloan c right join kcsd.kc_lawstatus p  on c.kc_case_no = p.kc_case_no
	WHERE p.kc_area_code IS NULL
   	
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--PRINT @wk_case_no
	UPDATE kcsd.kc_lawstatus SET kc_area_code = @wk_area_code
	WHERE kc_case_no = @wk_case_no and kc_area_code IS NULL

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
END
DEALLOCATE	cursor_case_no

/*
--kc_pushassign
DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT distinct TOP 50 c.kc_case_no, c.kc_area_code
	FROM kcsd.kc_customerloan c right join kcsd.kc_pushassign p  on c.kc_case_no = p.kc_case_no
	WHERE p.kc_area_code IS NULL
   	
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--PRINT @wk_case_no
	UPDATE kcsd.kc_pushassign SET kc_area_code = @wk_area_code
	WHERE kc_case_no = @wk_case_no and kc_area_code IS NULL

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
END
DEALLOCATE	cursor_case_no

--kc_carstatus
DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT distinct TOP 500 c.kc_case_no, c.kc_area_code
	FROM kcsd.kc_customerloan c right join kcsd.kc_carstatus p  on c.kc_case_no = p.kc_case_no
	WHERE p.kc_area_code IS NULL
   	
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--PRINT @wk_case_no
	UPDATE kcsd.kc_carstatus SET kc_area_code = @wk_area_code
	WHERE kc_case_no = @wk_case_no and kc_area_code IS NULL

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
END
DEALLOCATE	cursor_case_no

--kc_push
DECLARE	cursor_case_no	CURSOR
FOR	SELECT cm.kc_case_no, cm.kc_area_code
   	FROM kcsd.kc_customerloan cm,kcsd.kc_push kp
   	WHERE cm.kc_case_no = kp.kc_case_no
   	AND kp.kc_area_code IS NULL

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN
	UPDATE kcsd.kc_push SET kc_area_code = @wk_area_code
	WHERE kc_case_no = @wk_case_no and kc_area_code IS NULL

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
END
DEALLOCATE	cursor_case_no

--kc_apptschedule
DECLARE	cursor_case_no	CURSOR
FOR	
	SELECT distinct c.kc_case_no, c.kc_area_code
	FROM kcsd.kc_customerloan c right join kcsd.kc_apptschedule p  on c.kc_case_no = p.kc_case_no
	WHERE p.kc_area_code IS NULL
   	
OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
SET @i = 1

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--PRINT @wk_case_no
	UPDATE kcsd.kc_apptschedule SET kc_area_code = @wk_area_code
	WHERE kc_case_no = @wk_case_no and kc_area_code IS NULL

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code
END
DEALLOCATE	cursor_case_no

*/

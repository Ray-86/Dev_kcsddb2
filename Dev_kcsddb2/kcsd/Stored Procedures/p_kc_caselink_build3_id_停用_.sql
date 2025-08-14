-- ==========================================================================================
-- 07/30/06 KC:	proc to build ID vs ID caselink (especially for old cases without CP)
-- ==========================================================================================
CREATE     PROCEDURE [kcsd].[p_kc_caselink_build3_id(停用)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_id_no	varchar(10),
	@wk_id_no1	varchar(10),
	@wk_id_no2	varchar(10)

-- =============================================

CREATE TABLE #tmp_caselink_id
(kc_case_no	varchar(10),
kc_case_no2	varchar(10)
)


DECLARE	cursor_caselink_id_global	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
--	WHERE	kc_case_no < '0301000'
--	WHERE	kc_case_no BETWEEN '0301000' AND '04'
--	WHERE	kc_case_no BETWEEN '05' AND '06'
	WHERE	kc_case_no > '06'
	ORDER BY kc_case_no

OPEN cursor_caselink_id_global
FETCH NEXT FROM cursor_caselink_id_global INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_id_no = NULL,
		@wk_id_no1 = NULL, @wk_id_no2 = NULL

	SELECT	@wk_id_no = kc_id_no,
		@wk_id_no1 = kc_id_no1, @wk_id_no2 = kc_id_no2
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	IF	@wk_id_no IS NOT NULL
		EXECUTE	kcsd.p_kc_caselink_build3_id_sub @wk_case_no, @wk_id_no
	IF	@wk_id_no1 IS NOT NULL
		EXECUTE	kcsd.p_kc_caselink_build3_id_sub @wk_case_no, @wk_id_no1
	IF	@wk_id_no2 IS NOT NULL
		EXECUTE	kcsd.p_kc_caselink_build3_id_sub @wk_case_no, @wk_id_no2
	
	FETCH NEXT FROM cursor_caselink_id_global INTO @wk_case_no
END

DEALLOCATE	cursor_caselink_id_global

SELECT	*
FROM	#tmp_caselink_id

DELETE
FROM	#tmp_caselink_id

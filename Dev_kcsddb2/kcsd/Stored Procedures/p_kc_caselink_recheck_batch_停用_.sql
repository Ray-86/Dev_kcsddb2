-- =============================================
-- 11/22/08 * use CP method to build DY2 case vs case
--          * Scan for all cases on DY2
-- =============================================
CREATE   PROCEDURE [kcsd].[p_kc_caselink_recheck_batch(停用)]
AS
DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no=NULL

DECLARE	cursor_caselink_reck_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no > '039'
	ORDER BY kc_case_no

OPEN cursor_caselink_reck_case_no
FETCH NEXT FROM cursor_caselink_reck_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_case_no
	-- 執行 caselink
	EXECUTE kcsd.p_kc_caselink_recheck @wk_case_no, 'EXECUTE'

	FETCH NEXT FROM cursor_caselink_reck_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_caselink_reck_case_no

-- ==========================================================================================
-- 06/11/06 KC: 因案件新建檔後 會刪除CP中該筆記錄, 所以必須由caseno 再執行一次caselink
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_caselink_build2(停用)]
AS
DECLARE	@wk_cp_no	varchar(10),
	@wk_case_no	varchar(10)

SELECT	@wk_cp_no=NULL, @wk_case_no=NULL

DECLARE	cursor_cpcase_no	CURSOR
FOR	SELECT	kc_cp_no, kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_cp_no IS NOT NULL
--	AND	kc_case_no like '04%'
--	AND	kc_case_no like '05%'
--	AND	kc_case_no = '0500594'
	AND	kc_case_no like '06%'
	AND	kc_case_no <'0608432'	-- don't care today's record
--	AND	kc_case_no like '9%'
	ORDER BY kc_case_no

OPEN cursor_cpcase_no
FETCH NEXT FROM cursor_cpcase_no INTO @wk_cp_no, @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_cp_no, @wk_case_no

	EXECUTE	kcsd.p_kc_caselink @wk_case_no, @wk_cp_no	

	FETCH NEXT FROM cursor_cpcase_no INTO @wk_cp_no, @wk_case_no
END

DEALLOCATE	cursor_cpcase_no

-- =============================================
-- 06/10/06 KC: proc to batch build caselink
-- =============================================
CREATE   PROCEDURE [kcsd].[p_kc_caselink_build(停用)]
AS
DECLARE	@wk_cp_no	varchar(10),
	@wk_case_no	varchar(10)

SELECT	@wk_cp_no=NULL, @wk_case_no=NULL

DECLARE	cursor_cpcase_no	CURSOR
FOR	SELECT	kc_cp_no, kc_case_no
	FROM	kcsd.kc_cpresult
	WHERE	(	kc_cust_type = 'C'
		OR	kc_cust_type = 'D')
	AND	(kc_cp_no LIKE '05%' OR kc_cp_no LIKE '06%')


OPEN cursor_cpcase_no
FETCH NEXT FROM cursor_cpcase_no INTO @wk_cp_no, @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_cp_no, @wk_case_no

	EXECUTE	kcsd.p_kc_caselink @wk_case_no, @wk_cp_no	


	FETCH NEXT FROM cursor_cpcase_no INTO @wk_cp_no, @wk_case_no
END

DEALLOCATE	cursor_cpcase_no

-- ==========================================================================================
-- 07/31/06 KC:	proc to remove dup caselink items to avoid error message
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_caselink_build4_killdup(停用)]
AS
DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no=NULL

DECLARE	cursor_caselink_b4	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_caselink
	GROUP BY kc_case_no
	HAVING COUNT(kc_link_no) > 1
	ORDER BY kc_case_no

OPEN cursor_caselink_b4
FETCH NEXT FROM cursor_caselink_b4 INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_case_no

	EXECUTE	p_kc_caselink_build4_killdup_sub @wk_case_no

	FETCH NEXT FROM cursor_caselink_b4 INTO @wk_case_no
END

DEALLOCATE	cursor_caselink_b4

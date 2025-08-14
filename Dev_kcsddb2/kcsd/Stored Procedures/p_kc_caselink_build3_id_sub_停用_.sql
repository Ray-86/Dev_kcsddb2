-- ==========================================================================================
-- 07/30/06 KC:	proc to build ID vs ID caselink (especially for old cases without CP)
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_caselink_build3_id_sub(停用)]
	@pm_case_no varchar(10)=NULL, @pm_id_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no = NULL

DECLARE	cursor_caselink_r3	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no <> @pm_case_no
	AND	(	kc_id_no = @pm_id_no
		OR	kc_id_no1 = @pm_id_no
		OR	kc_id_no2 = @pm_id_no)

OPEN cursor_caselink_r3
FETCH NEXT FROM cursor_caselink_r3 INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF NOT EXISTS (
		SELECT	a.kc_link_no
		FROM	kcsd.kc_caselink a, kcsd.kc_caselink b
		WHERE	a.kc_link_no = b.kc_link_no
		AND	a.kc_case_no = @pm_case_no
		AND	b.kc_case_no = @wk_case_no
		)
	BEGIN
		SELECT	@pm_case_no, @wk_case_no

		INSERT	#tmp_caselink_id
			(kc_case_no, kc_case_no2)
		VALUES	(@pm_case_no, @wk_case_no)

		EXECUTE kcsd.p_kc_caselink_sub_connect @pm_case_no, @wk_case_no
	END

	FETCH NEXT FROM cursor_caselink_r3 INTO @wk_case_no
END

DEALLOCATE	cursor_caselink_r3

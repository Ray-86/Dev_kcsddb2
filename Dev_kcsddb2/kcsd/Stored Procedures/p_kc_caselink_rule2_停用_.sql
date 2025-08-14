-- ==========================================================================================
-- 07/08/06 KC:	改為獨立的 caselink_rule2
-- 07/01/06 KC:	Fix 同一天CP不會連結, 漏網之魚
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_caselink_rule2(停用)]
	@pm_case_no varchar(10)=NULL,
	@pm_cp_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_oldcp_no	varchar(10)

-- =============================================
IF EXISTS (
	SELECT	kc_case_no
	FROM	kcsd.kc_cpresult
	WHERE	kc_cp_no = @pm_cp_no
	AND	kc_cust_type = 'CP')		-- CP
BEGIN
	DECLARE	cursor_caselink_cp	CURSOR
	FOR	SELECT	kc_case_no
		FROM	kcsd.kc_cpresult
		WHERE	kc_cp_no = @pm_cp_no
		AND	kc_cust_type = 'CP'

	OPEN cursor_caselink_cp
	FETCH NEXT FROM cursor_caselink_cp INTO @wk_oldcp_no

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT	@wk_case_no = NULL

		SELECT	@wk_case_no = kc_case_no
		FROM	kcsd.kc_customerloan
		WHERE	kc_cp_no = @wk_oldcp_no

		-- Skip if with CP but NO case_no 
		IF	@wk_case_no IS NULL
		BEGIN
			FETCH NEXT FROM cursor_caselink_cp INTO @wk_oldcp_no
			CONTINUE
		END

		-- Check 是否 CP 結果是 已經有 C/D, 若非 C/D 則需處理
		IF NOT EXISTS (
			SELECT	kc_case_no
			FROM	kcsd.kc_cpresult
			WHERE	kc_cp_no = @pm_cp_no
			AND	(	kc_cust_type = 'C'
				OR	kc_cust_type = 'D')	--分期客戶或保人
			AND	kc_case_no = @wk_case_no
			)
		BEGIN
			-- SELECT	@pm_case_no, @pm_cp_no, @wk_case_no, @wk_oldcp_no
			EXECUTE kcsd.p_kc_caselink_sub_connect @pm_case_no, @wk_case_no
		END

		FETCH NEXT FROM cursor_caselink_cp INTO @wk_oldcp_no
	END
	DEALLOCATE	cursor_caselink_cp

END

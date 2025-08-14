-- ==========================================================================================
-- 20150824 修正插入重複資料問題 (判斷條件錯誤)
-- 11/17/06 KC: fix a bug for MAX cp number (忘記 SELECT MAX, 故產生莫名其妙連結)
-- 07/31/06 KC: A. fix @pm_case_no2 (之前無連結) can't link to @pm_case_no		
--		B. quit when already linked
--		(bug found when executing caselink_build3_id)
-- 07/17/06 KC: fix insert kc_caselink with column names failed because of new column added
-- 07/01/06 KC: sub to connect to cases
-- ==========================================================================================
CREATE         PROCEDURE [kcsd].[p_kc_caselink_sub_connect(停用)] @pm_case_no varchar(10)=NULL, @pm_case_no2 varchar(10)=NULL
AS
DECLARE	@wk_link_no	int,
	@wk_link_count	int,
	@wk_link_max	int,
	@wk_olink_no	int

IF	@pm_case_no IS NULL
OR	@pm_case_no2 IS NULL
	RETURN

-- 已有連結, 直接離開
IF EXISTS (
	SELECT	a.kc_link_no
	FROM	kcsd.kc_caselink a, kcsd.kc_caselink b
	WHERE	a.kc_link_no = b.kc_link_no
	AND	a.kc_case_no = @pm_case_no
	AND	b.kc_case_no = @pm_case_no2 )
	RETURN

SELECT	@wk_link_no = 0

-- Check if they are alreay linked with anyone
SELECT	@wk_link_count = COUNT(*) 
FROM	kcsd.kc_caselink
WHERE	kc_case_no = @pm_case_no
OR	kc_case_no = @pm_case_no2

IF	@wk_link_count = 0
BEGIN	-- Build new
	SELECT	@wk_link_max = MAX(ISNULL(kc_link_no, 0))
	FROM	kcsd.kc_caselink

	SELECT	@wk_link_no = @wk_link_max + 1

	INSERT	kcsd.kc_caselink
		(kc_link_no, kc_case_no, kc_updt_user, kc_updt_date)
	VALUES	(@wk_link_no, @pm_case_no, USER, GETDATE())

	INSERT	kcsd.kc_caselink
		(kc_link_no, kc_case_no, kc_updt_user, kc_updt_date)
	VALUES	(@wk_link_no, @pm_case_no2, USER, GETDATE())

END	
ELSE	
BEGIN	-- Merge
	SELECT	@wk_link_no = MIN(kc_link_no)
	FROM	kcsd.kc_caselink
	WHERE	kc_case_no = @pm_case_no
	OR	kc_case_no = @pm_case_no2

	-- =============================================
	-- case_no 1
	SELECT	@wk_olink_no = kc_link_no
	FROM	kcsd.kc_caselink
	WHERE	kc_case_no = @pm_case_no
	AND	kc_link_no = @wk_link_no

	IF	@wk_olink_no IS NULL		-- his link or he has no link
	BEGIN
		INSERT	kcsd.kc_caselink
			(kc_link_no, kc_case_no, kc_updt_user, kc_updt_date)
		VALUES	(@wk_link_no, @pm_case_no, USER, GETDATE())		
	END
	ELSE					-- merge
	BEGIN
		UPDATE	kcsd.kc_caselink
		SET	kc_link_no = @wk_link_no, kc_updt_user = USER, kc_updt_date = GETDATE()
		WHERE	kc_link_no = @wk_olink_no
	END
	-- =============================================
	-- case_no 2
	--SELECT	@wk_olink_no = NULL
	SELECT	@wk_olink_no = kc_link_no
	FROM	kcsd.kc_caselink
	WHERE	kc_case_no = @pm_case_no2
	AND	kc_link_no = @wk_link_no

	IF	@wk_olink_no IS NULL		-- his link or he has no link
	BEGIN
		INSERT	kcsd.kc_caselink
			(kc_link_no, kc_case_no, kc_updt_user, kc_updt_date)
		VALUES	(@wk_link_no, @pm_case_no2, USER, GETDATE())	-- 07/31/06 KC: fixed
	END
	ELSE					-- merge
	BEGIN
		UPDATE	kcsd.kc_caselink
		SET	kc_link_no = @wk_link_no, kc_updt_user = USER, kc_updt_date = GETDATE()
		WHERE	kc_link_no = @wk_olink_no
	END

END

-- ==========================================================================================
-- 07/31/06 KC:	sub to remove dup caselink items for a case to avoid error message
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_caselink_build4_killdup_sub(停用)] @pm_case_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_link_min	int

IF	@pm_case_no IS NULL
	RETURN

CREATE TABLE #tmp_caselink_no
(kc_link_no	int)

CREATE TABLE #tmp_caselink_case_no
(kc_case_no	varchar(10))

CREATE TABLE #tmp_caselink_case_no_nodup
(kc_case_no	varchar(10))

SELECT	@wk_case_no=NULL

-- get MIN link_no for this case
SELECT	@wk_link_min = MIN(kc_link_no)
FROM	kcsd.kc_caselink
WHERE	kc_case_no = @pm_case_no

-- get all link no for this case
INSERT	#tmp_caselink_no
SELECT	kc_link_no
FROM	kcsd.kc_caselink
WHERE	kc_case_no = @pm_case_no

-- get all case_no from those links
INSERT	#tmp_caselink_case_no
SELECT	c.kc_case_no
FROM	kcsd.kc_caselink c, #tmp_caselink_no t
WHERE	c.kc_link_no = t.kc_link_no

-- get distinct (Answer !!!)
INSERT	#tmp_caselink_case_no_nodup
SELECT	DISTINCT kc_case_no
FROM	#tmp_caselink_case_no

-- Kill all
DELETE
FROM	kcsd.kc_caselink
WHERE	kc_link_no IN (SELECT	kc_link_no
			FROM	#tmp_caselink_no)

-- re-insert to MIN
INSERT	kcsd.kc_caselink
	(kc_link_no, kc_case_no, kc_updt_user, kc_updt_date)
SELECT	@wk_link_min, kc_case_no, USER, GETDATE()
FROM	#tmp_caselink_case_no_nodup

DROP TABLE #tmp_caselink_no

DROP TABLE #tmp_caselink_case_no

DROP TABLE #tmp_caselink_case_no_nodup

-- ==========================================================================================
-- 05/15/06 KC:	* modify from p_kc_getuserinfo_ismember
-- 		* return param output and used internally
--		* don't know if it works if merge with p_kc_getuserinfo_ismember
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_getuserinfo_ismember_sub]
	@pm_group_name	varchar(20)=NULL,
	@pm_user_name	varchar(20)=NULL,
	@pm_member_flag varchar(1)='N' OUTPUT
AS

DECLARE	@wk_user_id	smallint,
	@wk_group_id	smallint

IF	@pm_user_name IS NULL
	SELECT	@pm_user_name = USER_NAME()

IF	@pm_group_name IS NULL
BEGIN
	SELECT	@pm_member_flag = 'N'
	RETURN
END

SELECT	@pm_group_name = UPPER(@pm_group_name)

SELECT	@wk_user_id = uid
FROM	sysusers
WHERE	name = @pm_user_name

SELECT	@wk_group_id = uid
FROM	sysusers
WHERE	name = @pm_group_name

/*
IF	EXISTS
	(SELECT	'X'
	FROM	sysusers a, sysusers b
	WHERE	a.gid = b.uid
	AND	a.name = @pm_user_name
	AND	b.name = @pm_group_name
	)
	SELECT	'1'
ELSE
	SELECT	'0'
*/

IF	EXISTS
	(SELECT	'X'
	FROM	sysmembers
	WHERE	memberuid = @wk_user_id
	AND	groupuid = @wk_group_id
	)
	SELECT	@pm_member_flag = 'Y'
ELSE
	SELECT	@pm_member_flag = 'N'


/*AND	b.name <> 'MGRS' */	/* KC 09/01/2004 */

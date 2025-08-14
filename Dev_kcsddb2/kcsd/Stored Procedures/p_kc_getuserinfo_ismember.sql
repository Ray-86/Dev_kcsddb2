CREATE   PROCEDURE [kcsd].[p_kc_getuserinfo_ismember]
@pm_group_name	varchar(20)=NULL,
@pm_user_name	varchar(20)=NULL
AS

DECLARE	@wk_user_id	smallint,
	@wk_group_id	smallint

IF	@pm_user_name IS NULL
	SELECT	@pm_user_name = USER_NAME()

IF	@pm_group_name IS NULL
BEGIN
	SELECT	'0'
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
	SELECT	'1'
ELSE
	SELECT	'0'


/*AND	b.name <> 'MGRS' */	/* KC 09/01/2004 */

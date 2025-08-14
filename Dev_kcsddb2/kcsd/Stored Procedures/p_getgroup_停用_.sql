CREATE  PROCEDURE [kcsd].[p_getgroup(停用)]	@pm_group_name	char(10) OUTPUT
AS
SELECT	@pm_group_name = LTRIM(RTRIM(ISNULL(b.name,'public')))
FROM	sysusers a, sysusers b
WHERE	a.gid = b.uid
AND	a.name = USER_NAME()
AND	b.name <> 'MGRS'	/* KC 09/01/2004 */

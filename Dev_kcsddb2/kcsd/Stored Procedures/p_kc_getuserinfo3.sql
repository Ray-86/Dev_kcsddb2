-- ==========================================================================================
-- 2011-07-16 Check security with version, IP
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_getuserinfo3] @pm_ver_no int=0, @pm_ip_addr varchar(20)=NULL
AS
DECLARE	@wk_user_gid	int,
	@wk_user_group	varchar(200),
	@wk_group_name	varchar(20),
	@wk_emp_code	varchar(10),
	@wk_emp_name	varchar(20)

IF	@pm_ver_no = 0
OR	@pm_ip_addr IS NULL
	RETURN

SELECT	@wk_user_gid = 0, @wk_user_group = ' ',
	@wk_emp_code = 'XXX', @wk_emp_name = 'XXXX'

--RAISERROR ('Job id 1 expects the default level of 10.', 23, 1)
--RETURN

/* get emp code */
SELECT	@wk_emp_code = kc_emp_code, @wk_emp_name = kc_emp_name
FROM	kcsd.kc_employee
WHERE	kc_user_name = USER_NAME()

/* get group info */
SELECT	@wk_user_group = @wk_user_group + ' ' + g.name
FROM	sysmembers m, sysusers g
WHERE	m.memberuid = USER_ID()
AND	m.groupuid = g.uid
AND	g.name <> 'MGRS'		/* KC 09/01/2004 */
ORDER BY g.name

--SELECT	@wk_user_group = 'PUS'

SELECT	USER_NAME() AS wk_user_name , LTRIM(RTRIM(@wk_user_group)) AS wk_group_name,
	@wk_emp_code AS wk_emp_code, @wk_emp_name AS wk_emp_name

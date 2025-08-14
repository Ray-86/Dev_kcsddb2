-- ==========================================================================================
-- 2013-03-13 增加HOSTNAME欄位
-- ==========================================================================================

CREATE    PROCEDURE [kcsd].[p_kc_getuserinfo] AS
DECLARE	@wk_user_gid	int,
	@wk_user_group	varchar(200),
	@wk_group_name	varchar(20),
	@wk_emp_code	varchar(10),
	@wk_emp_name	varchar(20),
	@wk_host_name	varchar(20),
	@wk_phone_ext	varchar(10),
	@wk_ippbx_ip	varchar(12)

SELECT	@wk_user_gid = 0, @wk_user_group = ' ',
	@wk_emp_code = 'XXX', @wk_emp_name = 'XXXX'

/* get emp code */
SELECT	@wk_emp_code = kc_emp_code, @wk_emp_name = kc_emp_name,@wk_phone_ext = kc_phone_ext,@wk_host_name = @@SERVERNAME
FROM	kcsd.kc_employee
WHERE	kc_user_name = USER_NAME()

/* get group info */
SELECT	@wk_user_group = @wk_user_group + ' ' + g.name
FROM	sysmembers m, sysusers g
WHERE	m.memberuid = USER_ID()
AND	m.groupuid = g.uid
--AND	g.name <> 'MGRS'		/* KC 09/01/2004 */
ORDER BY g.name


/*
if (@@SERVERNAME='DYS01')  select @wk_host_name = 'DYS01'
else if  (@@SERVERNAME='DYAP01')select @wk_host_name = 'DYAP01'
else if  (@@SERVERNAME='DYS11')  select @wk_host_name = 'DYS11'
else if  (@@SERVERNAME='DYS21')  select @wk_host_name = 'DYS21'
else if  (@@SERVERNAME='DYS31')  select @wk_host_name = 'DYS31'
else if  (@@SERVERNAME='DYS71')  select @wk_host_name = 'DYS71'
else if  (@@SERVERNAME='DYS81')  select @wk_host_name = 'DYS81'
else if  (@@SERVERNAME='DYS91')  select @wk_host_name = 'DYS91'
else if  (@@SERVERNAME='DYS05B')  select @wk_host_name = 'DYS05B'
else if  (@@SERVERNAME='DYS10')  select @wk_host_name = 'DYS10'
else if  (@@SERVERNAME='DYS101')  select @wk_host_name = 'DYS101'
else select @wk_host_name = '未知 ' + @@SERVERNAME
*/
SELECT	USER_NAME() AS wk_user_name , LTRIM(RTRIM(@wk_user_group)) AS wk_group_name,
	@wk_emp_code AS wk_emp_code, @wk_emp_name AS wk_emp_name,@wk_host_name AS wk_host_name,@wk_phone_ext AS wk_phone_ext

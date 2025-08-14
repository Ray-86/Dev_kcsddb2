
--20130425 增加辨識帳號權限
CREATE  view [kcsd].[v_kc_menu] 
AS

SELECT	DISTINCT m.*
FROM	kcsd.kc_menu m, kcsd.kc_menuaccess s
WHERE	m.kc_item_item = s.kc_item_item
AND	(s.kc_grant_name IN
(SELECT	u.name
FROM	sysmembers b, sysusers u
WHERE	b.memberuid = USER_ID()
AND	b.groupuid = u.uid
) OR s.kc_grant_name =  USER_NAME())


create procedure [kcsd].[p_kc_menu_getmenu(停用)] @pm_item_group varchar(100)=''
AS
IF	@pm_item_group IS NULL	
BEGIN
	SELECT	*
	FROM	kcsd.kc_menu
	ORDER BY kc_item_code
	RETURN
END

SELECT	*
FROM	kcsd.kc_menu
WHERE	kc_item_group = @pm_item_group
ORDER BY kc_item_code

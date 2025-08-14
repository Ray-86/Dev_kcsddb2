CREATE  PROCEDURE [kcsd].[p_kc_addrhistory_create_sub1]
@pm_id_no varchar(10), @pm_addr_type varchar(2),
@pm_addr_data varchar(100), @pm_addr_note varchar(100)=NULL
AS
DECLARE	@wk_count	int

IF	@pm_id_no is NULL OR @pm_addr_data is NULL
	RETURN

SELECT	@wk_count = COUNT(*)
FROM	kcsd.kc_addresshistory
WHERE	kc_id_no = @pm_id_no
AND	kc_addr_type = @pm_addr_type

/* really insert */
INSERT	kcsd.kc_addresshistory
	(kc_id_no, kc_addr_type, kc_updt_date, kc_addr_data, kc_addr_note, kc_updt_user)
VALUES
	(@pm_id_no, @pm_addr_type, DATEADD(minute,@wk_count,GETDATE()), @pm_addr_data, @pm_addr_note, USER)
/*
IF	@wk_count>1
	SELECT	@pm_id_no, @wk_count
*/

/*

P1: ñß─y╣q©▄, P2:│q░T, P3:ñ¢Ñq, P4:ªµ░╩╣q©▄
A1: ñß─yªa  A2: │q░Tªaº}  A3:ñ¢Ñqªaº}  A4:╣║╝Àªaº}
*/
CREATE   PROCEDURE [kcsd].[p_kc_addrhistory]
@pm_id_no varchar(10), @pm_addr_type varchar(2),
@pm_addr_data varchar(100), @pm_addr_note varchar(100)=NULL

AS

IF	@pm_id_no is NULL
	RETURN

INSERT kcsd.kc_addresshistory
(kc_id_no, kc_addr_type, kc_updt_date, kc_addr_data, kc_addr_note, kc_updt_user)
VALUES
(@pm_id_no, @pm_addr_type, GETDATE(), @pm_addr_data, @pm_addr_note, USER)

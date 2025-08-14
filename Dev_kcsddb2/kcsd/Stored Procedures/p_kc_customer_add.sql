CREATE  PROCEDURE [kcsd].[p_kc_customer_add]
@pm_cust_name varchar(30),
@pm_id_no varchar(20),
@pm_cust_role varchar(10),
@pm_area_code varchar(2)
AS

IF	@pm_cust_name IS NULL
OR	@pm_area_code IS NULL
	RETURN

insert	kc_customer
	(kc_cust_name, kc_id_no, kc_cust_role, kc_area_code, kc_updt_user, kc_updt_date)
values	(@pm_cust_name , @pm_id_no, @pm_cust_role, @pm_area_code, USER, GETDATE())

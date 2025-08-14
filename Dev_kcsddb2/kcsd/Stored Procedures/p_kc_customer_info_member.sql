-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE      PROCEDURE [kcsd].[p_kc_customer_info_member] @wk_member_no varchar(20)
AS
SELECT * FROM (
	SELECT kc_member_no,'00' AS kc_type_code,'本人' AS kc_type_name,'戶籍' AS kc_data_type,kc_member_name,null as kc_relation_no,kc_id_no,kc_birth_date,
	kc_perm_phone AS kc_perm_phone,null AS kc_perm_nt,kc_mobil_no AS kc_mobile,kc_permmember_type, kc_currmember_type,kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,
	kc_line_no AS kc_line_no, kc_papa_nameu AS kc_papa_name , kc_mama_nameu AS kc_mama_name, kc_mate_nameu AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'01' AS kc_type_code,null AS kc_type_name,'住家' AS kc_data_type,null AS kc_member_name,null as kc_relation_no,null AS kc_id_no,null  as kc_birth_date,
	kc_curr_phone AS kc_perm_phone,null AS kc_perm_nt, null AS kc_mobile,kc_permreside_type as kc_permmember_type,kc_currreside_type as kc_currmember_type,	
	kc_curr_addr as kc_perm_addr,kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'02' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_member_name,null as kc_relation_no,null AS kc_id_no,null  as kc_birth_date,
	kc_comp_phone AS kc_perm_phone,kc_comp_ext AS kc_perm_nt, null AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	kc_comp_addr as kc_perm_addr,null as kc_contact_memo,kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'03' AS kc_type_code,'聯一' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name3u AS kc_member_name,kc_relation_no3 as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,kc_mobil_no3 AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'04' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_member_name,null as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,null AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'05' AS kc_type_code,'聯二' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name4u AS kc_member_name,kc_relation_no4 as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,kc_mobil_no4 AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'06' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_member_name,null as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,null AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'07' AS kc_type_code,'聯三' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name6u AS kc_member_name,kc_relation_no6 as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,kc_mobil_no6 AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
	UNION
	SELECT kc_member_no,'08' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_member_name,null as kc_relation_no,null AS kc_id_no,null as kc_birth_date,
	null AS kc_perm_phone,null AS kc_perm_nt,null AS kc_mobile,null as kc_permmember_type,null as kc_currmember_type,	
	null as kc_perm_addr,null as kc_contact_memo,null as kc_comp_desc,null AS kc_line_no, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name
	FROM kcsd.kc_memberdata WHERE kc_member_no = @wk_member_no
) A
order by kc_type_code



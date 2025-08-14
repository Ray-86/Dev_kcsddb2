
CREATE        PROCEDURE [kcsd].[p_kc_customer_info] @wk_case_no varchar(10)
AS
SELECT * FROM (
	SELECT kc_case_no,kc_area_code,'00' AS kc_type_code,'本人' AS kc_type_name,'戶籍' AS kc_data_type,kc_cust_nameu,kc_id_no,kc_cust_stat AS kc_cust_stat,kc_birth_date,null as kc_rela_code,
	kc_mobil_no AS kc_mobile,kc_mobil_no_nt AS kc_monile_nt, kc_perm_stat AS kc_addr_stat, kc_perm_addr AS kc_addr, kc_perm_addr_nt AS kc_addr_nt, kc_perm_phone AS kc_phone, kc_perm_phone_nt AS kc_phone_nt, 
	null AS kc_comp_name, kc_papa_nameu AS kc_papa_name, kc_mama_nameu AS kc_mama_name, kc_mate_nameu AS kc_mate_name,kc_line_no AS kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'01' AS kc_type_code,null AS kc_type_name,'住家' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	kc_fax_phone AS kc_mobile,kc_fax_phone_nt AS kc_monile_nt, kc_curr_stat AS kc_addr_stat, kc_curr_addr AS kc_addr, kc_curr_addr_nt AS kc_addr_nt, kc_curr_phone AS kc_phone, kc_curr_phone_nt AS kc_phone_nt, 
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name ,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'02' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, kc_comp_stat AS kc_addr_stat, kc_comp_addr AS kc_addr, kc_comp_addr_nt AS kc_addr_nt, kc_comp_phone AS kc_phone, kc_comp_phone_nt AS kc_phone_nt, 
	kc_comp_namea AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'03' AS kc_type_code,'保一' AS kc_type_name,'戶籍' AS kc_data_type,kc_cust_name1u,kc_id_no1,kc_cust_stat1 AS kc_cust_stat,kc_birth_date1,kc_rela_code1 AS kc_rela_code,
	kc_mobil_no1 AS kc_mobile,kc_mobil_no1_nt AS kc_monile_nt, kc_perm_stat1 AS kc_addr_stat, kc_perm_addr1 AS kc_addr, kc_perm_addr1_nt AS kc_addr_nt, kc_perm_phone1 AS kc_phone, kc_perm_phone1_nt AS kc_phone_nt, 
	null AS kc_comp_name, kc_papa_name1u AS kc_papa_name, kc_mama_name1u AS kc_mama_name, kc_mate_name1u AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'04' AS kc_type_code,null AS kc_type_name,'住家' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	kc_mobil_no12 AS kc_mobile,kc_mobil_no12_nt AS kc_monile_nt, kc_curr_stat1 AS kc_addr_stat, kc_curr_addr1 AS kc_addr, kc_curr_addr1_nt AS kc_addr_nt, kc_curr_phone1 AS kc_phone, kc_curr_phone1_nt AS kc_phone_nt, 
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'05' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, kc_comp_stat1 AS kc_addr_stat, kc_comp_addr1 AS kc_addr, kc_comp_addr1_nt AS kc_addr_nt, kc_comp_phone1 AS kc_phone, kc_comp_phone1_nt AS kc_phone_nt, 
	kc_comp_namea1 AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'06' AS kc_type_code,'保二' AS kc_type_name,'戶籍' AS kc_data_type,kc_cust_name2u,kc_id_no2,kc_cust_stat2 AS kc_cust_stat,kc_birth_date2,kc_rela_code2 AS kc_rela_code,
	kc_mobil_no2 AS kc_mobile,kc_mobil_no2_nt AS kc_monile_nt, kc_perm_stat2 AS kc_addr_stat, kc_perm_addr2 AS kc_addr, kc_perm_addr2_nt AS kc_addr_nt, kc_perm_phone2 AS kc_phone, kc_perm_phone2_nt AS kc_phone_nt, 
	null AS kc_comp_name, kc_papa_name2u AS kc_papa_name, kc_mama_name2u AS kc_mama_name, kc_mate_name2u AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'07' AS kc_type_code,null AS kc_type_name,'住家' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, kc_curr_stat2 AS kc_addr_stat, kc_curr_addr2 AS kc_addr, kc_curr_addr2_nt AS kc_addr_nt, kc_curr_phone2 AS kc_phone, kc_curr_phone2_nt AS kc_phone_nt, 
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'08' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null AS kc_cust_nameu,null AS kc_id_no,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, kc_comp_stat2 AS kc_addr_stat, kc_comp_addr2 AS kc_addr, kc_comp_addr2_nt AS kc_addr_nt, kc_comp_phone2 AS kc_phone, kc_comp_phone2_nt AS kc_phone_nt, 
	kc_comp_namea2 AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'09' AS kc_type_code,'聯一' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name3u,null,null,null,kc_rela_code3 as kc_rela_code,
	kc_mobil_no3 AS kc_mobile,kc_mobil_no3_nt AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_curr_phone3 AS kc_phone, kc_curr_phone3_nt AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'10' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null,null,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_comp_phone3 AS kc_phone, null AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'11' AS kc_type_code,'聯二' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name4u,null,null,null,kc_rela_code4 as kc_rela_code,
	kc_mobil_no4 AS kc_mobile,kc_mobil_no4_nt AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_curr_phone4 AS kc_phone, kc_curr_phone4_nt AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'12' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null,null,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_comp_phone4 AS kc_phone, null AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'13' AS kc_type_code,'聯三' AS kc_type_name,'住家' AS kc_data_type,kc_cust_name6u,null,null,null,kc_rela_code6 as kc_rela_code,
	kc_mobil_no6 AS kc_mobile,kc_mobil_no6_nt AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_curr_phone6 AS kc_phone, kc_curr_phone6_nt AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'14' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null,null,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, null AS kc_addr_stat, null AS kc_addr, null AS kc_addr_nt, kc_comp_phone6 AS kc_phone, null AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'15' AS kc_type_code,'使用' AS kc_type_name,'戶籍' AS kc_data_type,kc_cust_name5u,kc_id_no5,null,kc_birth_date5,kc_rela_code5 AS kc_rela_code,
	kc_mobil_no5 AS kc_mobile,kc_mobil_no5_nt AS kc_monile_nt, null AS kc_addr_stat, kc_perm_addr5 AS kc_addr, kc_perm_addr5_nt AS kc_addr_nt, kc_perm_phone5 AS kc_phone, kc_perm_phone5_nt AS kc_phone_nt,
	null AS kc_comp_name, kc_papa_name5u AS kc_papa_name, kc_mama_name5u AS kc_mama_name, kc_mate_name5u AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan1 WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'16' AS kc_type_code,null AS kc_type_name,'住家' AS kc_data_type,null,null,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, null AS kc_addr_stat, kc_curr_addr5 AS kc_addr, kc_curr_addr5_nt AS kc_addr_nt, kc_curr_phone5 AS kc_phone, kc_curr_phone5_nt AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan1 WHERE kc_case_no = @wk_case_no
	UNION
	SELECT kc_case_no,kc_area_code,'17' AS kc_type_code,null AS kc_type_name,'公司' AS kc_data_type,null,null,null,null,null as kc_rela_code,
	null AS kc_mobile,null AS kc_monile_nt, null AS kc_addr_stat, kc_comp_addr5 AS kc_addr, kc_comp_addr5_nt AS kc_addr_nt, kc_comp_phone5 AS kc_phone, kc_comp_phone5_nt AS kc_phone_nt,
	null AS kc_comp_name, null AS kc_papa_name, null AS kc_mama_name, null AS kc_mate_name,null as kc_line_no
	FROM kcsd.kc_customerloan1 WHERE kc_case_no = @wk_case_no
) A
order by kc_type_code

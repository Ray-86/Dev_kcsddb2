CREATE    PROCEDURE [kcsd].[p_kc_creditcheck_area(停用)] @pm_query_input char(20)
AS
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	kc_cust_role as wk_cust_type, kc_cust_role as wk_link_type, kc_area_desc as wk_link_info,
	'' as wk_loan_stat
FROM	kcsd.kc_customer c LEFT JOIN kcsd.kct_area a ON c.kc_area_code = a.kc_area_code
WHERE	c.kc_cust_name = @pm_query_input
OR	c.kc_id_no = @pm_query_input

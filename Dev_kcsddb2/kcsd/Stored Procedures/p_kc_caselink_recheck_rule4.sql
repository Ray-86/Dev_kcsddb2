CREATE  PROCEDURE [kcsd].[p_kc_caselink_recheck_rule4] @pm_papa_name nvarchar(60), @pm_mama_name nvarchar(60),@pm_id_no varchar(10)
AS
--規則4: 兄弟辦過: P 與其他 P 相同 (兄弟姊妹曾辦過 或保過)
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'本人','兄弟' FROM	kcsd.kc_customerloan WHERE (kc_papa_nameu = @pm_papa_name 	AND	kc_mama_nameu = @pm_mama_name) and kc_id_no <> @pm_id_no
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保1','兄弟' FROM	kcsd.kc_customerloan WHERE (kc_papa_name1u = @pm_papa_name	AND	kc_mama_name1u = @pm_mama_name) and kc_id_no1 <> @pm_id_no
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保2','兄弟' FROM	kcsd.kc_customerloan WHERE (kc_papa_name2u = @pm_papa_name	AND	kc_mama_name2u = @pm_mama_name) and kc_id_no2 <> @pm_id_no

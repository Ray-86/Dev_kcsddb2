CREATE  PROCEDURE [kcsd].[p_kc_caselink_recheck_rule2] @pm_cust_name nvarchar(60), @pm_mate_name nvarchar(60)
AS
--規則2: 父母辦過 Name 與其他 P 相同, 且 Mate 為該件 P
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'本人','父母' FROM	kcsd.kc_customerloan WHERE (kc_papa_nameu = @pm_cust_name	AND	kc_mama_nameu = @pm_mate_name)	OR	(kc_mama_nameu = @pm_cust_name	AND	kc_papa_nameu = @pm_mate_name)
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保1','父母' FROM	kcsd.kc_customerloan WHERE (kc_papa_name1u = @pm_cust_name	AND	kc_mama_name1u = @pm_mate_name)	OR	(kc_mama_name1u = @pm_cust_name	AND	kc_papa_name1u = @pm_mate_name)
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保2','父母' FROM	kcsd.kc_customerloan WHERE (kc_papa_name2u = @pm_cust_name	AND	kc_mama_name2u = @pm_mate_name)	OR	(kc_mama_name2u = @pm_cust_name	AND	kc_papa_name2u = @pm_mate_name)

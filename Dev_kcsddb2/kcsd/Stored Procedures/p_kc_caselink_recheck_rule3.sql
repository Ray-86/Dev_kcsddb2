CREATE   PROCEDURE [kcsd].[p_kc_caselink_recheck_rule3] @pm_cust_name nvarchar(60), @pm_mate_name nvarchar(60)
AS
--規則3: 配偶辦過: Mate 與其他 Name 相同, 且 Mate 為該件 Name
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'本人','配偶' FROM	kcsd.kc_customerloan WHERE (kc_cust_nameu = @pm_mate_name AND kc_mate_nameu = @pm_cust_name)
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保1','配偶' FROM	kcsd.kc_customerloan WHERE (kc_cust_name1u = @pm_mate_name AND	kc_mate_name1u = @pm_cust_name)
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保2','配偶' FROM	kcsd.kc_customerloan WHERE (kc_cust_name2u = @pm_mate_name	AND	kc_mate_name2u = @pm_cust_name)


CREATE  PROCEDURE [kcsd].[p_kc_caselink_recheck_rule6] @pm_papa_name nvarchar(60), @pm_mama_name nvarchar(60)
AS
-- Rule 6: 父母辦過: P 與其他 Name 相同, 且另一 P為該件 C
INSERT	#tmp_caselink_recheck_case
SELECT	kc_case_no
FROM	kcsd.kc_customerloan
WHERE	
	(	kc_cust_nameu = @pm_papa_name
	AND	kc_mate_nameu = @pm_mama_name)
	OR
	(	kc_cust_nameu = @pm_mama_name
	AND	kc_mate_nameu = @pm_papa_name)
	OR
	(	kc_cust_name1u = @pm_papa_name
	AND	kc_mate_name1u = @pm_mama_name)
	OR
	(	kc_cust_name1u = @pm_mama_name
	AND	kc_mate_name1u = @pm_papa_name)
	OR
	(	kc_cust_name2u = @pm_papa_name
	AND	kc_mate_name2u = @pm_mama_name)
	OR
	(	kc_cust_name2u = @pm_mama_name
	AND	kc_mate_name2u = @pm_papa_name)

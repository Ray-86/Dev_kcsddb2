CREATE  PROCEDURE [kcsd].[p_kc_caselink_recheck_rule1]  @pm_id_no varchar(10)
AS
-- CP規則1: ID 與其他 ID 相同

INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'本人','自己' FROM	kcsd.kc_customerloan WHERE kc_id_no = @pm_id_no
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保1','自己' FROM	kcsd.kc_customerloan WHERE kc_id_no1 = @pm_id_no
INSERT #tmp_caselink_recheck_case SELECT kc_case_no,'保2','自己' FROM	kcsd.kc_customerloan WHERE kc_id_no2 = @pm_id_no
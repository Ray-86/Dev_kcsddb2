-- =============================================
-- 20150429 CP檢查歷史ID
-- 09/05/09 Bugfix: fix未查DY2黑名單, 只查DY1
-- 11/01/08 Add unicode name support (unicode dummy)
-- KC: CP with 黑名單, 其他車行, 其他車業車行
-- =============================================
CREATE                   procedure [kcsd].[p_kc_cpcheck_rule5]
@pm_query_no varchar(10), @pm_id_no varchar(10)
AS
--規則5: ID 與黑名單 ID 相同

DECLARE @wk_id_no varchar(10)

DECLARE c1 CURSOR FOR

SELECT distinct s.kc_id_no 
FROM kcsd.kc_customers s
WHERE 
EXISTS (
	SELECT DISTINCT  x.kc_id_no
	FROM kcsd.kc_customers x
	WHERE
	s.kc_id_no = x.kc_id_no AND
	EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
			x.kc_case_no = c.kc_case_no and 
			x.kc_cust_type = c.kc_cust_type and
			c.kc_id_no = @pm_id_no 
		)	
	)
UNION
SELECT @pm_id_no

OPEN c1
FETCH NEXT FROM c1 INTO @wk_id_no
WHILE @@FETCH_STATUS = 0
BEGIN

	/* '婉拒 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name, kc_cust_nameu)
	SELECT	@pm_query_no , kc_id_no, 'B', kc_cust_name, kc_cust_name		-- unicode dummy
	FROM	kcsd.kc_blacklist		-- bug fixed !!
	WHERE	kc_id_no = @pm_id_no and
	kc_decline_flag <> -1
	
	-- =============================================
	/* 拒往 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name, kc_cust_nameu)
	SELECT	@pm_query_no , kc_id_no, 'BU', kc_cust_name, kc_cust_name		-- unicode dummy
	FROM	kcsd.kc_blacklist		-- bug fixed !!
	WHERE	kc_id_no = @pm_id_no and
	kc_decline_flag = -1
	-- =============================================

	/* 黑名單--車業DY1 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name, kc_cust_nameu)	-- unicode dummy
	SELECT	@pm_query_no , kc_id_no, 'XB', kc_cust_name, kc_cust_name
	FROM	kcsddb.kcsd.kc_blacklist
	WHERE	kc_id_no = @pm_id_no
	
	-- =============================================
	/* 其他車行 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name, kc_cust_nameu)
	SELECT	@pm_query_no , kc_id_no, 'T', kc_cust_name, kc_cust_name		-- unicode dummy
	FROM	kcsd.kc_othercase
	WHERE	kc_id_no = @pm_id_no
	
	-- =============================================
	/* 其他車行--車業 DY1*/
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name, kc_cust_nameu)
	SELECT	@pm_query_no , kc_id_no, 'XT', kc_cust_name, kc_cust_name		-- unicode dummy
	FROM	kcsddb.kcsd.kc_othercase
	WHERE	kc_id_no = @pm_id_no

FETCH NEXT FROM c1  INTO @wk_id_no
end
CLOSE c1
DEALLOCATE c1

-- =============================================
-- 20150429 CP檢查歷史ID
-- 11/15/2010 KC: Remove non-Unicode Search because of no index and redundundant
-- 11/02/2008 Add unicode support
-- KC: add reference
-- =============================================
CREATE                 procedure [kcsd].[p_kc_cpcheck_rule3]
@pm_query_no varchar(10), @pm_id_no varchar(10), @pm_cust_name  nvarchar(60),@pm_mate_name nvarchar(60)
AS
	
--規則3: Mate 與其他 Name 相同, 且 Mate 為該件 Name

DECLARE @wk_cust_nameu nvarchar(60)

DECLARE c1 CURSOR FOR

SELECT distinct s.kc_cust_nameu 
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
SELECT @pm_cust_name

OPEN c1
FETCH NEXT FROM c1 INTO @wk_cust_nameu
WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type,
		kc_id_no,kc_cust_nameu,  kc_papa_nameu,  kc_mama_nameu,  kc_mate_nameu,
		kc_id_no1,kc_cust_name1u, kc_papa_name1u, kc_mama_name1u, kc_mate_name1u,
		kc_id_no2,kc_cust_name2u, kc_papa_name2u, kc_mama_name2u, kc_mate_name2u
		)
	SELECT	@pm_query_no , kc_case_no, 'C',
		kc_id_no,kc_cust_nameu,  kc_papa_nameu,  kc_mama_nameu,  kc_mate_nameu,
		kc_id_no1,kc_cust_name1u, kc_papa_name1u, kc_mama_name1u, kc_mate_name1u,
		kc_id_no2,kc_cust_name2u, kc_papa_name2u, kc_mama_name2u, kc_mate_name2u
	
	FROM	kcsd.kc_customerloan
	WHERE(kc_cust_nameu = @pm_mate_name
		AND	kc_mate_nameu = @wk_cust_nameu)
		OR
		(kc_cust_name1u = @pm_mate_name
		AND	kc_mate_name1u = @wk_cust_nameu)
		OR
		(kc_cust_name2u = @pm_mate_name
		AND	kc_mate_name2u = @wk_cust_nameu)
	
	-- =============================================
	/* Reference */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type,
		kc_id_no,kc_cust_nameu,  kc_papa_nameu,  kc_mama_nameu,  kc_mate_nameu,
		kc_id_no1,kc_cust_name1u, kc_papa_name1u, kc_mama_name1u, kc_mate_name1u,
		kc_id_no2,kc_cust_name2u, kc_papa_name2u, kc_mama_name2u, kc_mate_name2u
		)
	SELECT	@pm_query_no , kc_ref_no, 'RC',
		kc_id_no,kc_cust_name,  kc_papa_name,  kc_mama_name,  kc_mate_name,
		kc_id_no1,kc_cust_name1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
		kc_id_no2,kc_cust_name2, kc_papa_name2, kc_mama_name2, kc_mate_name2
	FROM	kcsd.kc_reference
	WHERE	(kc_cust_name = @pm_mate_name
		AND	kc_mate_name = @wk_cust_nameu)
		OR
		(kc_cust_name1 = @pm_mate_name
		AND	kc_mate_name1 = @wk_cust_nameu)
		OR
		(kc_cust_name2 = @pm_mate_name
		AND	kc_mate_name2 = @wk_cust_nameu)
	
	-- =============================================
	/* 車業系統 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type,
		kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
		kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
		kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2
		)
	SELECT	@pm_query_no , kc_case_no, 'XC',
		kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
		kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
		kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2
	FROM	kcsddb.kcsd.dy1kc_customerloan
	WHERE	(kc_cust_name = @pm_mate_name
		AND	kc_mate_name = @wk_cust_nameu)
		OR
		(kc_cust_name1 = @pm_mate_name
		AND	kc_mate_name1 = @wk_cust_nameu)
		OR
		(kc_cust_name2 = @pm_mate_name
		AND	kc_mate_name2 = @wk_cust_nameu)
	-- =============================================
	/* 車業系統 -- 低零利 */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type,
		kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
		kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
		kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2
		)
	SELECT	@pm_query_no , kc_case_no, 'XC2',
		kc_cust_name, kc_id_no, kc_papa_name, kc_mama_name, kc_mate_name,
		kc_cust_name1, kc_id_no1, kc_papa_name1, kc_mama_name1, kc_mate_name1,
		kc_cust_name2, kc_id_no2, kc_papa_name2, kc_mama_name2, kc_mate_name2
	FROM	kcsddb.kcsd.kc_customerloan2
	WHERE	(kc_cust_name = @pm_mate_name
		AND	kc_mate_name = @wk_cust_nameu)
		OR
		(kc_cust_name1 = @pm_mate_name
		AND	kc_mate_name1 = @wk_cust_nameu)
		OR
		(kc_cust_name2 = @pm_mate_name
		AND	kc_mate_name2 = @wk_cust_nameu)
	
	-- =============================================
	/* CP vs CP */
	INSERT	kcsd.kc_cpresult
		(kc_cp_no, kc_case_no, kc_cust_type,
		kc_id_no,kc_cust_nameu,  kc_papa_nameu,  kc_mama_nameu,  kc_mate_nameu,
		kc_id_no1,kc_cust_name1u, kc_papa_name1u, kc_mama_name1u, kc_mate_name1u,
		kc_id_no2,kc_cust_name2u, kc_papa_name2u, kc_mama_name2u, kc_mate_name2u
		)
	SELECT	@pm_query_no , kc_cp_no, 'CP',
		kc_id_no,kc_cust_nameu,  kc_papa_nameu,  kc_mama_nameu,  kc_mate_nameu,
		kc_id_no1,kc_cust_name1u, kc_papa_name1u, kc_mama_name1u, kc_mate_name1u,
		kc_id_no2,kc_cust_name2u, kc_papa_name2u, kc_mama_name2u, kc_mate_name2u
	FROM	kcsd.kc_cpdata
	WHERE	kc_cp_no <> @pm_query_no
	AND	(	kc_cust_nameu = @pm_mate_name
		AND	kc_mate_nameu = @wk_cust_nameu)
		OR
		(	kc_cust_name1u = @pm_mate_name
		AND	kc_mate_name1u = @wk_cust_nameu)
		OR
		(	kc_cust_name2u = @pm_mate_name
		AND	kc_mate_name2u = @wk_cust_nameu)

FETCH NEXT FROM c1  INTO @wk_cust_nameu
end
CLOSE c1
DEALLOCATE c1

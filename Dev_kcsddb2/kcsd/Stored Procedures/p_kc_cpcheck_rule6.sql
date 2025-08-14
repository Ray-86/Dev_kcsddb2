-- =============================================
-- 11/15/2010 KC: Remove non-Unicode Search because of no index and redundundant
-- 11/02/2008 Add unicode support
-- KC: add reference
-- =============================================
CREATE         PROCEDURE [kcsd].[p_kc_cpcheck_rule6]
@pm_query_no varchar(10), @pm_papa_name nvarchar(60), @pm_mama_name nvarchar(60)
AS

--規則6: 父母辦過: P 與其他 Name 相同, 且另一 P為該件 C 

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

-- =============================================
-- Reference
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
WHERE	(kc_cust_name = @pm_papa_name
	AND	kc_mate_name = @pm_mama_name)
	OR
	(kc_cust_name = @pm_mama_name
	AND	kc_mate_name = @pm_papa_name)
	OR
	(kc_cust_name1 = @pm_papa_name
	AND	kc_mate_name1 = @pm_mama_name)
	OR
	(kc_cust_name1 = @pm_mama_name
	AND	kc_mate_name1 = @pm_papa_name)
	OR
	(kc_cust_name2 = @pm_papa_name
	AND	kc_mate_name2 = @pm_mama_name)
	OR
	(kc_cust_name2 = @pm_mama_name
	AND	kc_mate_name2 = @pm_papa_name)

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
WHERE	(kc_cust_name = @pm_papa_name
	AND	kc_mate_name = @pm_mama_name)
	OR
	(kc_cust_name = @pm_mama_name
	AND	kc_mate_name = @pm_papa_name)
	OR
	(kc_cust_name1 = @pm_papa_name
	AND	kc_mate_name1 = @pm_mama_name)
	OR
	(kc_cust_name1 = @pm_mama_name
	AND	kc_mate_name1 = @pm_papa_name)
	OR
	(kc_cust_name2 = @pm_papa_name
	AND	kc_mate_name2 = @pm_mama_name)
	OR
	(kc_cust_name2 = @pm_mama_name
	AND	kc_mate_name2 = @pm_papa_name)

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
WHERE	(kc_cust_name = @pm_papa_name
	AND	kc_mate_name = @pm_mama_name)
	OR
	(kc_cust_name = @pm_mama_name
	AND	kc_mate_name = @pm_papa_name)
	OR
	(kc_cust_name1 = @pm_papa_name
	AND	kc_mate_name1 = @pm_mama_name)
	OR
	(kc_cust_name1 = @pm_mama_name
	AND	kc_mate_name1 = @pm_papa_name)
	OR
	(kc_cust_name2 = @pm_papa_name
	AND	kc_mate_name2 = @pm_mama_name)
	OR
	(kc_cust_name2 = @pm_mama_name
	AND	kc_mate_name2 = @pm_papa_name)

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
AND	(	kc_cust_nameu = @pm_papa_name
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

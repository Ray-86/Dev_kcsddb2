-- =============================================
-- 
-- =============================================
CREATE                 procedure [kcsd].[p_kc_cpcheck_rule8]
@pm_query_no varchar(10), @pm_id_no varchar(10), @pm_cust_name nvarchar(60),@pm_birth_date datetime
AS

--規則8: 居留證案件 ID前兩碼為英文 檢查生日、姓名相同

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
WHERE	((kc_cust_nameu = @pm_cust_name AND kc_birth_date = @pm_birth_date)
		OR(kc_cust_name1u = @pm_cust_name AND kc_birth_date1 = @pm_birth_date)
		OR(kc_cust_name2u = @pm_cust_name AND kc_birth_date2 = @pm_birth_date))

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
WHERE	((kc_cust_name = @pm_cust_name AND kc_birth_date = @pm_birth_date)
		OR(kc_cust_name1 = @pm_cust_name AND kc_birth_date1 = @pm_birth_date)
		OR(kc_cust_name2 = @pm_cust_name AND kc_birth_date2 = @pm_birth_date))

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
WHERE	((kc_cust_name = @pm_cust_name AND kc_birth_date = @pm_birth_date)
		OR(kc_cust_name1 = @pm_cust_name AND kc_birth_date1 = @pm_birth_date)
		OR(kc_cust_name2 = @pm_cust_name AND kc_birth_date2 = @pm_birth_date))

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
	AND((kc_cust_nameu = @pm_cust_name AND kc_birth_date = @pm_birth_date)
		OR(kc_cust_name1u = @pm_cust_name AND kc_birth_date1 = @pm_birth_date)
		OR(kc_cust_name2u = @pm_cust_name AND kc_birth_date2 = @pm_birth_date))
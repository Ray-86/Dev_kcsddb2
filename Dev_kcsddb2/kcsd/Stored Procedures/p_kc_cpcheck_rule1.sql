-- =============================================
-- 20150429 CP檢查歷史ID
-- 11/01/08 Add unicode name support (save to cpresult)
-- KC: add reference
-- =============================================
CREATE                 procedure [kcsd].[p_kc_cpcheck_rule1]
@pm_query_no varchar(10), @pm_id_no varchar(10)
AS

--規則1: ID 與其他 ID 相同

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
begin
	--客戶資料
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
	WHERE	kc_id_no = @wk_id_no
	OR	kc_id_no1 = @wk_id_no
	OR	kc_id_no2 = @wk_id_no
	
	--Reference
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
	WHERE	kc_id_no = @wk_id_no
	OR	kc_id_no1 = @wk_id_no
	OR	kc_id_no2 = @wk_id_no
	
	
	--車業系統
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
	WHERE	kc_id_no = @wk_id_no
	OR	kc_id_no1 = @wk_id_no
	OR	kc_id_no2 = @wk_id_no
	
	--車業系統 -- 低零利
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
	WHERE	kc_id_no = @wk_id_no
	OR	kc_id_no1 = @wk_id_no
	OR	kc_id_no2 = @wk_id_no
	
	-- CP
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
	AND	(kc_id_no = @wk_id_no
	OR	kc_id_no1 = @wk_id_no
	OR	kc_id_no2 = @wk_id_no)

FETCH NEXT FROM c1  INTO @wk_id_no
end
CLOSE c1
DEALLOCATE c1

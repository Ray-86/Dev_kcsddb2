-- =============================================
-- 2021-10-21 新增檢查 ID2
-- 2015-05-01 刪除不是u的欄位
-- 11/08/08 刪除CP結果為自己這個CP (cp_dupclear)
-- 11/02/08 Add unicode support
-- =============================================

CREATE                procedure [kcsd].[p_kc_cpcheck]
@pm_cp_no varchar(10),
@pm_cust_name nvarchar(60),
@pm_id_no varchar(10),
@pm_birth_date datetime,
@pm_papa_name nvarchar(60),
@pm_mama_name nvarchar(60),
@pm_mate_name nvarchar(60),
@pm_id_no1 varchar(10),
@pm_birth_date1 datetime,
@pm_cust_name1 nvarchar(60),
@pm_papa_name1 nvarchar(60),
@pm_mama_name1 nvarchar(60),
@pm_mate_name1 nvarchar(60),
@pm_id_no2 varchar(10),
@pm_birth_date2 datetime,
@pm_cust_name2 nvarchar(60),
@pm_papa_name2 nvarchar(60),
@pm_mama_name2 nvarchar(60),
@pm_mate_name2 nvarchar(60),
@pm_id2_no varchar(10),
@pm_id2_no1 varchar(10),
@pm_id2_no2 varchar(10)

AS

DELETE
FROM	kcsd.kc_cpresult
WHERE	kc_cp_no = @pm_cp_no

--規則1: ID 與其他 ID 相同
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id_no
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id_no1
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id_no2
--檢查 ID2
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id2_no
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id2_no1
EXECUTE kcsd.p_kc_cpcheck_rule1 @pm_cp_no, @pm_id2_no2

--規則2: Name 與其他 P 相同, 且 Mate 為該件 P
EXECUTE kcsd.p_kc_cpcheck_rule2 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name
EXECUTE kcsd.p_kc_cpcheck_rule2 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name1
EXECUTE kcsd.p_kc_cpcheck_rule2 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name2

--規則3: Mate 與其他 Name 相同, 且 Mate 為該件 Name
EXECUTE kcsd.p_kc_cpcheck_rule3 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name
EXECUTE kcsd.p_kc_cpcheck_rule3 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name1
EXECUTE kcsd.p_kc_cpcheck_rule3 @pm_cp_no, @pm_cp_no, @pm_cust_name,@pm_mate_name2

--規則4: P 與其他 P 相同 (兄弟姊妹曾辦過 或保過)
EXECUTE kcsd.p_kc_cpcheck_rule4 @pm_cp_no, @pm_papa_name, @pm_mama_name
EXECUTE kcsd.p_kc_cpcheck_rule4 @pm_cp_no, @pm_papa_name1, @pm_mama_name1
EXECUTE kcsd.p_kc_cpcheck_rule4 @pm_cp_no, @pm_papa_name2, @pm_mama_name2

--規則5: ID 與婉拒名單 ID 相同
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id_no
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id_no1
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id_no2
--檢查 ID2
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id2_no
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id2_no1
EXECUTE kcsd.p_kc_cpcheck_rule5 @pm_cp_no, @pm_id2_no2

--規則6: 父母辦過: P 與其他 Name 相同, 且另一 P為該件 C
EXECUTE kcsd.p_kc_cpcheck_rule6 @pm_cp_no, @pm_papa_name, @pm_mama_name
EXECUTE kcsd.p_kc_cpcheck_rule6 @pm_cp_no, @pm_papa_name1, @pm_mama_name1
EXECUTE kcsd.p_kc_cpcheck_rule6 @pm_cp_no, @pm_papa_name2, @pm_mama_name2

--規則8: 居留證案件 ID前兩碼為英文 檢查生日、姓名相同
IF @pm_id_no LIKE '[A-Z][A-Z]%' EXECUTE kcsd.p_kc_cpcheck_rule8 @pm_cp_no, @pm_id_no, @pm_cust_name, @pm_birth_date
IF @pm_id_no1 LIKE '[A-Z][A-Z]%' EXECUTE kcsd.p_kc_cpcheck_rule8 @pm_cp_no, @pm_id_no1, @pm_cust_name1, @pm_birth_date1
IF @pm_id_no2 LIKE '[A-Z][A-Z]%' EXECUTE kcsd.p_kc_cpcheck_rule8 @pm_cp_no, @pm_id_no2, @pm_cust_name2, @pm_birth_date2

EXECUTE kcsd.p_kc_cpdupclear @pm_cp_no

EXECUTE kcsd.p_kc_cpcheck_rule7 @pm_cp_no

/*
INSERT	kcsd.kc_cpresult
	(kc_cp_no, kc_case_no, kc_cust_type, kc_cust_name)
SELECT	@pm_cp_no , kc_id_no, 'B', kc_cust_name
FROM	kcsd.kc_blacklist
WHERE	kc_id_no = @pm_id_no
OR	kc_id_no = @pm_id_no1
OR	kc_id_no = @pm_id_no2*/

-- =============================================
-- 11/22/08 use CP method to build DY2 case vs case
-- =============================================
CREATE  PROCEDURE [kcsd].[p_kc_caselink_recheck] @pm_case_no varchar(10)=NULL
AS

DECLARE
@wk_cp_no varchar(10),
@wk_cust_name nvarchar(60),
@wk_id_no varchar(10),
@wk_papa_name nvarchar(60),
@wk_mama_name nvarchar(60),
@wk_mate_name nvarchar(60),

@wk_cust_name1 nvarchar(60),
@wk_id_no1 varchar(10),
@wk_papa_name1 nvarchar(60),
@wk_mama_name1 nvarchar(60),
@wk_mate_name1 nvarchar(60),

@wk_cust_name2 nvarchar(60),
@wk_id_no2 varchar(10),
@wk_papa_name2 nvarchar(60),
@wk_mama_name2 nvarchar(60),
@wk_mate_name2 nvarchar(60),

@wk_case_no	varchar(10)

IF	@pm_case_no IS NULL
	RETURN

SELECT	@wk_cust_name = kc_cust_nameu,@wk_id_no = kc_id_no,@wk_papa_name = kc_papa_nameu,@wk_mama_name = kc_mama_nameu,@wk_mate_name = kc_mate_nameu,
		@wk_cust_name1 = kc_cust_name1u,@wk_id_no1 = kc_id_no1,@wk_papa_name1 = kc_papa_name1u,@wk_mama_name1 = kc_mama_name1u,@wk_mate_name1 = kc_mate_name1u,
		@wk_cust_name2 = kc_cust_name2u,@wk_id_no2 = kc_id_no2,@wk_papa_name2 = kc_papa_name2u,@wk_mama_name2 = kc_mama_name2u,@wk_mate_name2 = kc_mate_name2u
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

DELETE FROM	#tmp_caselink_recheck_case


-- Rule 1: 自己辦過: ID 與其他 ID 相同
EXECUTE kcsd.p_kc_caselink_recheck_rule1 @wk_id_no
EXECUTE kcsd.p_kc_caselink_recheck_rule1 @wk_id_no1
EXECUTE kcsd.p_kc_caselink_recheck_rule1 @wk_id_no2

-- Rule 2: 子女辦過: Name 與其他 P 相同, 且 Mate 為該件 P
EXECUTE kcsd.p_kc_caselink_recheck_rule2 @wk_cust_name,  @wk_mate_name
EXECUTE kcsd.p_kc_caselink_recheck_rule2 @wk_cust_name1, @wk_mate_name1
EXECUTE kcsd.p_kc_caselink_recheck_rule2 @wk_cust_name2, @wk_mate_name2

-- Rule 3: 配偶辦過: Mate 與其他 Name 相同, 且 Mate 為該件 Name
EXECUTE kcsd.p_kc_caselink_recheck_rule3 @wk_cust_name,  @wk_mate_name
EXECUTE kcsd.p_kc_caselink_recheck_rule3 @wk_cust_name1, @wk_mate_name1
EXECUTE kcsd.p_kc_caselink_recheck_rule3 @wk_cust_name2, @wk_mate_name2

-- Rule 4: 兄弟辦過: P 與其他 P 相同 (兄弟姊妹曾辦過 或保過)
EXECUTE kcsd.p_kc_caselink_recheck_rule4 @wk_papa_name,  @wk_mama_name, @wk_id_no
EXECUTE kcsd.p_kc_caselink_recheck_rule4 @wk_papa_name1, @wk_mama_name1,@wk_id_no1
EXECUTE kcsd.p_kc_caselink_recheck_rule4 @wk_papa_name2, @wk_mama_name2,@wk_id_no2

-- Rule 5: 父母辦過: P 與其他 Name 相同, 且另一 P為該件 C
EXECUTE kcsd.p_kc_caselink_recheck_rule5 @wk_papa_name,  @wk_mama_name
EXECUTE kcsd.p_kc_caselink_recheck_rule5 @wk_papa_name1, @wk_mama_name1
EXECUTE kcsd.p_kc_caselink_recheck_rule5 @wk_papa_name2, @wk_mama_name2

-- EXECUTE kcsd.p_kc_cpdupclear @pm_cp_no

DELETE #tmp_caselink_recheck_case where kc_case_no = @pm_case_no
/*
SELECT	DISTINCT kc_case_no
FROM	#tmp_caselink_recheck_case


SELECT	DISTINCT A.*,c.kc_area_code +' '+ d.kc_area_desc as kc_area_desc,c.kc_cust_nameu,c.kc_cust_name1u,c.kc_cust_name2u,c.kc_pusher_code,c.kc_push_sort,c.kc_over_count,c.kc_dday_count,c.kc_over_amt,c.kc_loan_stat+' '+ s.Text as kc_loan_desc,c.kc_push_memo3
FROM	#tmp_caselink_recheck_case A left join kcsd.kc_customerloan c on A.kc_case_no = c.kc_case_no
									 left join kcsd.kct_area d on d.kc_area_code = c.kc_area_code
									 left join (select * from [Zephyr.Sys].dbo.sys_code where CodeType ='LoanCode') s on c.kc_loan_stat = s.Value
									 
DELETE FROM	#tmp_caselink_recheck_case
*/

-- =============================================
-- 2021-10-21 新增ID2計算
-- 2017-04-26 CP計算改為SP
-- =============================================

CREATE	procedure [kcsd].[p_kc_cpcalculate]
@pm_cp_no varchar(10)

AS

DECLARE
	@wk_cust_name nvarchar(60),
	@wk_id_no varchar(10),
	@wk_birth_date datetime,
	@wk_papa_name nvarchar(60),
	@wk_mama_name nvarchar(60),
	@wk_mate_name nvarchar(60),
	@wk_cust_name1 nvarchar(60),
	@wk_id_no1 varchar(10),
	@wk_birth_date1 datetime,
	@wk_papa_name1 nvarchar(60),
	@wk_mama_name1 nvarchar(60),
	@wk_mate_name1 nvarchar(60),
	@wk_cust_name2 nvarchar(60),
	@wk_id_no2 varchar(10),
	@wk_birth_date2 datetime,
	@wk_papa_name2 nvarchar(60),
	@wk_mama_name2 nvarchar(60),
	@wk_mate_name2 nvarchar(60),
	@wk_case_no	varchar(10),
	@wk_id2_no varchar(10),
	@wk_id2_no1 varchar(10),
	@wk_id2_no2 varchar(10)

SELECT 
	@wk_cust_name = kc_cust_nameu,
	@wk_id_no = kc_id_no,
	@wk_birth_date = kc_birth_date,
	@wk_papa_name = kc_papa_nameu,
	@wk_mama_name = kc_mama_nameu,
	@wk_mate_name = kc_mate_nameu,

	@wk_cust_name1 = kc_cust_name1u,
	@wk_id_no1 = kc_id_no1,
	@wk_birth_date1 = kc_birth_date1,
	@wk_papa_name1 = kc_papa_name1u,
	@wk_mama_name1 = kc_mama_name1u,
	@wk_mate_name1 = kc_mate_name1u,

	@wk_cust_name2 = kc_cust_name2u,
	@wk_id_no2 = kc_id_no2,
	@wk_birth_date2 = kc_birth_date2,
	@wk_papa_name2 = kc_papa_name2u,
	@wk_mama_name2 = kc_mama_name2u,
	@wk_mate_name2 = kc_mate_name2u,

	@wk_id2_no = kc_id2_no,
	@wk_id2_no1 = kc_id2_no1,
	@wk_id2_no2 = kc_id2_no2

FROM kcsd.kc_cpdata 
WHERE kc_cp_no = @pm_cp_no

--傳入''欄位轉為NULL 避免 '' = '' 連結
IF @wk_cust_name = '' SELECT @wk_cust_name = null
IF @wk_id_no = '' SELECT @wk_id_no = null
IF @wk_birth_date = '' SELECT @wk_birth_date = null
IF @wk_papa_name = '' SELECT @wk_papa_name = null
IF @wk_mama_name = '' SELECT @wk_mama_name = null
IF @wk_mate_name = '' SELECT @wk_mate_name = null
IF @wk_id_no1 = '' SELECT @wk_id_no1 = null
IF @wk_birth_date1 = '' SELECT @wk_birth_date1 = null
IF @wk_cust_name1 = '' SELECT @wk_cust_name1 = null
IF @wk_papa_name1 = '' SELECT @wk_papa_name1 = null
IF @wk_mama_name1 = '' SELECT @wk_mama_name1 = null
IF @wk_mate_name1 = '' SELECT @wk_mate_name1 = null
IF @wk_id_no2 = '' SELECT @wk_id_no2 = null
IF @wk_birth_date2 = '' SELECT @wk_birth_date2 = null
IF @wk_cust_name2 = '' SELECT @wk_cust_name2 = null
IF @wk_papa_name2 = '' SELECT @wk_papa_name2 = null
IF @wk_mama_name2 = '' SELECT @wk_mama_name2 = null
IF @wk_mate_name2 = '' SELECT @wk_mate_name2 = null
IF @wk_id2_no = '' SELECT @wk_id2_no = null
IF @wk_id2_no1 = '' SELECT @wk_id2_no1 = null
IF @wk_id2_no2 = '' SELECT @wk_id2_no2 = null

/* 先清除CP紀錄 */ 
DELETE FROM	kcsd.kc_cpresult
WHERE kc_cp_no = @pm_cp_no

/* 計算CP */
EXECUTE	kcsd.p_kc_cpcheck @pm_cp_no,@wk_cust_name,@wk_id_no,@wk_birth_date,@wk_papa_name,@wk_mama_name,@wk_mate_name,
	@wk_id_no1,@wk_birth_date1,@wk_cust_name1,@wk_papa_name1,@wk_mama_name1,@wk_mate_name1,
	@wk_id_no2,@wk_birth_date2,@wk_cust_name2,@wk_papa_name2,@wk_mama_name2,@wk_mate_name2,
	@wk_id2_no, @wk_id2_no1, @wk_id2_no2

/* 計算客戶資料連結件 */
--SELECT	@wk_case_no = kc_case_no
--FROM	kcsd.kc_customerloan
--WHERE	kc_cp_no = @pm_cp_no
--
--IF @wk_case_no IS NOT NULL
--BEGIN
--IF NOT EXISTS	
--	(SELECT	kc_case_no FROM kcsd.kc_caselink_queue WHERE kc_case_no = @wk_case_no AND kc_cp_no = @pm_cp_no)
--	INSERT	kcsd.kc_caselink_queue (kc_case_no, kc_cp_no)	
--	VALUES	(@wk_case_no, @pm_cp_no)
--END



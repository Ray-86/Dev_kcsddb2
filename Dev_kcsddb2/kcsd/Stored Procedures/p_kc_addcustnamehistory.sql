-- =============================================
-- 2015-04-28 新增ID歷史紀錄至kc_customers TABLE中
-- =============================================

CREATE  PROCEDURE [kcsd].[p_kc_addcustnamehistory] 
	@pm_case_no		nvarchar(10),
	@pm_cust_type		smallint,
	@pm_cust_id		varchar(10),
	@pm_cust_nameu	nvarchar(50)

AS
	
DECLARE	
	@pm_cust_cnt		smallint

SELECT @pm_cust_cnt = isnull(max(kc_cust_cnt),-1) + 1
FROM kcsd.kc_customers
WHERE	kc_case_no = @pm_case_no and
		kc_cust_type = @pm_cust_type

INSERT INTO kcsd.kc_customers 
	(kc_case_no,kc_cust_type,kc_cust_cnt,kc_id_no,kc_cust_nameu,kc_updt_user,kc_updt_date)
VALUES
	(@pm_case_no, @pm_cust_type, @pm_cust_cnt, @pm_cust_id, @pm_cust_nameu, USER,GETDATE())

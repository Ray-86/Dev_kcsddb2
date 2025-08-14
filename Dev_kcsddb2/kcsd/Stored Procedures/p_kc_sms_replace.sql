-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_sms_replace] 	@pm_sms_msg VARCHAR(300) = NULL OUTPUT , @pm_cp_no VARCHAR(20) = NULL  

AS
BEGIN

DECLARE	
	@wk_case_no		VARCHAR(10),
	@wk_cust_name	VARCHAR(10),
	@wk_cust_name1	VARCHAR(10),
	@wk_cust_name2		VARCHAR(10),
	@wk_licn_no		VARCHAR(10),
	@wk_pusher_code	VARCHAR(10),
	@wk_issu_code	VARCHAR(10),
	@wk_area_code		VARCHAR(10),
	@wk_cp_no		VARCHAR(10),
	@wk_give_amt	VARCHAR(10),
	@wk_strt_date	VARCHAR(10),
	@wk_brand_code	VARCHAR(10),
	@wk_linecust_url	VARCHAR(100)



	select 
	@wk_case_no = isnull(kc_case_no,''),
	@wk_cust_name = isnull(kc_cust_nameu,''),
	@wk_cust_name1 = isnull('，' + kc_cust_name1u,''),
	@wk_cust_name2 = isnull('，' + kc_cust_name2u,''),
	@wk_licn_no = isnull(kc_licn_no,''),
	@wk_pusher_code = isnull(kc_pusher_code,''),
	@wk_issu_code = isnull(kc_issu_code,''),
	@wk_area_code = isnull(kc_area_code,''),
	@wk_cp_no = isnull(kc_cp_no,''),
	@wk_give_amt = isnull(CONVERT(varchar, kc_give_amt),'')	,
	@wk_strt_date = isnull(SUBSTRING(CONVERT(varchar(20), kc_strt_date, 23),9,2),'')	,
	@wk_brand_code = isnull(kc_brand_code,''),
	@wk_linecust_url = case when kc_brand_code = '01' then 'https://line.me/R/ti/p/%40dy22268886' when kc_brand_code = '02' then 'https://line.me/R/ti/p/%40bobopay' else '' end
	

	from [kcsd].[kc_customerloan] where kc_cp_no = @pm_cp_no


	DECLARE	
	@wk_issu_desc		VARCHAR(10),
	@wk_atm_no	VARCHAR(10),
	@wk_acct_no	VARCHAR(10)

	select 
	@wk_issu_desc = isnull(kc_issu_desc,''),
	@wk_atm_no = isnull(kc_atm_no,''),
	@wk_acct_no = isnull(kc_acct_no,'')
	from [kcsd].kct_issuecompany where kc_issu_code = @wk_issu_code


	DECLARE	
	@wk_area_addr		VARCHAR(10),
	@wk_area_phone	VARCHAR(10)

	select 
	@wk_area_addr = isnull(kc_area_addr,''),
	@wk_area_phone = isnull(kc_area_phone,'')
	from [kcsd].kct_area where kc_area_code = @wk_area_code



SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【客編】', @wk_case_no)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【本人姓名】', @wk_cust_name)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【保人1姓名】', @wk_cust_name1)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【保人2姓名】', @wk_cust_name2)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【車牌】', @wk_licn_no)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【公司別】', @wk_issu_desc)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【銀行帳號】', @wk_atm_no)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【郵局帳號】', @wk_acct_no)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【分公司地址】', @wk_area_addr)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【分公司電話】', @wk_area_phone)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【撥款金額】', @wk_give_amt)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【CP編號】', @wk_cp_no)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【起始日期之欄位末兩碼號碼】', @wk_strt_date)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【品牌】', @wk_brand_code)
SELECT @pm_sms_msg = REPLACE (@pm_sms_msg, '【LINE客戶端網址】', @wk_linecust_url)

END

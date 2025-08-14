

CREATE	PROCEDURE [kcsd].[p_kc_year_tax]
	@pm_case_no varchar(10)=NULL, @pm_tick_type varchar(4), @pm_tick_kind varchar(6), @pm_tick_amt int, @pm_input_date smalldatetime, @pm_rept_date smalldatetime
AS


DECLARE	
@wk_area_code	varchar(2),
@wk_item_no		int

SELECT @wk_area_code = kc_area_code FROM kcsd.kc_customerloan WHERE kc_case_no = @pm_case_no;
SELECT @wk_item_no = ISNULL(MAX(kc_item_no),0)+1 FROM kcsd.kc_trafficticket WHERE kc_case_no = @pm_case_no;

INSERT INTO [kcsd].[kc_trafficticket]
           ([kc_case_no] ,[kc_item_no] ,[kc_input_date] ,[kc_tick_type] ,[kc_tick_item] ,[kc_tick_date]
           ,[kc_tick_amt] ,[kc_rept_date] ,[kc_updt_user] ,[kc_updt_date] ,[kc_tick_no] ,[kc_pay_date] 
		   ,[kc_proc_fee] ,[kc_pay_type] ,[kc_tick_kind] ,[kc_area_code])
     VALUES
           (@pm_case_no ,@wk_item_no, @pm_input_date, @pm_tick_type, '沒在使用', @pm_input_date, 
		   @pm_tick_amt, @pm_rept_date, USER, GETDATE(), '', @pm_input_date, 
		   0, '02', @pm_tick_kind, @wk_area_code)

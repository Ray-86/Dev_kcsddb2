CREATE	PROCEDURE [kcsd].[p_kc_year_letter]
	@pm_case_no varchar(10)=NULL, @pm_perm_flag varchar(1)=NULL, @pm_curr_flag varchar(1)=NULL, 
	@pm_perm_flag1 varchar(1)=NULL, @pm_curr_flag1 varchar(1)=NULL, @pm_perm_flag2 varchar(1)=NULL, @pm_curr_flag2 varchar(1)=NULL
AS


DECLARE	
@wk_area_code	varchar(2),
@wk_item_no		int

SELECT @wk_area_code = kc_area_code FROM kcsd.kc_customerloan WHERE kc_case_no = @pm_case_no;
SELECT @wk_item_no = ISNULL(MAX(kc_item_no),0)+1 FROM kcsd.kc_lawstatus WHERE kc_case_no = @pm_case_no;

INSERT INTO [kcsddb2].[kcsd].[kc_lawstatus]
([kc_case_no],[kc_law_date],[kc_law_code],[kc_updt_user],[kc_updt_date],[kc_item_no],[kc_area_code]
,[kc_perm_flag],[kc_curr_flag],[kc_perm_flag1],[kc_curr_flag1],[kc_perm_flag2],[kc_curr_flag2])
VALUES
(@pm_case_no,CONVERT(varchar(10),GETDATE(),111),'4',USER,GETDATE(),@wk_item_no,@wk_area_code
,@pm_perm_flag,@pm_curr_flag,@pm_perm_flag1,@pm_curr_flag1,@pm_perm_flag2,@pm_curr_flag2)

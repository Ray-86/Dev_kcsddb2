-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_searchbmn] @wk_mobile_no varchar(20),@pm_strt_date datetime , @pm_stop_date datetime
AS
BEGIN




select convert(varchar, getdate(), 112) as CreateDate,* from
(
--------C包含黑名單
--------B轉直
select  kc_cp_no,kc_cp_date,kc_case_no,kc_area_code,kc_cust_nameu,kc_emp_code, kc_mobile_type , kc_mobile_no
from 
(
--------A目標
select cp.kc_cp_no,kc_cp_date,c.kc_case_no,cp.kc_area_code,cp.kc_cust_nameu,kc_emp_code,CONVERT(varchar(12), c.kc_mobil_no) as 'Cu01',CONVERT(varchar(12), c.kc_fax_phone) as 'Cu02',CONVERT(varchar(12), c.kc_perm_phone) as 'Cu03',CONVERT(varchar(12), c.kc_curr_phone) as 'Cu04',
CONVERT(varchar(12), c.kc_comp_phone) as 'Cu05',CONVERT(varchar(12), c.kc_mobil_no1) as 'Cu06',CONVERT(varchar(12), c.kc_mobil_no12) as 'Cu07',CONVERT(varchar(12), c.kc_perm_phone1) as 'Cu08',
CONVERT(varchar(12), c.kc_curr_phone1) as 'Cu09',CONVERT(varchar(12), c.kc_comp_phone1) as 'Cu10',CONVERT(varchar(12), c.kc_mobil_no2) as 'Cu11',CONVERT(varchar(12), kc_perm_phone2) as 'Cu12',
CONVERT(varchar(12), kc_curr_phone2) as 'Cu13',CONVERT(varchar(12), kc_comp_phone2) as 'Cu14',CONVERT(varchar(12), c1.kc_mobil_no5) as 'Cu15',CONVERT(varchar(12), kc_perm_phone5) as 'Cu16',
CONVERT(varchar(12), kc_curr_phone5) as 'Cu17',CONVERT(varchar(12), kc_comp_phone5) as 'Cu18',CONVERT(varchar(12), c.kc_mobil_no3) as 'Cu19',CONVERT(varchar(12), kc_curr_phone3) as 'Cu20',
CONVERT(varchar(12), kc_comp_phone3) as 'Cu21',CONVERT(varchar(12), c.kc_mobil_no4) as 'Cu22',CONVERT(varchar(12), kc_curr_phone4) as 'Cu23',CONVERT(varchar(12), kc_comp_phone4) as 'Cu24',
CONVERT(varchar(12), cp.kc_mobil_no) as 'Cp01',CONVERT(varchar(12), cp.kc_perm_phone) as 'Cp02',CONVERT(varchar(12), cp.kc_curr_phone) as 'Cp03',CONVERT(varchar(12), cp.kc_comp_phone) as 'Cp04',
CONVERT(varchar(12), cp.kc_mobil_no1) as 'Cp05',CONVERT(varchar(12), cp.kc_perm_phone1) as 'Cp06',CONVERT(varchar(12), cp.kc_curr_phone1) as 'Cp07',CONVERT(varchar(12), cp.kc_comp_phone1) as 'Cp08',
CONVERT(varchar(12), cp.kc_mobil_no3) as 'Cp09',CONVERT(varchar(12), cp.kc_mobil_no4) as 'Cp10'
from [kcsd].[kc_cpdata] cp 
left join [kcsd].[kc_customerloan] c on cp.kc_cp_no = c.kc_cp_no
left join [kcsd].[kc_customerloan1] c1 on c.kc_case_no = c1.kc_case_no
where cp.kc_area_code is not null  and
((kc_cp_date between @pm_strt_date and @pm_stop_date)  or  kc_loan_stat <> 'C')
and (c.kc_mobil_no is not null or c.kc_fax_phone is not null or c.kc_perm_phone is not null or c.kc_curr_phone is not null or c.kc_comp_phone is not null or c.kc_mobil_no1 is not null or c.kc_mobil_no12 is not null or 
c.kc_perm_phone1 is not null or c.kc_curr_phone1 is not null or c.kc_comp_phone1 is not null or c.kc_mobil_no2 is not null or kc_perm_phone2 is not null or kc_curr_phone2 is not null or kc_comp_phone2 is not null or 
c1.kc_mobil_no5 is not null or kc_perm_phone5 is not null or kc_curr_phone5 is not null or kc_comp_phone5 is not null or c.kc_mobil_no3 is not null or kc_curr_phone3 is not null or kc_comp_phone3 is not null or 
c.kc_mobil_no4 is not null or kc_curr_phone4 is not null or kc_comp_phone4 is not null or cp.kc_mobil_no is not null or cp.kc_perm_phone is not null or cp.kc_curr_phone is not null or cp.kc_comp_phone is not null or 
cp.kc_mobil_no1 is not null or cp.kc_perm_phone1 is not null or cp.kc_curr_phone1 is not null or cp.kc_comp_phone1 is not null or cp.kc_mobil_no3 is not null or cp.kc_mobil_no4 is not null )
--------A目標
) as xx
UNPIVOT
(kc_mobile_no FOR kc_mobile_type IN ( Cu01,Cu02,Cu03,Cu04,Cu05,Cu06,Cu07,Cu08,Cu09,Cu10,Cu11,Cu12,Cu13,Cu14,Cu15,Cu16,Cu17,Cu18,Cu19,Cu20,Cu21,Cu22,Cu23,Cu24,
Cp01,Cp02,Cp03,Cp04,Cp05,Cp06,Cp07,Cp08,Cp09,Cp10)) PV
--------B轉直
UNION
select '' as kc_cp_no,'' as kc_cp_date,'' as kc_case_no,'' as kc_area_code,'' as kc_cust_nameu,'' as kc_emp_code,'Black' as kc_mobile_type,kc_mobile_no from [kcsd].[kc_mobileblacklist]
--------C包含黑名單
) as target
where kc_mobile_no = @wk_mobile_no



END

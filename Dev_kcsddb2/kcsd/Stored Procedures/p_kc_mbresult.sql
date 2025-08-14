-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_mbresult] @wk_cp_no varchar(10)
AS
BEGIN

--select @wk_cp_no = '2101310062'

DELETE FROM kcsd.kc_mbresult2  WHERE kc_cpr_no = @wk_cp_no

INSERT kcsd.kc_mbresult2
select @wk_cp_no,cp.kc_cp_no,T.kc_mobile_type,cp.kc_area_code,
case when SUBSTRING(kc_mobile_type,1,2) = 'Cp' then cp.kc_cp_no else c.kc_case_no end as kc_cp_typeno,
case when  T.kc_mobile_type in ('Cu01','Cu02','Cu03','Cu04','Cu05')  then isNULL(c.kc_cust_nameu,'')
when  T.kc_mobile_type in ('Cu06','Cu07','Cu08','Cu09','Cu10')  then isNULL(c.kc_cust_name1u,'')
when  T.kc_mobile_type in ('Cu11','Cu12','Cu13','Cu14')  then isNULL(c.kc_cust_name2u,'')
when  T.kc_mobile_type in ('Cu15','Cu16','Cu17','Cu18')  then isNULL(c1.kc_cust_name5u,'')
when  T.kc_mobile_type in ('Cu19','Cu20','Cu21')  then isNULL(c.kc_cust_name3u,'')
when  T.kc_mobile_type in ('Cu22','Cu23','Cu24')  then isNULL(c.kc_cust_name4u,'')
when  T.kc_mobile_type in ('Cp01','Cp02','Cp03','Cp04')  then isNULL(cp.kc_cust_nameu,'')
when  T.kc_mobile_type in ('Cp05','Cp06','Cp07','Cp08')  then isNULL(cp.kc_cust_name1u,'')
when  T.kc_mobile_type = 'Cp09'  then isNULL(cp.kc_cust_name3u,'')
when  T.kc_mobile_type = 'Cp10'  then isNULL(cp.kc_cust_name4u,'')
when  T.kc_mobile_type = 'Cp12'  then ''
end as 'kc_mobile_name',T.kc_mobile_no
from kcsd.kc_chkmblist T
left join kcsd.kc_cpdata cp on T.kc_cp_no = cp.kc_cp_no
left join [kcsd].[kc_customerloan] c on T.kc_cp_no = c.kc_cp_no
left join [kcsd].[kc_customerloan1] c1 on c.kc_case_no = c1.kc_case_no
where kc_mobile_no in(

--------B1轉直
select  mykc_mobile_no
from 
(
--------A1此CP的名單
select cp.kc_cp_no,CONVERT(varchar(12), c.kc_mobil_no) as 'Cu01',CONVERT(varchar(12), c.kc_fax_phone) as 'Cu02',CONVERT(varchar(12), c.kc_perm_phone) as 'Cu03',CONVERT(varchar(12), c.kc_curr_phone) as 'Cu04',
CONVERT(varchar(12), c.kc_comp_phone) as 'Cu05',CONVERT(varchar(12), c.kc_mobil_no1) as 'Cu06',CONVERT(varchar(12), c.kc_mobil_no12) as 'Cu07',CONVERT(varchar(12), c.kc_perm_phone1) as 'Cu08',
CONVERT(varchar(12), c.kc_curr_phone1) as 'Cu09',CONVERT(varchar(12), c.kc_comp_phone1) as 'Cu10',CONVERT(varchar(12), c.kc_mobil_no2) as 'Cu11',CONVERT(varchar(12), kc_perm_phone2) as 'Cu12',
CONVERT(varchar(12), kc_curr_phone2) as 'Cu13',CONVERT(varchar(12), kc_comp_phone2) as 'Cu14',CONVERT(varchar(12), c1.kc_mobil_no5) as 'Cu15',CONVERT(varchar(12), kc_perm_phone5) as 'Cu16',
CONVERT(varchar(12), kc_curr_phone5) as 'Cu17',CONVERT(varchar(12), kc_comp_phone5) as 'Cu18',CONVERT(varchar(12), c.kc_mobil_no3) as 'Cu19',CONVERT(varchar(12), kc_curr_phone3) as 'Cu20',
CONVERT(varchar(12), kc_comp_phone3) as 'Cu21',CONVERT(varchar(12), c.kc_mobil_no4) as 'Cu22',CONVERT(varchar(12), kc_curr_phone4) as 'Cu23',CONVERT(varchar(12), kc_comp_phone4) as 'Cu24',
CONVERT(varchar(12), cp.kc_mobil_no) as 'Cp01',CONVERT(varchar(12), cp.kc_perm_phone) as 'Cp02',CONVERT(varchar(12), cp.kc_curr_phone) as 'Cp03',CONVERT(varchar(12), cp.kc_comp_phone) as 'Cp04',
CONVERT(varchar(12), cp.kc_mobil_no1) as 'Cp05',CONVERT(varchar(12), cp.kc_perm_phone1) as 'Cp06',CONVERT(varchar(12), cp.kc_curr_phone1) as 'Cp07',CONVERT(varchar(12), cp.kc_comp_phone1) as 'Cp08',
CONVERT(varchar(12), cp.kc_mobil_no3) as 'Cp09',CONVERT(varchar(12), cp.kc_mobil_no4) as 'Cp10',CONVERT(varchar(12), cp.kc_agency_phone) as 'Cp12'
from [kcsd].[kc_cpdata] cp 
left join [kcsd].[kc_customerloan] c on cp.kc_cp_no = c.kc_cp_no
left join [kcsd].[kc_customerloan1] c1 on c.kc_case_no = c1.kc_case_no
where  (cp.kc_cp_no = @wk_cp_no ) 
--------A1此CP的名單
) as xx
UNPIVOT
(mykc_mobile_no FOR kc_mobile_type IN ( Cu01,Cu02,Cu03,Cu04,Cu05,Cu06,Cu07,Cu08,Cu09,Cu10,Cu11,Cu12,Cu13,Cu14,Cu15,Cu16,Cu17,Cu18,Cu19,Cu20,Cu21,Cu22,Cu23,Cu24,
Cp01,Cp02,Cp03,Cp04,Cp05,Cp06,Cp07,Cp08,Cp09,Cp10,Cp12)) PV
--------B1轉直
) and isnull(cp.kc_cp_no,'') <> @wk_cp_no

END


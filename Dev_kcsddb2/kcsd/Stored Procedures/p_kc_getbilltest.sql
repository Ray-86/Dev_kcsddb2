
CREATE  PROCEDURE [kcsd].[p_kc_getbilltest] @pm_member_no varchar(20), @pm_expt_date datetime , @pm_data_type varchar(2)
AS

DECLARE @wk_getbill_date  datetime
DECLARE @wk_min_kc_expt_date  datetime

DECLARE @wk_date_01  datetime
DECLARE @wk_date_10 datetime
DECLARE @date_type varchar(20)
DECLARE @wk_break_fee int
DECLARE @wk_over_months int


select @wk_getbill_date = @pm_expt_date
select @wk_over_months = 0,@wk_break_fee = 0

--每個月的第一天
SELECT  @wk_date_01 = DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-1,@wk_getbill_date))+1, 0)
--每個月的第十天
SELECT  @wk_date_10 = DATEADD(D,9, DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-1,@wk_getbill_date))+1, 0)) 

--select @date_type = case when DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-1,@wk_getbill_date))+1, 0) <= @wk_getbill_date and @wk_getbill_date <= DATEADD(D,9, DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-1,@wk_getbill_date))+1, 0)) then '正常時間取件' else '逾期取件' end

--IF(@date_type = '正常時間取件') 
--  BEGIN 
--  select @wk_getbill_date = @wk_date_10
--  END


select @wk_min_kc_expt_date = ISNULL(min_kc_expt_date,GETDATE()) from (
select m.kc_member_no,MIN(kc_expt_date) min_kc_expt_date from kcsd.kc_loanpayment l
left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
left join kcsd.kc_memberdata m on c.kc_member_no = m.kc_member_no
where (kc_pay_date is null or (kc_expt_date <= @wk_getbill_date and kc_pay_date > @wk_getbill_date)   ) and m.kc_member_no = @pm_member_no GROUP BY m.kc_member_no
) as xx

if(@wk_min_kc_expt_date is not null)
BEGIN
WHILE (@wk_over_months < 999)
BEGIN
if(@wk_getbill_date <= DATEADD(M,@wk_over_months,@wk_min_kc_expt_date))
	BREAK
ELSE
	select @wk_over_months = @wk_over_months + 1
	select @wk_break_fee = @wk_over_months*300
	CONTINUE
END
END

select @wk_break_fee = @wk_break_fee - ISNULL(SUM(kc_latepayment_fee),0)  from kcsd.kc_loanpayment l 
left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no 
where c.kc_prod_type = '14' and kc_pay_date between  @wk_min_kc_expt_date and GETDATE() and c.kc_member_no = @pm_member_no


IF(@pm_data_type = '01') 
  BEGIN 
select *,kc_expt_fee+wk_interest_count as total_fee from(
select CONVERT(varchar(6),kc_expt_date,112) data_months, CreateDate,
case when CONVERT(varchar(6),kc_expt_date,112) = CONVERT(varchar(6),@wk_date_10,112) then '當期' else '逾期' end as datatype,
l.kc_case_no,kc_perd_no,kc_expt_date,kc_expt_fee,  DATEDIFF(d,l.kc_expt_date,@wk_getbill_date) wk_dday_count ,@wk_getbill_date getbill_date 
,case when DATEDIFF(d,l.kc_expt_date,@wk_getbill_date) > 0 and l.kc_pay_date is null then   --FLOOR(kc_expt_fee * 0.16 / 365 * DATEDIFF(d,l.kc_expt_date,@wk_getbill_date))  

CAST(ROUND(kc_expt_fee * 0.16 / 365 * DATEDIFF(d,l.kc_expt_date,@wk_getbill_date), 0)AS INT)

else 0 end  wk_interest_count 
from kcsd.kc_loanpayment l
left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
where kc_prod_type = '14' and 
c.kc_member_no = @pm_member_no and kc_expt_date <= dateadd(ms,-3,DATEADD( DD,1,@wk_date_10)) and (kc_pay_date is null or (kc_expt_date <= @wk_date_10 and kc_pay_date > @wk_date_10))
) as xx order by data_months,CreateDate,kc_case_no,kc_perd_no

  END
ELSE IF(@pm_data_type = '02')        
  BEGIN
  select @wk_break_fee as kc_break_fee

  END

ELSE IF(@pm_data_type = '03') 
  BEGIN

select kc_member_no,
case when @wk_over_months = 0 then @wk_date_10 else @wk_getbill_date end as kc_expt_date,SUM(kc_expt_fee) SUM_kc_expt_fee ,@wk_break_fee as kc_break_fee, SUM(wk_interest_count) SUM_interest_count,SUM(kc_expt_fee) +@wk_break_fee+ SUM(wk_interest_count) as total_fee from(
select CONVERT(varchar(6),kc_expt_date,112) data_months, kc_member_no,
case when CONVERT(varchar(6),kc_expt_date,112) = CONVERT(varchar(6),@wk_date_10,112) then '當期' else '逾期' end as datatype,
l.kc_case_no,kc_perd_no,kc_expt_date,kc_expt_fee,  DATEDIFF(d,l.kc_expt_date,@wk_getbill_date) wk_dday_count ,@wk_getbill_date getbill_date 
,case when DATEDIFF(d,l.kc_expt_date,@wk_getbill_date) > 0 and l.kc_pay_date is null then   --FLOOR(kc_expt_fee * 0.16 / 365 * DATEDIFF(d,l.kc_expt_date,@wk_getbill_date))

CAST(ROUND(kc_expt_fee * 0.16 / 365 * DATEDIFF(d,l.kc_expt_date,@wk_getbill_date), 0)AS INT)
else 0 end  wk_interest_count 
from kcsd.kc_loanpayment l
left join kcsd.kc_customerloan c on l.kc_case_no = c.kc_case_no
where kc_prod_type = '14' and 
c.kc_member_no = @pm_member_no and kc_expt_date <= dateadd(ms,-3,DATEADD( DD,1,@wk_date_10)) and (kc_pay_date is null or (kc_expt_date <= @wk_date_10 and kc_pay_date > @wk_date_10))
) as xx GROUP BY kc_member_no,getbill_date



  END


  

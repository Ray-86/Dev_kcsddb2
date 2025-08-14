-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_GetMarketPool] @pm_type varchar(10)=NULL,@pm_marketing_type varchar(50)=NULL,@pm_market_target varchar(10)=NULL 
AS
BEGIN



--不合格名單(黑名單)
CREATE TABLE #tmp_kc_marketer_blacklist
(
kc_id_no	varchar(10),
kc_black_type int
)

--合格名單(白名單)
CREATE TABLE #tmp_kc_marketer_whitelist
(
kc_case_no	varchar(10)
)

--合格獎池名單
CREATE TABLE #tmp_kc_marketer_pool
(
kc_case_no	varchar(10),
kc_case_stat varchar(2),
kc_strt_date datetime,
kc_marketer_code	varchar(3),
kc_marketing_type	varchar(2),
MP datetime,
kc_rema_amt int,
white_type	varchar(1),
black_type	varchar(1)

)

--新增不合格名單
INSERT	#tmp_kc_marketer_blacklist

select kc_id_no,1 as kc_black_type from (select kc_id_no,COUNT(*) as cnt from  kcsd.kc_customerloan where kc_loan_stat <> 'C'  group by kc_id_no) as xx where cnt > 2
union		
select kc_id_no,2 as kc_black_type from (select kc_case_no,COUNT(*) as cnt from kcsd.kc_apptschedule a where kc_appt_type = 'B'  group by kc_case_no) a
left join kcsd.kc_customerloan c on a.kc_case_no = c.kc_case_no where cnt > 6
--union
--select kc_id_no,3 as kc_black_type  from kcsd.kc_marketer m left join kcsd.kc_customerloan c on m.kc_case_no = c.kc_case_no where kc_stop_date is null
union 
select kc_id_no,4 as kc_black_type  from kcsd.kc_customerloan c where kc_pusher_code is not null or kc_buy_date between  DATEADD(DD , -3 , GETDATE())  and GETDATE() or DATEADD (year , 62 , c.kc_birth_date) <=  GETDATE() group by kc_id_no 
union
select kc_id_no,5 as kc_black_type  from kcsd.kc_cpdata where kc_area_code = '00' and kc_cp_date between DATEADD (dd , -180 , GETDATE()) and  GETDATE() group by kc_id_no
union
select kc_id_no,6 as kc_black_type  from  kcsd.kc_blacklist where kc_decline_flag = -1
union
select kc_id_no,7 as kc_black_type  from  kcsd.kc_blacklistlist where kc_updt_date >= DATEADD (dd , -150 , GETDATE())
union
(select DISTINCT kc_id_no,8 as kc_black_type from kcsd.kc_pushassign p left join kcsd.kc_customerloan c on p.kc_case_no = c.kc_case_no where p.kc_pusher_code like 'L%')
union
(
    select DISTINCT kc_id_no,9 as kc_black_type from(
  select ROW_NUMBER() OVER(PARTITION BY d.kc_case_no  ORDER BY d.kc_strt_date  DESC) AS RowNumber,d.*,c.kc_id_no from kcsd.kc_marketer d 
  left join kcsd.kc_customerloan c on d.kc_case_no = c.kc_case_no 
  ) as xx where RowNumber = 1 and kc_marketing_type in ('05','06') and DATEDIFF(MONTH, kc_strt_date, GETDATE()) <= 6 
)
union
select kc_id_no,10 as kc_black_type from kcsd.kc_marketblacklist where IsEnable = 1



--新增合格名單
INSERT	#tmp_kc_marketer_whitelist
select c.kc_case_no from kcsd.kc_customerloan c

  where kc_loan_stat not in ('X','Y','Z','F','N')
  and kc_prod_type not in('13','14')
  and DATEADD (year , 18 , c.kc_birth_date) <=  GETDATE()
  and ISNULL(kc_break_amt2,0) <= 1000
  and SUBSTRING(c.kc_id_no, 2, 1) in ('1','2')



INSERT	#tmp_kc_marketer_pool
  select p.kc_case_no, kc_case_stat, l.kc_strt_date,
  case when @pm_type = 'normal' then l.kc_marketer_code else l2.kc_marketer_code end kc_marketer_code,
  case when @pm_type = 'normal' then l.kc_marketing_type else l2.kc_marketing_type end kc_marketing_type,
  MP,ISNULL(kc_rema_amt,0) kc_rema_amt  ,case when white.kc_case_no is not null then 'V' else '' end white_type ,case when black.kc_id_no is not null then 'V' else '' end black_type 
  from kcsd.kc_marketer_pool p
  left join (  select ROW_NUMBER() OVER(PARTITION BY d.kc_case_no  ORDER BY kc_strt_date  DESC) AS RowNumber,* from kcsd.kc_marketer d ) l on l.RowNumber = 1 and p.kc_case_no = l.kc_case_no
  left join (  select ROW_NUMBER() OVER(PARTITION BY d.kc_case_no  ORDER BY kc_strt_date  DESC) AS RowNumber,* from kcsd.kc_marketerDuDu d ) l2 on l2.RowNumber = 1 and p.kc_case_no = l2.kc_case_no
  left join (    select kc_case_no,MAX(kc_pay_date) MP from kcsd.kc_loanpayment GROUP BY kc_case_no ) M on  p.kc_case_no = M.kc_case_no
  left join  kcsd.kc_customerloan c on p.kc_case_no = c.kc_case_no
  
  left join  #tmp_kc_marketer_whitelist white on p.kc_case_no = white.kc_case_no
  left join  #tmp_kc_marketer_blacklist black on c.kc_id_no = black.kc_id_no
  where 
   p.kc_pool_type = @pm_type

  --and EXISTS ( select kc_case_no from  #tmp_kc_marketer_whitelist white where p.kc_case_no = white.kc_case_no)
  --and not EXISTS ( select kc_id_no from  #tmp_kc_marketer_blacklist X where c.kc_id_no = X.kc_id_no)
 
  and ( @pm_marketing_type = 'ALL' or 
  (l.kc_marketing_type in (SELECT value FROM STRING_SPLIT(@pm_marketing_type, ','))  OR (CHARINDEX('05', @pm_marketing_type) > 0 AND l.kc_marketing_type IS NULL ))                  )
  ORDER BY MP DESC,ISNULL(kc_rema_amt,0) DESC 

IF @pm_market_target = 'Query'
BEGIN
  select * from #tmp_kc_marketer_pool   ORDER BY MP DESC,ISNULL(kc_rema_amt,0) DESC 
END
else IF @pm_market_target = 'Send'
BEGIN
  select * from #tmp_kc_marketer_pool 
  where kc_case_stat = 'A'
  and white_type = 'V'
  and black_type <> 'V'
  and kc_case_no not in (select kc_case_no  from kcsd.kc_marketer where kc_stop_date is null and @pm_type = 'normal'
	union
	select kc_case_no  from kcsd.kc_marketerDuDu where kc_stop_date is null and @pm_type = 'member')

  ORDER BY MP DESC,ISNULL(kc_rema_amt,0) DESC 

  --select * from  kcsd.kc_marketer_pool where kc_case_stat = 'A'
  --and kc_case_no not in (select kc_case_no from kcsd.kc_marketer where kc_stop_date is null)

END

DROP TABLE #tmp_kc_marketer_whitelist
DROP TABLE #tmp_kc_marketer_blacklist
DROP TABLE #tmp_kc_marketer_pool

END



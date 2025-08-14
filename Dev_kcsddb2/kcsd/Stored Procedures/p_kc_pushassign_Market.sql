-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_pushassign_Market] @pm_run_code varchar(10)=NULL
AS
DECLARE	
@wk_case_no			varchar(10),
@wk_loan_perd		int,		
@wk_loan_perd_ed	int,	  --已繳足的期數
@wk_rema_amt		int,	
@wk_id_no		varchar(20),	
@wk_pusher_code	varchar(6),	-- M0 
@wk_pusher_date	datetime,	-- 指派日
@wk_row_cnt		int,		-- 筆數
@wk_row_count	int,
@wk_RNC	int,
@wk_total_cnt	int

--不合格名單
CREATE TABLE #tmp_kc_marketer_blacklist
(
kc_id_no	varchar(10),
kc_black_type int
)


--暫存委派名單
CREATE TABLE #tmp_kc_marketer_test
(
kc_case_no	varchar(10),
kc_strt_date smalldatetime,
kc_marketer_code	varchar(6),
kc_updt_user	varchar(10),
kc_updt_date smalldatetime
)


--新增不合格名單
INSERT	#tmp_kc_marketer_blacklist

select kc_id_no,1 as kc_black_type from (select kc_id_no,COUNT(*) as cnt from  kcsd.kc_customerloan where kc_loan_stat <> 'C'  group by kc_id_no) as xx where cnt > 2
union		
select kc_id_no,2 as kc_black_type from (select kc_case_no,COUNT(*) as cnt from kcsd.kc_apptschedule a where kc_appt_type = 'B'  group by kc_case_no) a
left join kcsd.kc_customerloan c on a.kc_case_no = c.kc_case_no where cnt > 6
union
select kc_id_no,3 as kc_black_type  from kcsd.kc_marketer m left join kcsd.kc_customerloan c on m.kc_case_no = c.kc_case_no where kc_stop_date is null
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




--SELECT	*
--	FROM	#tmp_kc_marketer_blacklist


SELECT	@wk_case_no=NULL, @wk_pusher_code=NULL,	 @wk_pusher_date=NULL, @wk_row_cnt = 0
SELECT @wk_row_count =  Round(RAND() * 1000, 0) --亂數
--取得指派日凌晨
SELECT @wk_pusher_date = CONVERT(varchar(20), GETDATE(), 23)

DECLARE	cursor_case_no	CURSOR FOR

	--1.已繳足1/2期數且未繳餘額低於15000元
	--2.未繳期數小於等於總期數/3
	--3.未繳餘額=0案件
select  c.RNC,c.kc_id_no,c.kc_case_no--,c.kc_birth_date,c.kc_id_no,c.kc_buy_date,kc_loan_perd,kc_perd_no_ed,isnull(kc_rema_amt,0) as kc_rema_amt 
from (select ROW_NUMBER() OVER(PARTITION BY c.kc_id_no ORDER BY c.kc_buy_date) AS 'RNC' ,* from kcsd.kc_customerloan c) c
left join (select kc_case_no, isnull(MAX(kc_perd_no),0) as kc_perd_no_ed from kcsd.kc_loanpayment where kc_perd_no < 50  and kc_pay_date is not null GROUP BY kc_case_no) l1 on c.kc_case_no = l1.kc_case_no
left join (SELECT kc_case_no , Count(kc_case_no) cnt_B from kcsd.kc_apptschedule where kc_appt_type = 'B' and kc_visit_outc is not null and kc_appt_date <= DATEADD(mm, DATEDIFF(mm,0,getdate()), 0) and kc_rela_name in ('0','本人') group by kc_case_no) l2 on c.kc_case_no = l2.kc_case_no
left join (select kc_case_no,MAX(kc_pay_date) MP from kcsd.kc_loanpayment group by kc_case_no) Maxl on C.kc_case_no = Maxl.kc_case_no
where kc_loan_stat not in ('X','Y','Z','F','N')
and kc_prod_type not in('13','14')
and DATEADD (year , 18 , c.kc_birth_date) <=  GETDATE()
and ISNULL(kc_break_amt2,0) <= 1000
and SUBSTRING(c.kc_id_no, 2, 1) in ('1','2')
and MP >= '2025-01-01'
and not EXISTS (
select kc_id_no from  #tmp_kc_marketer_blacklist X where c.kc_id_no = X.kc_id_no
)

and(
(kc_loan_perd / 2 < ISNULL(kc_perd_no_ed,0) and ISNULL(kc_rema_amt,0) < 15000 and ISNULL(kc_give_amt,0)  > 30000) 
or (kc_loan_perd - ISNULL(kc_perd_no_ed,0) <= kc_loan_perd / 3 and kc_rema_amt < 150000)
or (ISNULL(kc_rema_amt,0) = 0)
)
ORDER BY c.kc_case_no,kc_rema_amt DESC  


OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_RNC,@wk_id_no,@wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code = NULL

    select @wk_total_cnt = COUNT(*) from kcsd.kc_customerloan where kc_id_no = @wk_id_no GROUP BY kc_id_no

	--檢查此ID所有案件是不是都符合
	IF @wk_RNC = @wk_total_cnt
	BEGIN
		--委派
		EXECUTE kcsd.p_kc_pushassign_sub_pusher	@wk_pusher_code OUTPUT, @wk_case_no, '', @wk_row_count OUTPUT,@wk_row_cnt OUTPUT,'T'
		--select @wk_pusher_code,@wk_row_count,@wk_row_cnt 

		IF	@wk_pusher_code IS NOT NULL 
		BEGIN
			IF	@pm_run_code = 'EXECUTE'
			BEGIN
				-- 新增指派
				INSERT	kcsd.kc_marketer
					(kc_case_no, kc_strt_date, kc_marketer_code,kc_updt_user, kc_updt_date)
				VALUES	(@wk_case_no, @wk_pusher_date, @wk_pusher_code,USER, GETDATE() )
			END
			ELSE
				--存測試資料
				INSERT	#tmp_kc_marketer_test
					(kc_case_no, kc_strt_date, kc_marketer_code,kc_updt_user, kc_updt_date)
				VALUES	(@wk_case_no, @wk_pusher_date, @wk_pusher_code,USER, GETDATE() )
		END
	END



		FETCH NEXT FROM cursor_case_no INTO  @wk_RNC,@wk_id_no,@wk_case_no	

END	

		
CLOSE cursor_case_no
DEALLOCATE	cursor_case_no



--------回收委派 


		IF	@pm_run_code = 'EXECUTE'
		BEGIN
		update kcsd.kc_marketer set kc_stop_date = GETDATE() where kc_item_no in(
		---
		select kc_item_no from  kcsd.kc_marketer m 
		left join kcsd.kc_customerloan c on m.kc_case_no = c.kc_case_no
		where m.kc_stop_date is null 
		and m.kc_strt_date < CONVERT(varchar(100), GETDATE(), 23)
		and  (EXISTS (select kc_id_no from  #tmp_kc_marketer_blacklist X where c.kc_id_no = X.kc_id_no and kc_black_type <> 3)
		or ISNULL(kc_break_amt2,0) > 1000
		or (kc_loan_stat = 'F') 
		or  SUBSTRING(c.kc_id_no, 2, 1) not in ('1','2'))	
		---
		)
		END
		else

		select * from  kcsd.kc_marketer m 
		left join kcsd.kc_customerloan c on m.kc_case_no = c.kc_case_no
		where m.kc_stop_date is null 
		and m.kc_strt_date < CONVERT(varchar(100), GETDATE(), 23)
		and  (EXISTS (select kc_id_no from  #tmp_kc_marketer_blacklist X where c.kc_id_no = X.kc_id_no and kc_black_type <> 3)
		or ISNULL(kc_break_amt2,0) > 1000
		or (kc_loan_stat = 'F') 
		or  SUBSTRING(c.kc_id_no, 2, 1) not in ('1','2'))	

		
SELECT	*
	FROM	#tmp_kc_marketer_test
	ORDER BY kc_marketer_code DESC

SELECT	kc_marketer_code,COUNT(*)
	FROM	#tmp_kc_marketer_test
	GROUP BY kc_marketer_code
	ORDER BY kc_marketer_code DESC
	
DROP TABLE #tmp_kc_marketer_test
DROP TABLE #tmp_kc_marketer_blacklist



--select * from  kcsd.kc_marketer m where kc_case_no = 'T040465'







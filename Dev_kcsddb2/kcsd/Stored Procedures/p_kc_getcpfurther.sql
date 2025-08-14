
CREATE PROCEDURE [kcsd].[p_kc_getcpfurther]
AS
BEGIN

	DECLARE	
	@wk_further_flag int,
	@wk_further_flag1 int,
	@wk_further_flag2 int,
	@wk_further_flag3 int,
	@wk_further_flag4 int,
	@wk_further_flag5 int,
	@wk_further_flag6 int,
	@wk_further_flag7 int,

	@wk_further_flagID int,
	@wk_further_flagLOC int
--經銷補查
select @wk_further_flag = COUNT(*) from kcsd.kc_cpdata where (kc_further_flag = 'Y' or kc_further_flag3 = 'Y' or kc_further_flag5 = 'Y') and datediff(s,kc_updt_date,getdate()) > 30
--勞保補查
select @wk_further_flag1 = COUNT(*) from kcsd.kc_cpdata where kc_further_flag1 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30
--設定補查
select @wk_further_flag2 = COUNT(*) from kcsd.kc_cpdata where kc_further_flag2 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30
--特約補查
--select @wk_further_flag3 = COUNT(*) from kcsd.kc_cpdata where kc_further_flag3 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30
select @wk_further_flag3 = 0
--特約徵審
select @wk_further_flag4 = COUNT(*) from (
select kc_cp_no from kcsd.kc_cpdata where kc_further_flag4 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30 and (datediff(s,kc_further_date3,getdate()) > 120 OR ((kc_source_type <> '03'  and datediff(s,kc_further_date5,getdate()) > 1200)  or (kc_source_type = '03'  and (datediff(s,kc_further_date5,getdate()) > 120 or kc_prod_type = '14' ))))
union
select kc_cp_no from [kcsd].[kc_noticecfm] where kc_notice_flag = 'Y' and kc_notice_type = '1' and   datediff(s,kc_updt_date,getdate()) > 5 and datediff(s,kc_notice_date,getdate()) > 5) as cnt
--COUNT(*) from kcsd.kc_cpdata where kc_further_flag4 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30 and datediff(s,kc_further_date3,getdate()) > 10

--業務補查
select @wk_further_flag5 = COUNT(*) from kcsd.kc_cpdata where kc_further_flag5 = 'Y' and datediff(s,kc_updt_date,getdate()) > 30
select @wk_further_flag5 = 0
--待辦(徵審)
select @wk_further_flag6 = COUNT(*) from [kcsd].[kc_noticecfm] where kc_notice_flag = 'Y'  and  datediff(s,kc_updt_date,getdate()) > 5 and ((datediff(s,kc_notice_date,getdate()) > 5 and kc_notice_type = '3') or (datediff(s,kc_notice_date,getdate()) > -60 and kc_notice_type in ('2','6')))
--待辦(客服)
select @wk_further_flag7 = COUNT(*) from kcsd.kc_creditmemo where kc_notice_flag = 'Y' and  datediff(s,kc_updt_date,getdate()) > 5

--待辦(客服)
select @wk_further_flagLOC = COUNT(*) from kcsd.kc_LOCdata where kc_further_flag = 'Y' 



--經銷補查
select @wk_further_flagID = ID0K +ID0L +ID0M+ID1K+ID1L from (
select sum(ID0K) ID0K,sum(ID0L) ID0L,sum(ID0M) ID0M,sum(ID1K) ID1K,sum(ID1L) ID1L from(
select case when ID0K_0_flag = 'Y' then 1 else 0 end ID0K,
case when ID0L_0_flag = 'Y' then 1 else 0 end ID0L,
case when ID0M_0_flag = 'Y' then 1 else 0 end ID0M,
case when ID0K_1_flag = 'Y' then 1 else 0 end ID1K,
case when ID0L_1_flag = 'Y' then 1 else 0 end ID1L
from kcsd.kc_piccsno
) as xx)as xx





--2020/09/08 暫停f4的運作
--2020/11/16 重新恢復f4的運作
UPDATE kcsd.kc_cpfurther SET kc_further_flag = @wk_further_flag,kc_further_flag1 = @wk_further_flag1,kc_further_flag2 = @wk_further_flag2,kc_further_flag3 = @wk_further_flag3,
kc_further_flag4 = @wk_further_flag4 ,kc_further_flag5 = @wk_further_flag5,kc_further_flag6 = @wk_further_flag6,kc_further_flag7 = @wk_further_flag7,kc_further_flagID = @wk_further_flagID,kc_further_flagLOC = @wk_further_flagLOC,
kc_updt_user='dbo',kc_updt_date = GETDATE()

END






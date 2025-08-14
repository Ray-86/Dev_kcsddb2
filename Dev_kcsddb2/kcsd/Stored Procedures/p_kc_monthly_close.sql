-- ==========================================================================================
--
-- ==========================================================================================


CREATE PROCEDURE [kcsd].[p_kc_monthly_close] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL
AS

DECLARE	@wk_strt_date	datetime,
		@wk_stop_date	datetime

--電催月結寫入 kc_pushonhand_push
EXEC kcsd.p_kc_pushonhand_push @pm_strt_date,@pm_stop_date,NULL,'EXECUTE'

--法催月結寫入 kc_pushonhand_law
EXEC kcsd.p_kc_pushonhand_law @pm_strt_date,@pm_stop_date,NULL,'EXECUTE'

--新增車行月結寫入 kc_stat_caragent
--EXEC kcsd.p_kc_stat_caragent @pm_strt_date,@pm_stop_date,'EXECUTE'

--正常金額回收 kc_stat_receivables
EXEC kcsd.p_kc_stat_receivables @pm_strt_date,@pm_stop_date,'EXECUTE'

--逾放比率 kc_overdueacc (四期逾帳/收入/營業成本/利息折扣(前20月~前4月))
EXEC kcsd.p_kc_debtage_new @pm_strt_date,@pm_stop_date,'EXECUTE'

--業務逾期完全未繳 kc_stat_salesoverdue4 (前4月)
SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-4,@pm_strt_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-3,@pm_strt_date))+1, 0))
EXEC kcsd.p_kc_stat_salesoverdue @wk_strt_date,@wk_stop_date,@pm_stop_date,'A','EXECUTE'

--業務逾期正常件 kc_stat_salesoverdue4g (前4月)
SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-4,@pm_strt_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-3,@pm_strt_date))+1, 0))
EXEC kcsd.p_kc_stat_salesoverdue @wk_strt_date,@wk_stop_date,@pm_stop_date,'C','EXECUTE'

--累計完全未繳 kc_stat_salesoverdue15 (前15月)
SELECT @wk_strt_date = DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-15,@pm_strt_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-3,@pm_strt_date))+1, 0))
EXEC kcsd.p_kc_stat_salesoverdue @wk_strt_date,@wk_stop_date,@pm_stop_date,'B','EXECUTE'

--催收轉法務
EXEC kcsd.p_kc_pushonhand_PtoL @pm_strt_date,@pm_stop_date,NULL,'EXECUTE'

--到期回收率 kc_deadline_per   20200806王冠博新增
SELECT @wk_strt_date =  DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-17,@pm_stop_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-5,@pm_stop_date))+1, 0))
EXEC [kcsd].[p_kc_deadline_per] @wk_strt_date,@wk_stop_date,@pm_stop_date,'EXECUTE'

--逾三金額比 kc_over3month_per   20200806王冠博新增
SELECT @wk_strt_date =  DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-17,@pm_stop_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-5,@pm_stop_date))+1, 0))
EXEC [kcsd].[p_kc_over3month_per] @wk_strt_date,@wk_stop_date,@pm_stop_date,'EXECUTE'

--逾三金額比(經銷) kc_over3month_caragent   20200813王冠博新增
SELECT @wk_strt_date =  DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-17,@pm_stop_date))+1, 0)
SELECT @wk_stop_date = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-5,@pm_stop_date))+1, 0))
EXEC [kcsd].[p_kc_over3month_caragent] @wk_strt_date,@wk_stop_date,@pm_stop_date,'EXECUTE'
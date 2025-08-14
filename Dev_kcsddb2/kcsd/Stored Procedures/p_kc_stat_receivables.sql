-- ==========================================================================================
-- 
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_stat_receivables] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_receivables
(
kc_exp_date		varchar(6),
kc_area_code	varchar(2),
kc_prod_type	varchar(2),
kc_rece_sum1	bigint,
kc_rece_sum2	bigint
)

INSERT	#tmp_receivables
--上個月
select ss.kc_expt_date,ss.kc_area_code,ss.kc_prod_type,sum(s1) as s1,sum(s2) as s2 from 
(
select c.kc_area_code,c.kc_prod_type,convert(varchar(6),l.kc_expt_date,112) as kc_expt_date ,
Sum(Case When l.kc_perd_no<50 Then cast(l.kc_expt_fee as bigint) Else 0 End)-Sum(Case When l.kc_pay_date <= DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm, -1,@pm_strt_date))+1, 0)) Then cast(l.kc_pay_fee as bigint) Else 0 End) AS s1,
'' as s2
FROM kcsd.kc_loanpayment l INNER JOIN kcsd.kc_customerloan c ON l.kc_case_no = c.kc_case_no
where 
c.kc_loan_stat Not In ('X','Y','Z') and 
c.kc_buy_date between DATEADD(mm, -62,@pm_strt_date) and DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm, -1,@pm_strt_date))+1, 0))
group by c.kc_area_code,c.kc_prod_type,convert(varchar(6),l.kc_expt_date,112)
union
--本月
select c.kc_area_code,c.kc_prod_type,convert(varchar(6),l.kc_expt_date,112),'' as s1,
Sum(Case When l.kc_perd_no<50 Then cast(l.kc_expt_fee as bigint) Else 0 End)-Sum(Case When l.kc_pay_date <= @pm_stop_date Then cast(l.kc_pay_fee as bigint) Else 0 End) AS s2
FROM kcsd.kc_loanpayment l INNER JOIN kcsd.kc_customerloan c ON l.kc_case_no = c.kc_case_no
where 
c.kc_loan_stat Not In ('X','Y','Z') and 
c.kc_buy_date between DATEADD(mm, -61,@pm_strt_date) and @pm_stop_date
group by c.kc_area_code,c.kc_prod_type,convert(varchar(6),l.kc_expt_date,112)
) as ss
group by ss.kc_expt_date,ss.kc_area_code,ss.kc_prod_type
having ss.kc_expt_date = convert(varchar(6),@pm_strt_date,112)
order by ss.kc_expt_date,ss.kc_area_code

IF	@pm_run_code = 'EXECUTE'
BEGIN

DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_stat_receivables where kc_exp_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_stat_receivables
		SELECT * from #tmp_receivables
	END
END
ELSE
BEGIN
	SELECT	* FROM	#tmp_receivables
END

DROP TABLE #tmp_receivables

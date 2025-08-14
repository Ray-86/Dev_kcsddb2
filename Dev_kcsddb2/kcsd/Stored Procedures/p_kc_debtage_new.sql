
-- ==========================================================================================
-- 20180309 增加產品別
-- 20170301 修正計算方式(只計算購買日區間內案件)
-- ==========================================================================================

CREATE   PROCEDURE [kcsd].[p_kc_debtage_new]	@pm_strt_date DATETIME, @pm_stop_date DATETIME,@pm_run_code varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_area_code	varchar(2),
	@wk_prod_type	varchar(2),
	@wk_due_date	datetime,		--age_date+1
	@wk_over_amt	int,			--逾期金額
	@wk_arec_amt	int,			--未繳金額
	@wk_dday_date	datetime,		--dummy for p_kc_getoveramt
	@wk_strt_date2	datetime,
	@wk_stop_date2	datetime


CREATE TABLE #tmp_debtage
(kc_case_no	varchar(10),
kc_area_code	varchar(2),
kc_prod_type	varchar(2),
kc_expt_sum	int,			--逾期金額
kc_arec_amt	int,			--未繳金額
kc_dday_count	int			--逾期月數
)

--select @pm_strt_date = '2015-05-01'
--select @pm_stop_date = '2016-12-31'
SELECT @wk_case_no = NULL
SELECT @wk_strt_date2 = DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-20,@pm_stop_date))+1, 0)				--前20個月的第一天
SELECT @wk_stop_date2 = DATEADD(ms,-3,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-4,@pm_stop_date))+1, 0))	--前4個月的最後一天精準到秒
SELECT @wk_due_date = DATEADD(day, 1, @pm_stop_date)

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no,kc_area_code,kc_prod_type
	FROM	kcsd.kc_customerloan
	WHERE	kc_buy_date between @wk_strt_date2 and @pm_stop_date
		and kc_loan_stat Not In ('X','Y','Z')

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_area_code,@wk_prod_type

WHILE (@@FETCH_STATUS = 0)
BEGIN
	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

	IF	@wk_over_amt > 0 and DATEDIFF(month, @wk_dday_date, @pm_stop_date)>=4
	BEGIN
		INSERT	#tmp_debtage
			(kc_case_no,kc_area_code,kc_prod_type,kc_expt_sum, kc_arec_amt,kc_dday_count)
		VALUES	(@wk_case_no,@wk_area_code,@wk_prod_type,@wk_over_amt, @wk_arec_amt,DATEDIFF(month, @wk_dday_date, @pm_stop_date) )
	END		

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no,@wk_area_code,@wk_prod_type
END

DEALLOCATE	cursor_case_no

IF	@pm_run_code = 'EXECUTE'
BEGIN
DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_overdueacc where kc_buy_date = convert(varchar(6),@pm_strt_date,112)
	IF @wk_datacount = 0
		BEGIN
		Insert into kcsd.kc_overdueacc
		select ss.kc_buy_date,ss.kc_area_code,ss.kc_prod_type,sum(ss.kc_arec_amt) as kc_arec_amt,sum(ss.kc_expt_sum) as kc_expt_sum ,sum(kc_loan_cost) as kc_loan_cost,sum(ss.kc_intr_sum) as kc_intr_sum
		from (
			SELECT convert(varchar(6),@pm_strt_date,112) as kc_buy_date,kc_area_code,kc_prod_type,sum(kc_arec_amt)as kc_arec_amt,0 as kc_expt_sum,0 as kc_loan_cost,0 as kc_intr_sum FROM #tmp_debtage 
			group by kc_area_code,kc_prod_type
			union
			select convert(varchar(6),@pm_strt_date,112) as kc_buy_date,kc_area_code,c.kc_prod_type,0 as kc_arec_amt,sum(cast(kc_perd_fee as bigint) * cast(kc_loan_perd as bigint)) as kc_expt_sum,sum(isnull(kc_cred_fee,0))+sum(isnull(kc_insu_sum,0))+sum(isnull(kc_totm_fee,0))+sum(isnull(kc_aux_amt,0)*180)+sum(isnull(kc_give_amt,0)) as kc_loan_cost,0 as kc_intr_sum
			from kcsd.kc_customerloan c
			where
			c.kc_loan_stat Not In ('Y','Z') and 
			c.kc_buy_date between @wk_strt_date2 and @wk_stop_date2
			group by kc_area_code,c.kc_prod_type
			union
			select convert(varchar(6),@pm_strt_date,112) as kc_buy_date,c.kc_area_code,c.kc_prod_type,0 as kc_arec_amt,0 as kc_expt_sum,0 as kc_loan_cost,sum(l.kc_intr_fee) as kc_intr_sum
			FROM kcsd.kc_loanpayment l INNER JOIN kcsd.kc_customerloan c ON l.kc_case_no = c.kc_case_no
			where
			c.kc_loan_stat Not In ('Y','Z') and 
			l.kc_pay_date between @wk_strt_date2 and @wk_stop_date2
			group by c.kc_area_code,c.kc_prod_type
		) as ss
		group by ss.kc_buy_date,ss.kc_area_code,ss.kc_prod_type
	END
END
ELSE
BEGIN
	SELECT * FROM #tmp_debtage  ORDER BY kc_area_code,kc_case_no

	--20200701 報表測
	/*
	SELECT d.kc_case_no,d.kc_area_code,d.kc_dday_count,d.kc_arec_amt , c.kc_buy_date , c.kc_birth_date ,(case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20 
	FROM #tmp_debtage  d
	left join  [kcsd].[kc_customerloan]  c on d.kc_case_no = c.kc_case_no
	where c.kc_buy_date between '2019-01-01' and '2019-12-31'
	and c.kc_prod_type = '07'
    ORDER BY kc_area_code*/

	/*
	select kc_area_code,kc_prod_type,sum(cast(kc_perd_fee as bigint) * cast(kc_loan_perd as bigint)) as kc_expt_sum
	from [kcsd].[kc_customerloan]  c 
	where 
	c.kc_loan_stat Not In ('Y','Z') and 
	c.kc_buy_date between '2019-01-01' and '2019-12-31'
	and c.kc_prod_type = '01'
	GROUP BY kc_area_code,kc_prod_type
	ORDER BY kc_area_code*/
	/*
	select kc_area_code,0 as kc_dday_count,0 as kc_arec_amt,cast(kc_perd_fee as bigint) * cast(kc_loan_perd as bigint) as kc_expt_sum , kc_buy_date,kc_birth_date ,(case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20 
	from [kcsd].[kc_customerloan]  c 
	where 
	c.kc_loan_stat Not In ('Y','Z') and 
	c.kc_buy_date between '2019-01-01' and '2019-12-31'*/

	--	ORDER BY d.kc_area_code,d.kc_case_no
/*
	,c.kc_buy_date,kc_birth_date ,(case  when  DATEADD (year , 20,c.kc_birth_date )< c.kc_buy_date  then  'yes'  else  'no'  end ) as  Is20  ,c.kc_expt_sum
	FROM #tmp_debtage  d
	union (select kc_case_no,kc_buy_date,kc_birth_date ,kc_prod_type ,cast(kc_perd_fee as bigint) * cast(kc_loan_perd as bigint) as kc_expt_sum  from [kcsd].[kc_customerloan])  c on d.kc_case_no = c.kc_case_no
	where c.kc_buy_date between '2019-01-01' and '2019-12-31'
	and c.kc_prod_type = '01'
	ORDER BY d.kc_area_code,d.kc_case_no*/

END
-- ==========================================================================================
-- 20180309 增加產品別
-- 2014-06-10 cursor 改寫 select
-- 2005-11-12 proc for 業務逾期統計 kcp_stat01
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_stat_salesoverdue] @pm_strt_date DATETIME=NULL,@pm_stop_date DATETIME=NULL,@pm_cut_date DATETIME=NULL,@pm_run_type varchar(1)=NULL,@pm_run_code varchar(10)=NULL
AS

DECLARE	@wk_buy_date	datetime

SELECT	@wk_buy_date = @pm_cut_date
SELECT	@pm_cut_date = DATEADD(day, 1, @pm_cut_date )

--去除時間
SELECT @pm_strt_date = DATEADD(dd, 0, DATEDIFF(dd, 0, @pm_strt_date))
SELECT @pm_stop_date = DATEADD(dd, 0, DATEDIFF(dd, 0, @pm_stop_date))
SELECT @wk_buy_date = DATEADD(dd, 0, DATEDIFF(dd, 0, @wk_buy_date))
SELECT @pm_cut_date = DATEADD(dd, 0, DATEDIFF(dd, 0, @pm_cut_date))
print @pm_stop_date
print @pm_cut_date
CREATE TABLE #tmp_salesoverdue
(
kc_case_no		varchar(7),
kc_area_code	varchar(2),
kc_prod_type	varchar(2),
kc_buy_date		datetime,
kc_over_amt		int,
kc_pay_sum		int,
)

INSERT #tmp_salesoverdue
SELECT kc_case_no,c.kc_area_code,kc_prod_type,kc_buy_date,1 AS kc_over_amt,(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date < @pm_cut_date) AS kc_pay_sum
FROM kcsd.kc_customerloan c
WHERE kc_buy_date BETWEEN @pm_strt_date  AND @pm_stop_date
	AND kc_loan_stat Not In ('Y','Z')
	AND (SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < @pm_cut_date AND kc_perd_no < 50)-(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date < @pm_cut_date)>0
ORDER BY c.kc_case_no

IF	@pm_run_code = 'EXECUTE'
BEGIN
	DECLARE @wk_datacount int
	IF @pm_run_type ='A'	--累計完全未繳(前4月)
	BEGIN
		SELECT @wk_datacount = count(*) from kcsd.kc_stat_salesoverdue4 where kc_buy_date = convert(varchar(6),@wk_buy_date,112)
		IF @wk_datacount = 0
			BEGIN
			Insert into kcsd.kc_stat_salesoverdue4
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_over_cnt),sum(kc_case_cnt),GETDATE() as kc_updt_date from (
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,s.kc_area_code,kc_prod_type,count(s.kc_over_amt)as kc_over_cnt,0 as kc_case_cnt
							FROM #tmp_salesoverdue s
							where s.kc_over_amt>0 and s.kc_pay_sum =0
							group by s.kc_area_code,kc_prod_type
					union all
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,kc_area_code,kc_prod_type,0 as kc_over_cnt,count(kc_case_no) as kc_case_cnt
							FROM kcsd.kc_customerloan
							where kc_loan_stat Not In ('Y','Z') 
							and kc_buy_date between @pm_strt_date and @pm_stop_date
							group by kc_area_code,kc_prod_type
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
		END
	END
	ELSE IF @pm_run_type ='B'--完全未繳(前15月)
	BEGIN
		SELECT @wk_datacount = count(*) from kcsd.kc_stat_salesoverdue15 where kc_buy_date = convert(varchar(6),@wk_buy_date,112)
		IF @wk_datacount = 0
			BEGIN
			Insert into kcsd.kc_stat_salesoverdue15
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_over_cnt),sum(kc_case_cnt),GETDATE() as kc_updt_date from (
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,s.kc_area_code,kc_prod_type,count(s.kc_over_amt)as kc_over_cnt,0 as kc_case_cnt
							FROM #tmp_salesoverdue s
							where s.kc_over_amt>0 and s.kc_pay_sum =0
							group by s.kc_area_code,kc_prod_type
					union all
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,kc_area_code,kc_prod_type,0 as kc_over_cnt,count(kc_case_no) as kc_case_cnt
							FROM kcsd.kc_customerloan
							where kc_loan_stat Not In ('Y','Z') 
							and kc_buy_date between @pm_strt_date and @pm_stop_date
							group by kc_area_code,kc_prod_type
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
			/*
			Insert into kcsd.kc_stat_salesoverdue15
			SELECT convert(varchar(6),@wk_buy_date,112),s.kc_area_code,kc_prod_type,count(s.kc_over_amt)as kc_over_cnt,(select count(kc_case_no) from kcsd.kc_customerloan where kc_loan_stat Not In ('Y','Z') and kc_area_code = s.kc_area_code and kc_buy_date between @pm_strt_date and @pm_stop_date) as kc_case_cnt
			FROM #tmp_salesoverdue s
			where s.kc_over_amt>0 and s.kc_pay_sum =0
			group by s.kc_area_code
			order by kc_area_code
			*/
		END
	END
	ELSE IF @pm_run_type ='C'--正常件(前4月)
	BEGIN
		SELECT @wk_datacount = count(*) from kcsd.kc_stat_salesoverdue4g where kc_buy_date = convert(varchar(6),@wk_buy_date,112)
		IF @wk_datacount = 0
			BEGIN
			Insert into kcsd.kc_stat_salesoverdue4g
			select convert(varchar(6),@wk_buy_date,112),kc_area_code,kc_prod_type,count(kc_case_no) as kc_good_cnt,(select count(kc_case_no) from kcsd.kc_customerloan where kc_loan_stat Not In ('Y','Z') and kc_area_code = c.kc_area_code and kc_prod_type = c.kc_prod_type and kc_buy_date between @pm_strt_date and @pm_stop_date) as kc_case_cnt,GETDATE() as kc_updt_date
			from kcsd.kc_customerloan c
			where kc_loan_stat Not In ('Y','Z') and
			kc_buy_date between @pm_strt_date and @pm_stop_date and
			not exists
			(SELECT	1 FROM #tmp_salesoverdue where kc_case_no = c.kc_case_no)
			group by kc_area_code,kc_prod_type
			order by kc_area_code
		END
	END
END
ELSE
BEGIN
	IF @pm_run_type ='A'	--累計完全未繳(前4月)
	BEGIN
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_over_cnt),sum(kc_case_cnt),GETDATE() as kc_updt_date from (
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,s.kc_area_code,kc_prod_type,count(s.kc_over_amt)as kc_over_cnt,0 as kc_case_cnt
							FROM #tmp_salesoverdue s
							where s.kc_over_amt>0 and s.kc_pay_sum =0
							group by s.kc_area_code,kc_prod_type
					union all
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,kc_area_code,kc_prod_type,0 as kc_over_cnt,count(kc_case_no) as kc_case_cnt
							FROM kcsd.kc_customerloan
							where kc_loan_stat Not In ('Y','Z') 
							and kc_buy_date between @pm_strt_date and @pm_stop_date
							group by kc_area_code,kc_prod_type
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
	END
	ELSE IF @pm_run_type ='B'--完全未繳(前15月)
	BEGIN
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_over_cnt),sum(kc_case_cnt),GETDATE() as kc_updt_date from (
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,s.kc_area_code,kc_prod_type,count(s.kc_over_amt)as kc_over_cnt,0 as kc_case_cnt
							FROM #tmp_salesoverdue s
							where s.kc_over_amt>0 and s.kc_pay_sum =0
							group by s.kc_area_code,kc_prod_type
					union all
					SELECT convert(varchar(6),@wk_buy_date,112) as kc_buy_date,kc_area_code,kc_prod_type,0 as kc_over_cnt,count(kc_case_no) as kc_case_cnt
							FROM kcsd.kc_customerloan
							where kc_loan_stat Not In ('Y','Z') 
							and kc_buy_date between @pm_strt_date and @pm_stop_date
							group by kc_area_code,kc_prod_type
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
	END
	ELSE IF @pm_run_type ='C'--正常件(前4月)
	BEGIN
			select convert(varchar(6),@wk_buy_date,112),kc_area_code,kc_prod_type,count(kc_case_no) as kc_good_cnt,(select count(kc_case_no) from kcsd.kc_customerloan where kc_loan_stat Not In ('Y','Z') and kc_area_code = c.kc_area_code and kc_prod_type = c.kc_prod_type and kc_buy_date between @pm_strt_date and @pm_stop_date) as kc_case_cnt,GETDATE() as kc_updt_date
			from kcsd.kc_customerloan c
			where kc_loan_stat Not In ('Y','Z') and
			kc_buy_date between @pm_strt_date and @pm_stop_date and
			not exists
			(SELECT	1 FROM #tmp_salesoverdue where kc_case_no = c.kc_case_no)
			group by kc_area_code,kc_prod_type
			order by kc_area_code
	END
END
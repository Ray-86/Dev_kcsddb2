

CREATE PROCEDURE [kcsd].[p_kc_over3month_caragent] @pm_strt_date DATETIME=NULL ,@pm_stop_date DATETIME=NULL ,@pm_stop_date2 DATETIME=NULL    ,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_over3month
(
kc_buy_date		varchar(6),
kc_comp_code	varchar(4),
kc_case_no      varchar(20),
kc_badcase_payfee int,
kc_expt_fee int,
)
INSERT #tmp_over3month
select convert(varchar(6),@pm_stop_date2,112) as kc_buy_date,kc_comp_code,kc_case_no,case when kc_over_amt > 0 and kc_over_count >= 3 then kc_expt_fee - kc_pay_fee else 0 end as kc_badcase_payfee , kc_expt_fee
from 
(
select A.kc_buy_date,A.kc_comp_code,A.kc_case_no,
SUM(A.kc_perd_fee * A.kc_loan_perd) AS kc_expt_fee,
f.kc_over_amt,f.kc_over_count,
(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = A.kc_case_no and kc_pay_date <= @pm_stop_date2) as kc_pay_fee
from kcsd.kc_customerloan A
LEFT JOIN (
SELECT kc_case_no,
ISNULL((SELECT	DATEDIFF(day,MIN(kc_expt_date),DATEADD(day,1,@pm_stop_date2))/30 FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND (kc_pay_date >= DATEADD(day,1,@pm_stop_date2) OR kc_pay_date IS NULL)),0) AS kc_over_count,
(SELECT ISNULL(SUM(kc_expt_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_expt_date < DATEADD(day, 1, @pm_stop_date2 ) AND kc_perd_no < 50)-(SELECT ISNULL(SUM(kc_pay_fee), 0) FROM kcsd.kc_loanpayment WHERE kc_case_no = c.kc_case_no AND kc_pay_date <DATEADD(day, 1, @pm_stop_date2 ))  AS kc_over_amt
FROM	kcsd.kc_customerloan c
	) f ON A.kc_case_no = f.kc_case_no
WHERE kc_loan_stat Not In ('Y','Z') 
AND A.kc_buy_date Between @pm_strt_date And @pm_stop_date
group by f.kc_over_amt,f.kc_over_count,A.kc_case_no,kc_comp_code,kc_buy_date
) as x


IF	@pm_run_code = 'EXECUTE'
BEGIN
DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_over3month_caragent where kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	IF @wk_datacount > 0
	BEGIN
	DELETE FROM kcsd.kc_over3month_caragent WHERE  kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	END
			Insert into kcsd.kc_over3month_caragent
			select *,
			case 
			when ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) > 0.05 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0401 and 0.05 and kc_case_cnt < 6) then 'E'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0401 and 0.05 and kc_case_cnt > 5) 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0301 and 0.04 and kc_case_cnt between 0 and 10) then 'D'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0301 and 0.04 and kc_case_cnt > 10) 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.03 and kc_case_cnt between 0 and 10) then 'C'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0201 and 0.03 and kc_case_cnt > 10)
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.02 and kc_case_cnt between 11 and 50) then 'B'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.02 and kc_case_cnt > 50)then 'A'END as kc_caragent_point,
			GETDATE() as kc_updt_date
			from (		
			select kc_buy_date ,kc_comp_code, (select Count(kc_case_no) as kc_case_cnt from kcsd.kc_customerloan c where kc_buy_date between DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-12,@pm_stop_date2))+1, 0)  and @pm_stop_date2 and c.kc_comp_code = o.kc_comp_code) as kc_case_cnt  , SUM(kc_badcase_payfee) as kc_badcase_payfee, SUM(kc_expt_fee) as kc_expt_fee		 
			FROM #tmp_over3month  o        
			group by kc_buy_date ,kc_comp_code
			) as x
			order by kc_comp_code
	
END
ELSE
BEGIN
			--Insert into kcsd.kc_over3month_caragent
			select *,
			case 
			when ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) > 0.05 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0401 and 0.05 and kc_case_cnt < 6) then 'E'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0401 and 0.05 and kc_case_cnt > 5) 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0301 and 0.04 and kc_case_cnt between 0 and 10) then 'D'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0301 and 0.04 and kc_case_cnt > 10) 
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.03 and kc_case_cnt between 0 and 10) then 'C'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0.0201 and 0.03 and kc_case_cnt > 10)
				or (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.02 and kc_case_cnt between 11 and 50) then 'B'
			when (ROUND((kc_badcase_payfee*1.00) / kc_expt_fee , 4) between 0 and 0.02 and kc_case_cnt > 50)then 'A'END as kc_caragent_point,
			GETDATE() as kc_updt_date
			from (		
			select kc_buy_date ,kc_comp_code, (select Count(kc_case_no) as kc_case_cnt from kcsd.kc_customerloan c where kc_buy_date between DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,-12,@pm_stop_date2))+1, 0)  and @pm_stop_date2 and c.kc_comp_code = o.kc_comp_code) as kc_case_cnt  , SUM(kc_badcase_payfee) as kc_badcase_payfee, SUM(kc_expt_fee) as kc_expt_fee		 
			FROM #tmp_over3month  o        
			group by kc_buy_date ,kc_comp_code
			) as x
			order by kc_comp_code
END


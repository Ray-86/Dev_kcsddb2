-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [kcsd].[p_kc_over3month_per] @pm_strt_date DATETIME=NULL ,@pm_stop_date DATETIME=NULL ,@pm_stop_date2 DATETIME=NULL    ,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_over3month
(
kc_buy_date		varchar(6),
kc_prod_type	varchar(2),
kc_area_code	varchar(2),
kc_badcase_payfee int,
kc_expt_fee int,
)

INSERT #tmp_over3month
select convert(varchar(6),@pm_stop_date2,112) as kc_buy_date,kc_prod_type,kc_area_code,case when kc_over_amt > 0 and kc_over_count >= 3 then kc_expt_fee - kc_pay_fee else 0 end as kc_badcase_payfee , kc_expt_fee
from 
(
select A.kc_prod_type,A.kc_buy_date,A.kc_area_code,
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
group by kc_prod_type,f.kc_over_amt,f.kc_over_count,A.kc_case_no,kc_area_code,kc_buy_date
) as x



IF	@pm_run_code = 'EXECUTE'
BEGIN
DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_over3month_per where kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	IF @wk_datacount > 0
	BEGIN
	DELETE FROM kcsd.kc_over3month_per WHERE  kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	END
				Insert into kcsd.kc_over3month_per
			SELECT kc_buy_date,kc_prod_type,kc_area_code,ISNULL(SUM(kc_badcase_payfee),0) as kc_badcase_payfee , SUM(kc_expt_fee) as kc_expt_fee,GETDATE() as kc_updt_date 				 
				FROM #tmp_over3month 
         	group by kc_prod_type,kc_area_code,kc_buy_date
END
ELSE
BEGIN
			SELECT kc_buy_date,kc_prod_type,kc_area_code,ISNULL(SUM(kc_badcase_payfee),0) as kc_badcase_payfee , SUM(kc_expt_fee) as kc_expt_fee,GETDATE() as kc_updt_date 				 
				FROM #tmp_over3month 
         	group by kc_prod_type,kc_area_code,kc_buy_date
END


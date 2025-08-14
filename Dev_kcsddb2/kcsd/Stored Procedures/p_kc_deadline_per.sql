-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_deadline_per] @pm_strt_date DATETIME=NULL ,@pm_stop_date DATETIME=NULL ,@pm_stop_date2 DATETIME=NULL    ,@pm_run_code varchar(10)=NULL
AS

CREATE TABLE #tmp_deadline
(
kc_case_no		varchar(7),
kc_area_code	varchar(2),
kc_prod_type	varchar(2),
kc_buy_date		varchar(6),
kc_expt_sum		int,
kc_pay_amt		int,
)

INSERT #tmp_deadline
SELECT
A.kc_case_no,A.kc_area_code,A.kc_prod_type,  convert(varchar(6),@pm_stop_date2,112),
SUM(ISNULL(e.wk_expt_sum,0)) AS kc_expt_sum,
SUM(ISNULL(d.wk_pay_amt,0)) AS kc_pay_amt
FROM kcsd.kc_customerloan A
LEFT JOIN (
SELECT kc_case_no, Sum(kc_pay_fee) - Sum(kc_intr_fee) as wk_pay_amt
	FROM kcsd.kc_loanpayment
	WHERE kc_pay_date <= @pm_stop_date2 and kc_expt_date <= @pm_stop_date2
	GROUP BY kc_case_no
	) d ON A.kc_case_no = d.kc_case_no
LEFT JOIN (
SELECT kc_case_no, Sum(kc_expt_fee) AS wk_expt_sum
	FROM kcsd.kc_loanpayment
	WHERE kc_expt_date <= @pm_stop_date2
	and kc_perd_no < 50
	GROUP BY kc_case_no
	) e ON A.kc_case_no = e.kc_case_no
WHERE kc_loan_stat Not In ('Y','Z') 
AND A.kc_buy_date Between @pm_strt_date And @pm_stop_date
GROUP BY A.kc_case_no,A.kc_area_code,A.kc_prod_type,A.kc_buy_date

IF	@pm_run_code = 'EXECUTE'
BEGIN
DECLARE @wk_datacount int
	SELECT @wk_datacount = count(*) from kcsd.kc_deadline_per where kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	IF @wk_datacount > 0
	BEGIN
	DELETE FROM kcsd.kc_deadline_per WHERE  kc_buy_date = convert(varchar(6),@pm_stop_date2,112)
	END
					Insert into kcsd.kc_deadline_per
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_expt_sum) as kc_expt_sum,sum(kc_pay_amt) as kc_pay_amt,GETDATE() as kc_updt_date 
			from (
					SELECT kc_buy_date, kc_area_code , kc_prod_type ,sum(kc_expt_sum) AS kc_expt_sum ,sum(kc_pay_amt) AS kc_pay_amt
							FROM #tmp_deadline s
							group by kc_buy_date, kc_area_code , kc_prod_type 
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
END
ELSE
BEGIN
			SELECT kc_buy_date,kc_area_code,kc_prod_type,sum(kc_expt_sum) as kc_expt_sum,sum(kc_pay_amt) as kc_pay_amt,GETDATE() as kc_updt_date 
			from (
					SELECT kc_buy_date, kc_area_code , kc_prod_type ,sum(kc_expt_sum) AS kc_expt_sum ,sum(kc_pay_amt) AS kc_pay_amt
							FROM #tmp_deadline s
							group by kc_buy_date, kc_area_code , kc_prod_type 
							) as ss
			group by kc_buy_date,kc_area_code,kc_prod_type
END


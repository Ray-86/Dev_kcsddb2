


-- ==========================================================================================

-- ==========================================================================================

CREATE   PROCEDURE [kcsd].[p_kc_index3012]	@pm_strt_date datetime = '2003-05-01', @pm_stop_date datetime = NULL, @pm_strt_date2 datetime = '2003-05-01', @pm_stop_date2 datetime = NULL, @wk_issu_code varchar(2) = NULL, @IsShowkc_law_fmt varchar(5) = NULL
AS

DECLARE @tmp_debtage TABLE 
(	kc_case_no	varchar(10),
	kc_expt_sum	int,			/* 逾期金額 */
	kc_arec_amt	int,			/* 未繳金額 */
	kc_dday_count	int			/* 逾期月數 */
)

INSERT INTO @tmp_debtage EXEC kcsd.p_kc_debtage @pm_stop_date

SELECT @pm_strt_date = '2003-05-01'
SELECT @pm_strt_date2 = '2003-05-01'

SELECT kc_customerloan.kc_case_no, kc_cust_nameu, kc_customerloan.kc_area_code, kc_issu_code, kc_loan_perd, kc_perd_fee,
FORMAT(kc_buy_date,'yyMM') AS wk_perd_yymm, kc_buy_date, tmp_debtage.kc_dday_count, tmp_debtage.kc_expt_sum AS kc_over_amt, tmp_debtage.kc_arec_amt
FROM kcsd.kc_customerloan
INNER JOIN @tmp_debtage AS tmp_debtage ON kc_customerloan.kc_case_no = tmp_debtage.kc_case_no
WHERE (LEFT(kc_customerloan.kc_case_no,1) = 'T' OR LEFT(kc_customerloan.kc_case_no,1) BETWEEN '0' AND '5')
AND tmp_debtage.kc_dday_count >= 6
AND kc_buy_date BETWEEN @pm_strt_date2 AND @pm_stop_date2
AND kc_issu_code = @wk_issu_code
and (@wk_issu_code <> '06' or (@wk_issu_code = '06' and kc_prod_type <> '04'))
AND kc_loan_stat not in ('X','Y')
AND ((kc_idle_date IS NULL) OR (kc_idle_date IS NOT NULL AND kc_idle_date NOT BETWEEN @pm_strt_date2 AND @pm_stop_date2))
AND not exists (select * from kcsd.kc_lawstatus  
where case @IsShowkc_law_fmt when 'true' then kc_case_no else '' end = kc_customerloan.kc_case_no and (kc_law_fmt = 'C6' OR kc_law_fmt = 'XA'))

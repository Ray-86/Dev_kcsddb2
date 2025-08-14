CREATE   PROCEDURE [kcsd].[p_kc_profitexercise]
@pm_strt_date datetime,
@pm_stop_date datetime
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_area_code	varchar(6),
	@wk_pay_date	datetime,
	@wk_cust_name	varchar(30),
	@wk_expt_total	int,		/* 全部應收 */
	@wk_perd_pay	int,		/* 當期收款 */
	@wk_total_pay	int,		/* 累計收款 */
	@wk_loan_perd	int,
	@wk_perd_fee	int,

	@wk_loan_cost	int,		/* 分期成本 */
	@wk_exer_amt	int,
	@wk_unexer_amt	int

SELECT	@wk_case_no=NULL, @wk_area_code=NULL,
	@wk_pay_date=NULL, @wk_cust_name=NULL,
	@wk_expt_total=0, @wk_loan_perd=0, @wk_perd_fee=0,
	@wk_exer_amt=0, @wk_unexer_amt=0

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_pay_date, kc_case_no
	FROM	kcsd.kc_loanpayment
	WHERE	kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	GROUP BY kc_pay_date, kc_case_no
	ORDER BY kc_pay_date, kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_pay_date, @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_area_code=NULL, @wk_cust_name=NULL,
		@wk_expt_total=0, @wk_loan_perd=0, @wk_perd_fee=0,
		@wk_exer_amt=0, @wk_unexer_amt=0

	/* get Info */
	SELECT	@wk_cust_name = kc_cust_name, @wk_area_code = kc_area_code,
		@wk_loan_perd = kc_loan_perd, @wk_perd_fee = kc_perd_fee
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* 計算當期收款 */
	SELECT	@wk_perd_pay = SUM(ISNULL(kc_pay_fee, 0)-ISNULL(kc_intr_fee, 0))
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = @wk_pay_date
	
	/* 累計收款 */
	SELECT	@wk_total_pay = SUM(ISNULL(kc_pay_fee, 0)-ISNULL(kc_intr_fee, 0))
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date <= @wk_pay_date

	/* 全部應收 */
	SELECT	@wk_expt_total = @wk_loan_perd * @wk_perd_fee

	/* 分期成本 */
	EXECUTE	kcsd.p_kc_profitexercise_sub1 @wk_case_no, @wk_loan_cost OUTPUT

	SELECT	@wk_pay_date, @wk_case_no

	FETCH NEXT FROM cursor_case_no INTO @wk_pay_date, @wk_case_no
END

DEALLOCATE	cursor_case_no

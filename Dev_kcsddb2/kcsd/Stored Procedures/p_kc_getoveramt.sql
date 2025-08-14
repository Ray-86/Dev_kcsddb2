/* 計算在 due_date前(不含) 的應繳金額 */
CREATE    PROCEDURE [kcsd].[p_kc_getoveramt] 
	@pm_case_no varchar(10)=NULL,
	@pm_due_date datetime=NULL,
	@pm_over_amt int OUTPUT,
	@pm_arec_amt int OUTPUT,	/* 到最後一期的所有未繳 */
	@pm_dday_date datetime OUTPUT
AS
DECLARE	@wk_expt_amt	int,
	@wk_pay_sum	int,
	@wk_exptall_amt	int		/* 每期應繳總和(不管已繳未繳) */

SELECT	@pm_over_amt = 0, @pm_arec_amt = 0,
	@wk_expt_amt = 0, @wk_pay_sum = 0,
	@pm_dday_date = NULL

/* 計算應繳金額 */
SELECT	@wk_expt_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date < @pm_due_date
AND	kc_perd_no < 50

/* 計算已回收金額, 條件: 繳款日在區間前 */
SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_pay_date < @pm_due_date

/* 委託金額 = 應收 - 已收 */
SELECT	@pm_over_amt = @wk_expt_amt - @wk_pay_sum

/* 溢繳, 設為0 */
IF	@pm_over_amt <= 0
	SELECT	@pm_over_amt = 0
ELSE
	SELECT	@pm_dday_date = MIN(kc_expt_date)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @pm_case_no
	AND	(	kc_pay_date >= @pm_due_date
		OR	kc_pay_date IS NULL)

/* 計算到最後一期的未繳(不管是否到期) */
/* 計算所有應繳金額 */
SELECT	@wk_exptall_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_perd_no < 50

SELECT	@pm_arec_amt = @wk_exptall_amt - @wk_pay_sum
IF	@pm_arec_amt < 0
	SELECT	@pm_arec_amt = 0

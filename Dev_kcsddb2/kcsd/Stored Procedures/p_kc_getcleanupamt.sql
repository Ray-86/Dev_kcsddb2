CREATE    PROCEDURE [kcsd].[p_kc_getcleanupamt]
	@pm_case_no varchar(10)=NULL,
	@pm_due_date datetime=NULL
AS
DECLARE	@wk_over_amt	int,			/* 逾期金額 */
	@wk_under_amt	int,			/* 未逾期金額(但未繳) */
	@wk_arec_amt	int,			/* 未繳金額 = over_amt + under_amt */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */

	@wk_perd_fee	int,			/* 每期金額 */
	@wk_break_amt	int,			/* Total違約金 */
	@wk_break_amt_m	int,			/* 每月違約金 */
	@wk_dday_count	int,			/* 逾期月數 */
	@wk_over_count	int			/* 逾期期數 */

/* 取得基本資料 */
SELECT	@wk_perd_fee = kc_perd_fee
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

EXECUTE	kcsd.p_kc_getoveramt @pm_case_no, @pm_due_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

/* SELECT	@pm_due_date, @wk_over_amt, @wk_arec_amt, @wk_dday_date */

SELECT	@wk_under_amt = @wk_arec_amt - @wk_over_amt,
	@wk_dday_count = DATEDIFF(day,ISNULL(@wk_dday_date, @pm_due_date), @pm_due_date) / 30


/* 計算實際逾期期數, delay 天數, 及金額 */
SELECT	@wk_over_count=COUNT(kc_case_no)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date < @pm_due_date
AND	(kc_pay_date IS NULL OR (kc_pay_date IS NOT NULL AND kc_pay_date > @pm_due_date))

/* 違約金1的算法, 已停用
SELECT	@wk_break_amt_m = ROUND(@wk_perd_fee*0.02,0)
SELECT	@wk_break_amt = @wk_break_amt_m*(@wk_dday_count+@wk_dday_count-@wk_over_count+1)*@wk_over_count/2.0
*/
/* 違約金2 */
EXECUTE	kcsd.p_kc_updateloanstatus_sub1 @pm_case_no, @wk_break_amt OUTPUT, @pm_due_date

SELECT	@wk_over_amt AS kc_over_amt,  @wk_over_count AS kc_over_count,
	@wk_under_amt AS kc_under_amt, @wk_break_amt AS kc_break_amt

/* ¡p║Ô╣H¼¨¬¸ */
/* 12/06/2004 KC: 修改以供updateloanstatus及getcleanupamt共用 */
CREATE   PROCEDURE [kcsd].[p_kc_updateloanstatus_sub1]
	@pm_case_no	varchar(10),
	@pm_break_amt	int OUTPUT,
	@pm_due_date	datetime=NULL
AS

DECLARE	@wk_break_fee1	int,
	@wk_break_fee2	int

IF	@pm_due_date IS NULL
	SELECT	@pm_due_date = GETDATE()

/* Ñ╝├║ */
SELECT	@wk_break_fee1 = ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, @pm_due_date) )/1000.0, 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_pay_date IS NULL
AND	kc_expt_date < @pm_due_date
AND	kc_expt_fee > 0

/* ñw├║ª²╣H¼¨ */
SELECT	@wk_break_fee2 = ROUND(SUM(kc_expt_fee*DATEDIFF(day,kc_expt_date, kc_pay_date) )/1000.0, 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_pay_date IS NOT NULL
AND	kc_expt_date < kc_pay_date
AND	kc_expt_fee > 0

SELECT	@pm_break_amt = ISNULL(@wk_break_fee1,0) + ISNULL(@wk_break_fee2, 0)

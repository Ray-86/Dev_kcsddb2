CREATE PROCEDURE [kcsd].[p_kc_getlastperiod]
@pm_case_no varchar(10),
@pm_perd_no int,
@pm_last_perdno int OUTPUT
AS

DECLARE	@wk_expt_date	datetime,
	@wk_expt_date1	datetime

SELECT	@pm_last_perdno = 0

IF	@pm_perd_no = 1
	RETURN 

/* get info */
SELECT	@wk_expt_date = kc_expt_date
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_perd_no = @pm_perd_no

/* get period */
/* first get same expt date */
SELECT	@pm_last_perdno = ISNULL( MAX(kc_perd_no), 0)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date = @wk_expt_date
AND	kc_perd_no < @pm_perd_no

IF	@pm_last_perdno <> 0		/* got answer and quit */
	RETURN

/* different expt date */
SELECT	@wk_expt_date1 = MAX(kc_expt_date)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date < @wk_expt_date

SELECT	@pm_last_perdno = MAX(kc_perd_no)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date = @wk_expt_date1

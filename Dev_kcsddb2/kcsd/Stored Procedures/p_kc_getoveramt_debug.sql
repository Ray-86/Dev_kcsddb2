CREATE  PROCEDURE [kcsd].[p_kc_getoveramt_debug] @pm_case_no varchar(10)=NULL
AS
DECLARE	@wk_end_date	datetime,		/* 計算截止時間 */
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 */
	@wk_dday_date	datetime		/* dummy for p_kc_getoveramt */

IF	@pm_case_no IS NULL
	RETURN

SELECT	@wk_end_date = GETDATE(), @wk_over_amt = 0, @wk_arec_amt = 0, @wk_dday_date = NULL

EXECUTE	kcsd.p_kc_getoveramt @pm_case_no, @wk_end_date, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT

SELECT	@pm_case_no, @wk_over_amt, @wk_arec_amt

CREATE PROCEDURE [kcsd].[p_kc_pvperiod_bak]
@pm_case_no varchar(10), @pm_perd_no int,
@pm_pv_amt int OUTPUT,
@pm_invo_amt int OUTPUT,
@pm_pvpay_amt int OUTPUT,
@pm_invo_rema int=0 OUTPUT
AS

DECLARE	@wk_expt_fee	int,
	@wk_perd_fee	int,
	@wk_pay_fee	int,
	@wk_intr_rate	real,
	@wk_pvall_amt	int,

	@wk_pv_last	int,
	@wk_pvpay_last	int,
	@wk_prev_no	int,
	@wk_pinvo_rema	int,

	@wk_expt_date	datetime,
	@wk_expt_mxdate	datetime,	/* max expt date */
	@wk_expt_mxperd int		/* max perd no */

/* init */
SELECT	@pm_pv_amt = 0, @pm_invo_amt = 0, @pm_pvpay_amt = 0, @pm_invo_rema = 0

SELECT	@wk_expt_fee = 0,  @wk_pay_fee = 0,
	@wk_intr_rate = 0, @wk_pvall_amt = 0,  @wk_prev_no = 0,
	@wk_pinvo_rema = 0,
	@wk_expt_date = NULL, @wk_expt_mxdate = NULL,
	@wk_perd_fee =0

/* get loan info */
SELECT	@wk_pvall_amt = kc_pvall_amt, @wk_perd_fee = kc_perd_fee
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

SELECT	@wk_intr_rate = t.kc_loan_rate
FROM	kcsd.kc_customerloan c, kcsd.kc_loantype t
WHERE	c.kc_loan_type = t.kc_loan_type

SELECT	@wk_expt_date = kc_expt_date, @wk_expt_fee = kc_expt_fee,
	@wk_pay_fee = kc_pay_fee
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_perd_no = @pm_perd_no

/* 抓上期繳款資料 */
IF	@pm_perd_no = 1
	SELECT	@wk_pv_last = @wk_pvall_amt, @wk_pvpay_last = 0
ELSE
BEGIN
	EXECUTE kcsd.p_kc_getlastperiod @pm_case_no, @pm_perd_no, @wk_prev_no OUTPUT
	
	SELECT	@wk_pv_last = kc_pv_amt, @wk_pvpay_last = kc_pvpay_amt,
		@wk_pinvo_rema = kc_invo_rema
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @pm_case_no
	AND	kc_perd_no = @wk_prev_no
END

/* start Calc */
SELECT	@pm_pv_amt = @wk_pv_last - @wk_pvpay_last

IF	@pm_perd_no < 50
	SELECT	@pm_invo_amt = ROUND(@pm_pv_amt * @wk_intr_rate / 1200.0, 0)
ELSE
	SELECT	@pm_invo_amt = @wk_pinvo_rema	/* 上期利息餘額 */

IF	@wk_pay_fee >= @wk_expt_fee		/* 足額 */
	SELECT	@pm_pvpay_amt = @wk_expt_fee - @pm_invo_amt
ELSE
BEGIN
	IF	@wk_pay_fee >= @pm_invo_amt	/* 還全部利息部分本金 */
		SELECT	@pm_pvpay_amt = @wk_pay_fee - @pm_invo_amt
	ELSE
	BEGIN					/* 繳款不足利息, 先還息 */
		SELECT	@pm_invo_rema = @pm_invo_amt - @wk_pay_fee
		SELECT	@pm_invo_amt = @wk_pay_fee, @pm_pvpay_amt = 0
	END
END


/* 判斷是否為最後一期 */
SELECT	@wk_expt_mxdate = MAX(kc_expt_date)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no

SELECT	@wk_expt_mxperd = MAX(kc_perd_no)
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_expt_date = @wk_expt_mxdate

IF	@pm_perd_no = @wk_expt_mxperd	/* 最後一期利息算法不同 */
BEGIN
	SELECT	@pm_pvpay_amt = @pm_pv_amt, @pm_invo_amt = @wk_perd_fee - @pm_pv_amt
END

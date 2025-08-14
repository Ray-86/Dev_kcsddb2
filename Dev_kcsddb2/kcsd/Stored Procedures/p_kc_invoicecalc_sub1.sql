/*
==========================================================================================
2018-08-24 計算勞務發票 (大於成本才開立)
==========================================================================================
*/

CREATE	PROCEDURE [kcsd].[p_kc_invoicecalc_sub1] @pm_case_no varchar(10), @pm_perd_no int,@pm_invo_amt2 int OUTPUT,@wk_pvpay_amt2 int OUTPUT
AS

DECLARE	@wk_case_no	varchar(10),
		@wk_perd_no	int,
		@wk_loan_fee int,
		@wk_pay_fee int,
		@wk_pay_sum int,
		@wk_invo_amt2 int

	SELECT @wk_loan_fee = kc_loan_fee from kcsd.kc_customerloan where kc_case_no = @pm_case_no
	SELECT @wk_pay_sum = 0,@pm_invo_amt2 = 0

	DECLARE	cursor_case_no	CURSOR
		FOR	SELECT	p.kc_case_no, p.kc_perd_no, p.kc_pay_fee, p.kc_invo_amt2
		FROM	kcsd.kc_loanpayment p,kcsd.kc_customerloan c
		WHERE	p.kc_case_no = c.kc_case_no
		AND c.kc_case_no = @pm_case_no
		ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no
	OPEN cursor_case_no
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no, @wk_pay_fee, @wk_invo_amt2
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @wk_pay_sum  = @wk_pay_sum + @wk_pay_fee --繳款合計金額
		IF (@wk_perd_no = @pm_perd_no) BREAK
		SELECT @pm_invo_amt2  = @pm_invo_amt2 + @wk_invo_amt2 --之前已開立金額

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no, @wk_pay_fee, @wk_invo_amt2
	END
	DEALLOCATE	cursor_case_no
	
	--計算本期應開金額
	IF ((@wk_pay_sum - @wk_loan_fee - @pm_invo_amt2)>0)
	SELECT @pm_invo_amt2 = @wk_pay_sum - @wk_loan_fee - @pm_invo_amt2
		ELSE
	SELECT @pm_invo_amt2 = 0
	SELECT @wk_pvpay_amt2 = @wk_pay_fee - @pm_invo_amt2
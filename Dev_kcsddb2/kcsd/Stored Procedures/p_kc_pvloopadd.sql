CREATE                PROCEDURE [kcsd].[p_kc_pvloopadd]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_perd_no	int,

	@wk_pv_amt	int,
	@wk_invo_amt	int,
	@wk_pvpay_amt	int,
	@wk_invo_rema	int,
	@wk_proc_amt	int,
	@wk_proc_rema	int,
	@wk_oinvo_amt	int

SELECT	@wk_case_no=NULL, @wk_perd_no=0,
	@wk_pv_amt=0, @wk_invo_amt=0, @wk_pvpay_amt=0

DECLARE	cursor_case_no	CURSOR
FOR	/* Mode 1: 由 tmppv 指定case_no, perd_no */
	/*
	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_tmpnopv p
	ORDER BY p.kc_case_no, p.kc_perd_no */

	/* Mode 2: 由kc_tmpnopv 的 caseno, 從第一期開始算 */
	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
	WHERE	p.kc_case_no = c.kc_case_no
	AND	p.kc_pay_fee IS NOT NULL
	AND	p.kc_pay_fee <> 0
	AND	p.kc_case_no BETWEEN '0' AND '5'
	AND	(p.kc_case_no in
		(SELECT kc_case_no FROM kcsd.kc_tmpnopv))
	ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no

	/* Mode 3: 由kc_tmpnopv中,  付款日大於 tmpnov.expt_date的每期 */
	/*
	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_loanpayment p, kcsd.kc_tmpnopv t
	WHERE	p.kc_case_no = t.kc_case_no
	AND	p.kc_pay_fee IS NOT NULL
	AND	p.kc_pay_fee <> 0
	AND	p.kc_case_no BETWEEN '0' AND '5'
	AND	p.kc_pay_date >= t.kc_expt_date
	ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no */

	/* Mode 4: from 2, 所有 caseno, 從第一期開始算 */
	/*
	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
	WHERE	p.kc_case_no = c.kc_case_no
	AND	p.kc_pay_fee IS NOT NULL
	AND	p.kc_pay_fee <> 0
	AND	p.kc_case_no BETWEEN '0' AND '5'
	ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no */


OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_case_no, @wk_perd_no

	EXECUTE	kcsd.p_kc_pvperiod @wk_case_no, @wk_perd_no,
		@wk_pv_amt OUTPUT, @wk_invo_amt OUTPUT, @wk_pvpay_amt OUTPUT, @wk_invo_rema OUTPUT,
		@wk_proc_amt OUTPUT, @wk_proc_rema OUTPUT, @wk_oinvo_amt OUTPUT


	UPDATE	kcsd.kc_loanpayment
	SET	kc_pv_amt2 = @wk_pv_amt, kc_invo_amt2 = @wk_invo_amt,
		kc_pvpay_amt2 = @wk_pvpay_amt, kc_invo_rema2 = @wk_invo_rema,
		kc_proc_amt2 = @wk_proc_amt, kc_proc_rema2 = @wk_proc_rema,
		kc_oinvo_amt = @wk_oinvo_amt
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no


/* show */
/*SELECT	@wk_case_no, @wk_perd_no, @wk_pv_amt, @wk_invo_amt, @wk_pvpay_amt, @wk_invo_rema,
	@wk_proc_amt, @wk_proc_rema
*/

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_perd_no
END

DEALLOCATE	cursor_case_no

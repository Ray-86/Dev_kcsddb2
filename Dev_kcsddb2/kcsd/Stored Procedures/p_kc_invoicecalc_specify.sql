-- ==========================================================================================
-- 07/11/09 add to run specified case, strt_time, end_time
/* 計算指定case no 的發票金額
Param: Runcode
Data: kc_tmpnopv (kc_case_no, kc_perd_no)
Output: Write or Display
 */
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_invoicecalc_specify]
	@pm_run_code varchar(10)=NULL,
	@pm_strt_date datetime=NULL,
	@pm_stop_date datetime=NULL,
	@pm_case_no varchar(10)=NULL
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

SELECT	@wk_case_no = NULL, @wk_perd_no = NULL

/*
DECLARE	cursor_invocalc	CURSOR
FOR	SELECT	kc_case_no, kc_perd_no
	FROM	kcsd.kc_tmpnopv
	ORDER BY kc_case_no, kc_perd_no */

DECLARE	cursor_invocalc	CURSOR
FOR	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
	WHERE	p.kc_case_no = c.kc_case_no
	AND	p.kc_pay_fee IS NOT NULL
	AND	p.kc_pay_fee > 0
	--AND	p.kc_case_no BETWEEN '0' AND '5'
	AND	p.kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	(c.kc_issu_code IS NULL	-- 05/17/2009 東元資融 only
		OR c.kc_issu_code = '01' OR c.kc_issu_code = '03') -- 2016/08/18 東元車業
	AND	c.kc_case_no = @pm_case_no
	ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no

OPEN cursor_invocalc
FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	--SELECT	@wk_case_no, @wk_perd_no	
	
	IF	@pm_run_code = 'EXECUTE'
	BEGIN
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
	END
	ELSE	/* TEST */
		EXECUTE	kcsd.p_kc_pvperiod_debug @wk_case_no, @wk_perd_no

	FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no
END

DEALLOCATE	cursor_invocalc

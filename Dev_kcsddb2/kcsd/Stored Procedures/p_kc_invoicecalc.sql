-- ==========================================================================================
-- 2017-11-09 kc_pay_date 改 kc_invo_date
-- 05/17/2009 KC: 限制只有issu_code 東元資融01 (or NULL)才執行
-- 2016/08/18 更改issu_code為01 03
-- ==========================================================================================
CREATE      PROCEDURE [kcsd].[p_kc_invoicecalc]
	@pm_strt_date datetime=NULL,
	@pm_stop_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_perd_no	int,

	@wk_pv_amt	int,
	@wk_invo_amt	int,
	@wk_pvpay_amt	int,
	@wk_invo_rema	int,
	@wk_proc_amt	int,
	@wk_proc_rema	int,
	@wk_oinvo_amt	int,
	@wk_edit_date	datetime

SELECT	@wk_case_no = NULL, @wk_perd_no = NULL

SELECT	@wk_edit_date =	CONVERT(char(2), DATEPART(month, GETDATE())) +  '/' +
			CONVERT(char(2), DATEPART(day, GETDATE())) + '/' +
			CONVERT(char(4), DATEPART(year, GETDATE()))

CREATE TABLE #tmp_invoicecalc
(
kc_case_no	varchar(10),
kc_perd_no	int
)

DECLARE	cursor_invocalc	CURSOR
FOR	SELECT	p.kc_case_no, p.kc_perd_no
	FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
	WHERE	
	p.kc_case_no = c.kc_case_no
	AND	(((c.kc_issu_code IS NULL OR c.kc_issu_code = '01') AND c.kc_case_no BETWEEN '0' AND '5') 
	OR (c.kc_issu_code = '03' AND c.kc_case_no LIKE 'T%'))
	AND	p.kc_invo_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	p.kc_pay_fee IS NOT NULL
	AND	p.kc_pay_fee > 0
	ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no

OPEN cursor_invocalc
FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no


WHILE (@@FETCH_STATUS = 0)
BEGIN

/*	SELECT	@wk_case_no, @wk_perd_no

	INSERT	#tmp_invoicecalc
		(kc_case_no, kc_perd_no)
	VALUES	(@wk_case_no, @wk_perd_no)
*/
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

	FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no
END

DEALLOCATE	cursor_invocalc
/*
SELECT	*
FROM	#tmp_invoicecalc
*/

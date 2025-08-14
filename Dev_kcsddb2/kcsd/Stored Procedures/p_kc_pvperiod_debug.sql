CREATE  PROCEDURE [kcsd].[p_kc_pvperiod_debug] @pm_case_no varchar(10), @pm_perd_no int
AS
DECLARE	@wk_pv_amt	int,
	@wk_invo_amt	int,
	@wk_pvpay_amt	int,
	@wk_invo_rema	int,
	@wk_proc_amt	int,
	@wk_proc_rema	int,
	@wk_oinvo_amt	int

EXECUTE	kcsd.p_kc_pvperiod @pm_case_no, @pm_perd_no,
	@wk_pv_amt OUTPUT, @wk_invo_amt OUTPUT, @wk_pvpay_amt OUTPUT, @wk_invo_rema OUTPUT,
	@wk_proc_amt OUTPUT, @wk_proc_rema OUTPUT, @wk_oinvo_amt OUTPUT

SELECT	@pm_case_no, @pm_perd_no, @wk_pv_amt AS pv_amt, @wk_invo_amt AS invo_amt, @wk_pvpay_amt AS pvpay_amt,
	@wk_invo_rema as invo_rema,
	@wk_proc_amt AS proc_amt, @wk_proc_rema AS proc_rema, @wk_oinvo_amt AS oinvo_amt

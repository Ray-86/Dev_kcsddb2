-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [kcsd].[p_kc_invoicecalc_Inquire]  @pm_case_no varchar(10)=NULL , @wk_perd_no	int =NULL

AS
DECLARE	

	@wk_pv_amt2	int,
	@wk_invo_amt2	int,	--利息收入
	@wk_pvpay_amt2	int,	--還本數
	@wk_invo_rema2	int,
	@wk_proc_amt2	int,	--手續費收入
	@wk_proc_rema2	int,
	@wk_oinvo_amt	int,	--溢開發票
	@wk_prod_type varchar(2)



		--計算PV發票開立金額
		EXECUTE	kcsd.p_kc_pvperiod @pm_case_no, @wk_perd_no,@wk_pv_amt2 OUTPUT, @wk_invo_amt2 OUTPUT, @wk_pvpay_amt2 OUTPUT, @wk_invo_rema2 OUTPUT,@wk_proc_amt2 OUTPUT, @wk_proc_rema2 OUTPUT, @wk_oinvo_amt OUTPUT


		select @pm_case_no kc_case_no, @wk_perd_no kc_perd_no,@wk_pv_amt2 kc_pv_amt2, @wk_invo_amt2 kc_invo_amt2, @wk_pvpay_amt2 kc_pvpay_amt2, 
		
		@wk_invo_rema2 kc_invo_rema2,@wk_proc_amt2 kc_proc_amt2, @wk_proc_rema2 kc_proc_rema2, @wk_oinvo_amt kc_oinvo_amt 



-- ==========================================================================================
-- 2018-08-24 增加勞務發票計算
-- 2017-05-19 增加kc_invo_flag,增加@pm_issu_code
-- 2016-08-18 更改issu_code為01 03
-- 2009-05-17 KC: 限制只有issu_code 東元資融01 (or NULL)才執行
-- ==========================================================================================
CREATE      PROCEDURE [kcsd].[p_kc_invoicecalc_new] @pm_strt_date datetime=NULL, @pm_issu_code varchar(2)=NULL, @pm_case_no varchar(10)=NULL

AS
DECLARE	@wk_case_no	varchar(10),
	@wk_perd_no	int,
	@wk_pv_amt2	int,
	@wk_invo_amt2	int,	--利息收入
	@wk_pvpay_amt2	int,	--還本數
	@wk_invo_rema2	int,
	@wk_proc_amt2	int,	--手續費收入
	@wk_proc_rema2	int,
	@wk_oinvo_amt	int,	--溢開發票
	@wk_prod_type varchar(2)

SELECT	@wk_case_no = NULL, @wk_perd_no = NULL

CREATE TABLE #tmp_invoicecalc
(
kc_case_no	varchar(10),
kc_perd_no	int
)

IF	@pm_case_no IS NULL
	DECLARE	cursor_invocalc	CURSOR
	FOR	SELECT	p.kc_case_no, p.kc_perd_no,c.kc_prod_type
		FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
		WHERE	
		p.kc_case_no = c.kc_case_no 

		AND ((p.kc_case_no BETWEEN '0' AND '5' OR p.kc_case_no LIKE 'T%' OR p.kc_case_no LIKE 'A%' OR p.kc_case_no LIKE 'B%') 
		or (kc_buy_date >= '2024-07-01' and c.kc_issu_code in ('02','05','06') and kc_prod_type = '04'))



		AND	p.kc_invo_date = @pm_strt_date --and kc_pay_date >= '2017-09-01'
		AND	p.kc_pay_fee IS NOT NULL
		AND	(p.kc_pay_fee > 0 or kc_break_fee >0)
		AND p.kc_invo_flag is null
		ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no
ELSE	-- 單件計算 kc_case_no
	DECLARE	cursor_invocalc	CURSOR
	FOR	SELECT	p.kc_case_no, p.kc_perd_no,c.kc_prod_type
		FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
		WHERE	
		p.kc_case_no = c.kc_case_no
		AND c.kc_issu_code = @pm_issu_code
		AND c.kc_case_no = @pm_case_no
		AND (p.kc_case_no BETWEEN '0' AND '5' OR p.kc_case_no LIKE 'T%' OR p.kc_case_no LIKE 'A%' OR p.kc_case_no LIKE 'B%')
		AND	p.kc_invo_date = @pm_strt_date --and kc_pay_date >= '2017-09-01'
		AND	p.kc_pay_fee IS NOT NULL
		AND	(p.kc_pay_fee > 0 or kc_break_fee >0)
		ORDER BY p.kc_case_no, p.kc_expt_date, p.kc_perd_no

OPEN cursor_invocalc
FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no, @wk_prod_type

WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF @wk_prod_type = '08' --勞務
	BEGIN
		--計算勞務發票開立金額
		EXEC kcsd.p_kc_invoicecalc_sub1 @wk_case_no,@wk_perd_no,@wk_invo_amt2 OUTPUT,@wk_pvpay_amt2 OUTPUT

		UPDATE	kcsd.kc_loanpayment SET	kc_invo_amt2 = @wk_invo_amt2,kc_pvpay_amt2 = @wk_pvpay_amt2,kc_invo_flag = 'N'
		WHERE kc_case_no = @wk_case_no AND kc_perd_no = @wk_perd_no
	END
	ELSE
	BEGIN
		--計算PV發票開立金額
		EXECUTE	kcsd.p_kc_pvperiod @wk_case_no, @wk_perd_no,@wk_pv_amt2 OUTPUT, @wk_invo_amt2 OUTPUT, @wk_pvpay_amt2 OUTPUT, @wk_invo_rema2 OUTPUT,@wk_proc_amt2 OUTPUT, @wk_proc_rema2 OUTPUT, @wk_oinvo_amt OUTPUT

		UPDATE	kcsd.kc_loanpayment
		SET	kc_pv_amt2 = @wk_pv_amt2, kc_invo_amt2 = @wk_invo_amt2,
			kc_pvpay_amt2 = @wk_pvpay_amt2, kc_invo_rema2 = @wk_invo_rema2,
			kc_proc_amt2 = @wk_proc_amt2, kc_proc_rema2 = @wk_proc_rema2,
			kc_oinvo_amt = @wk_oinvo_amt,kc_invo_flag = 'N'
		WHERE	kc_case_no = @wk_case_no
		AND	kc_perd_no = @wk_perd_no
	END
	FETCH NEXT FROM cursor_invocalc INTO @wk_case_no, @wk_perd_no, @wk_prod_type
END

DEALLOCATE	cursor_invocalc
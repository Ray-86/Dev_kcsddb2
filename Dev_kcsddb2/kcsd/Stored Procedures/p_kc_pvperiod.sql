/*
-- ==========================================================================================
07/11/09 修正保費溢開發票, 作法: 手續費減溢開保費(最後一期不管)
05/03/08: 溢開發票不再計算,直接設為0 (oinvo_amt)
03/06/08: 利率計算改抓每個 case 的 kc_intr_rate (原:動態查kc_loantype)
Policy 1: PV, 有溢開發票
Policy 2: PV, 無溢開發票
6/25/2005 KC: Policy 3: 5/1/2005起當期分期款未繳足全額者,先還本金
		繳足者計算不變*/
-- ==========================================================================================

CREATE                  PROCEDURE [kcsd].[p_kc_pvperiod]
@pm_case_no varchar(10), @pm_perd_no int,
@pm_pv_amt int OUTPUT,
@pm_invo_amt int OUTPUT,
@pm_pvpay_amt int OUTPUT,
@pm_invo_rema int=0 OUTPUT,
@pm_proc_amt int=0 OUTPUT,
@pm_proc_rema int=0 OUTPUT,
@pm_oinvo_amt int=0 OUTPUT
AS

DECLARE	@wk_expt_fee	int,
	@wk_perd_fee	int,
	@wk_pay_fee	int,
	@wk_intr_rate	real,
	@wk_pvall_amt	int,
--	@wk_oinvo_last	int,		/* 前期溢開票金額 */
	@wk_buy_date	datetime,
--	@wk_pvnew_flag	int,		/* buy_date>=7/1/2003 採新pv算法 */
	@wk_loan_perd	int,
	@wk_intr_fee	int,
	@wk_lsum_last	int,		/* 前期小計 */

	@wk_pv_last	int,
	@wk_pvpay_last	int,
	@wk_prev_no	int,
	@wk_pinvo_rema	int,
	@wk_prall_amt	int,		/* 手續費總額 */
	@wk_proc_sum	int,		/* 已繳手續費總和 */
	@wk_proc_last	int,		/* 前期手續費 */
	@wk_pproc_rema	int,		/* 前期手續費餘額 */

	@wk_expt_date	datetime,
	@wk_expt_mxdate	datetime,	/* max expt date */
	@wk_expt_mxperd int,		/* max perd no */

	@wk_avail_amt	int,

	@wk_invo_last	int,		/* 前期利息 */
	@wk_intr_last	int,		/* 前期折扣 */

	@wk_pvpay_amt	int,		/* 當期應還本金 */
	@wk_over_insu	int		-- 溢繳手續費

/* init */
SELECT	@pm_pv_amt = 0, @pm_invo_amt = 0, @pm_pvpay_amt = 0, @pm_invo_rema = 0,
	@pm_proc_amt = 0, @pm_proc_rema = 0, @pm_oinvo_amt = 0

SELECT	@wk_expt_fee = 0,  @wk_pay_fee = 0,
	@wk_intr_rate = 0, @wk_pvall_amt = 0,  @wk_prev_no = 0,
	@wk_pinvo_rema = 0,
	-- @wk_oinvo_last = 0, @wk_pvnew_flag = 1,
	@wk_expt_date = NULL, @wk_expt_mxdate = NULL,
	@wk_perd_fee =0, @wk_buy_date = NULL, @pm_proc_amt = 0,
	@wk_intr_fee = 0, @wk_lsum_last = 0,
	@wk_proc_last = 0, @wk_pvpay_amt = 0

/* get loan info */
SELECT	@wk_pvall_amt = kc_pvall_amt, @wk_perd_fee = kc_perd_fee,
	@wk_buy_date = kc_buy_date, @wk_prall_amt = kc_proc_amt,
	@wk_loan_perd = kc_loan_perd
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no


-- Old 動態查kc_loantype 的 intr_rate
/*
SELECT	@wk_intr_rate = t.kc_loan_rate
FROM	kcsd.kc_customerloan c, kcsd.kc_loantype t
WHERE	c.kc_loan_type = t.kc_loan_type
AND	c.kc_case_no = @pm_case_no */

-- 03/06/08 改抓每個case 的 kc_intr_rate
SELECT	@wk_intr_rate = kc_intr_rate
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

SELECT	@wk_expt_date = kc_expt_date, @wk_expt_fee = kc_expt_fee,
	@wk_pay_fee = kc_pay_fee, @wk_intr_fee = kc_intr_fee
FROM	kcsd.kc_loanpayment
WHERE	kc_case_no = @pm_case_no
AND	kc_perd_no = @pm_perd_no

-- 05/03/08: 不再計算溢開發票
--IF	@wk_buy_date < '7/1/2003'
--	SELECT	@wk_pvnew_flag = 0

/* 抓上期繳款資料 */
IF	@pm_perd_no = 1
BEGIN
	SELECT	@wk_pv_last = @wk_pvall_amt, @wk_pvpay_last = 0

-- 05/03/08: 不再計算溢開發票
--	IF	@wk_pvnew_flag <> 0	
--		SELECT	@pm_oinvo_amt = 0
--	ELSE				/* 溢開發票 */
--	BEGIN
--		SELECT	@pm_oinvo_amt = ISNULL(SUM(ISNULL(kc_invo_amt,0)),0)
--		FROM	kcsd.kc_loanpayment
--		WHERE	kc_case_no = @pm_case_no
--		AND	kc_pay_date < '7/1/2003'	/* 7/1 為溢開發票 */

--		SELECT	@pm_oinvo_amt = @pm_oinvo_amt + @wk_prall_amt
--	END
END	
ELSE
BEGIN
	EXECUTE kcsd.p_kc_getlastperiod @pm_case_no, @pm_perd_no, @wk_prev_no OUTPUT
	
	SELECT	@wk_pv_last = ISNULL(kc_pv_amt2, 0),
		@wk_pvpay_last = ISNULL(kc_pvpay_amt2, 0),
		@wk_pinvo_rema = ISNULL(kc_invo_rema2, 0),
--		@wk_oinvo_last = ISNULL(kc_oinvo_amt, 0),	-- 05/03/08: 不再計算溢開發票
		@wk_pproc_rema = ISNULL(kc_proc_rema2, 0),
		@wk_invo_last = ISNULL(kc_invo_amt2, 0),
		@wk_proc_last = ISNULL(kc_proc_amt2, 0),
		@wk_intr_last = ISNULL(kc_intr_fee, 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @pm_case_no
	AND	kc_perd_no = @wk_prev_no

-- 05/03/08: 不再計算溢開發票
--	IF	(@wk_pvnew_flag=0)		/* 考慮溢開發票 */
--	BEGIN
--		SELECT	@wk_lsum_last = @wk_invo_last + @wk_proc_last - @wk_intr_last
--		SELECT	@pm_oinvo_amt = @wk_oinvo_last - @wk_lsum_last
--		IF	@pm_oinvo_amt < 0
--			SELECT	@pm_oinvo_amt = 0
--	END
END

/* start Calc */
SELECT	@pm_pv_amt = @wk_pv_last - @wk_proc_last - @wk_pvpay_last


IF	@pm_perd_no < 50
	SELECT	@pm_invo_amt = ROUND(@pm_pv_amt * @wk_intr_rate / 1200.0, 0),
		@pm_proc_amt = ROUND(@wk_prall_amt/@wk_loan_perd, 0)
ELSE
BEGIN
	/* 上期利息/手續費 餘額 */
	SELECT	@pm_invo_amt = @wk_pinvo_rema,
		@pm_proc_amt = @wk_pproc_rema
END

-- 計算手續費(解決溢繳)
EXECUTE kcsd.p_kc_pvperiod_fixinvo_insu @pm_case_no, @pm_perd_no, @pm_proc_amt OUTPUT

IF	@wk_pay_fee >= @wk_expt_fee		/* 足額 */
	SELECT	@pm_pvpay_amt = @wk_expt_fee - @pm_invo_amt - @pm_proc_amt
ELSE
BEGIN
	IF	@wk_buy_date < '5/1/2005'	/* 先還利息 */
	BEGIN
		SELECT	@wk_avail_amt = @wk_pay_fee

		IF	@wk_avail_amt >= @pm_invo_amt	/* 先還全部利息, 考慮手續費 */
		BEGIN
			SELECT	@wk_avail_amt = @wk_avail_amt - @pm_invo_amt	/* 還利息 */
		

			IF	@wk_avail_amt >= @pm_proc_amt	/* 還手續費, 再還本金 */
				SELECT	@pm_pvpay_amt = @wk_avail_amt - @pm_proc_amt
			ELSE
			BEGIN					/* 還部分手續費 */
				SELECT	@pm_proc_rema = @pm_proc_amt - @wk_avail_amt
				SELECT	@pm_proc_amt = @wk_avail_amt
			END
		END
		ELSE
		BEGIN					/* 繳款不足利息, 先還息 */
			SELECT	@pm_invo_rema = @pm_invo_amt - @wk_avail_amt
			SELECT	@pm_invo_amt = @wk_avail_amt, @pm_pvpay_amt = 0
			/* KC 12/12/2003: 手續費完全未繳, 故已繳手續費為0,
			未繳手續費餘額餘額為原手續費 */
			SELECT	@pm_proc_rema = @pm_proc_amt
			SELECT	@pm_proc_amt = 0
		END
	END
	ELSE					/* 先還本金 */
	BEGIN
		SELECT	@wk_pvpay_amt = @wk_expt_fee - @pm_invo_amt - @pm_proc_amt	/* 應還本金 */

		SELECT	@wk_avail_amt = @wk_pay_fee

		IF	@wk_avail_amt >= @wk_pvpay_amt	/* 先還全部本金, 考慮手續費 */
		BEGIN
			SELECT	@wk_avail_amt = @wk_avail_amt - @wk_pvpay_amt,	/* 還本金後剩多少 */
				@pm_pvpay_amt = @wk_pvpay_amt
		

			IF	@wk_avail_amt >= @pm_proc_amt	/* 還手續費, 再還利息 */
			BEGIN
				SELECT	@wk_avail_amt = @wk_avail_amt - @pm_proc_amt

				SELECT	@pm_invo_rema = @pm_invo_amt - @wk_avail_amt
				SELECT	@pm_invo_amt = @wk_avail_amt
			END
			ELSE
			BEGIN					/* 還部分手續費 */
				SELECT	@pm_proc_rema = @pm_proc_amt - @wk_avail_amt
				SELECT	@pm_proc_amt = @wk_avail_amt

				SELECT	@pm_invo_rema = @pm_invo_amt	/* 利息未繳 */
				SELECT	@pm_invo_amt = 0
			END
		END
		ELSE
		BEGIN					/* 繳款不足本金, 全部還本金 */
			SELECT	@pm_invo_rema = @pm_invo_amt
			SELECT	@pm_invo_amt = 0, @pm_pvpay_amt = @wk_avail_amt
			/* KC 12/12/2003: 手續費完全未繳, 故已繳手續費為0,
			未繳手續費餘額餘額為原手續費 */
			SELECT	@pm_proc_rema = @pm_proc_amt
			SELECT	@pm_proc_amt = 0
		END		
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

IF	@pm_perd_no = @wk_expt_mxperd	/* 最後一期利息 及 手續費算法不同 */
BEGIN
	SELECT	@wk_proc_sum = SUM(kc_proc_amt2)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @pm_case_no
	AND	kc_perd_no <> @pm_perd_no

	SELECT	@pm_proc_amt = @wk_prall_amt - @wk_proc_sum
	SELECT	@pm_pvpay_amt = @pm_pv_amt - @pm_proc_amt
	SELECT	@pm_invo_amt = @wk_pay_fee - @pm_pvpay_amt - @pm_proc_amt
END
/*
-- 手續費減溢繳放最後有問題
ELSE	-- 07/11/2009 修正保費溢開發票, 作法: 手續費減溢開保費(最後一期不管)
BEGIN
	-- 抓溢開保費
	IF	EXISTS	(SELECT	'*'
			FROM	kcsd.kc_zzfix_invo
			WHERE	kc_case_no = @pm_case_no
			AND	(kc_perd_no IS NULL
				OR kc_perd_no = @pm_perd_no)
			)
	BEGIN
		SELECT	@wk_over_insu = 0

		-- 減去溢繳手續費
		SELECT	@wk_over_insu = kc_invo_diff
		FROM	kcsd.kc_zzfix_invo
		WHERE	kc_case_no = @pm_case_no

		SELECT	@pm_proc_amt = @pm_proc_amt - @wk_over_insu

		UPDATE	kcsd.kc_zzfix_invo
		SET	kc_perd_no = @pm_perd_no
		WHERE	kc_case_no = @pm_case_no
		--IF	@pm_proc_amt < 0 
		--BEGIN
		--	SELECT	@pm_invo_amt = @pm_invo_amt + @pm_proc_amt
		--END
	END
END
*/

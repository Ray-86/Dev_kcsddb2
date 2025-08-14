CREATE    PROCEDURE [kcsd].[p_kc_pushonhand_sub] @pm_pstrt_date datetime=NULL, @pm_pstop_date datetime=NULL, @pm_case_no varchar(10)=NULL, @pm_strt_date datetime=NULL, @pm_pusher_code varchar(10)=NULL,@pm_over_amt int OUTPUT, @pm_pay_sum int OUTPUT, @pm_intr_sum int OUTPUT, @pm_break_sum int OUTPUT
AS
DECLARE	@wk_delay_code	varchar(4),
	@wk_prepay_sum	int,
	@wk_close_date	datetime,	-- 指派結束日
	@wk_cut_date	datetime	-- 委託金額計算日

	-- Init RETURN values
	SELECT	@pm_over_amt = 0, @pm_pay_sum = 0, @pm_intr_sum = 0, @pm_break_sum = 0

	-- Init local variables
	SELECT	@wk_close_date = NULL, @wk_cut_date = NULL

	IF	@pm_pstrt_date IS NULL
	OR	@pm_pstop_date IS NULL
	OR	@pm_case_no IS NULL
	OR	@pm_strt_date IS NULL
	OR	@pm_pusher_code IS NULL
		RETURN

	-- 找出指派原因 & CloseDate
	SELECT	@wk_delay_code = kc_delay_code,
		@wk_close_date = kc_stop_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @pm_case_no
	AND	kc_strt_date = @pm_strt_date
	AND	kc_pusher_code = @pm_pusher_code

	-- 如果沒有結束日, 則設為期末日
	IF	@wk_close_date IS NULL
		SELECT	@wk_close_date = @pm_pstop_date

	-- 找出 cut_date 委託金額計算日 (委派日 vs pstrt_date), 較晚者為cut_date
	IF	@pm_pstrt_date < @pm_strt_date
		SELECT	@wk_cut_date = @pm_strt_date
	ELSE
		SELECT	@wk_cut_date = @pm_pstrt_date		

	IF	@pm_pusher_code LIKE 'L%'	-- 12/08/07 法務及外包類似 M1/MA
	OR	@pm_pusher_code LIKE 'Z%'	-- 12/08/07 法務及外包類似 M1/MA
	BEGIN
		-- 計算委託金額
		SELECT	@pm_over_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		--AND	kc_expt_date < @pm_pstrt_date
		AND	kc_expt_date < @wk_cut_date
		AND	kc_perd_no < 50

		-- 計算已回收金額, 條件: 繳款日在區間前
		SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		-- AND	kc_pay_date < @pm_pstrt_date
		AND	kc_pay_date < @wk_cut_date

		-- 委託金額 = 應收 - 已收 + 期間內但逾期繳
		SELECT	@pm_over_amt = @pm_over_amt - @wk_prepay_sum
		IF	@pm_over_amt < 0
			SELECT	@pm_over_amt = 0

		-- 法務及外包計算所有收回
		-- 12/08/07 新條件: 必須在指派區間內 (@pm_strt_date~@wk_close_date)
		IF	@pm_pusher_code LIKE 'L%'
		OR	@pm_pusher_code LIKE 'Z%'
			SELECT	@pm_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
				@pm_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
				@pm_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
			FROM	kcsd.kc_loanpayment
			WHERE	kc_case_no = @pm_case_no
			AND	kc_pay_date BETWEEN @pm_pstrt_date AND @pm_pstop_date
			AND	kc_pay_date BETWEEN @pm_strt_date AND @wk_close_date
		RETURN
	END

	-- M1/MA
	IF	@wk_delay_code = 'M1'
	OR	@wk_delay_code = 'MA'
	BEGIN
		-- 計算委託金額
		SELECT	@pm_over_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		AND	kc_expt_date < @wk_cut_date
		AND	kc_perd_no < 50

		-- 計算已回收金額, 條件: 繳款日在區間前
		SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		AND	kc_pay_date < @wk_cut_date

		-- 委託金額 = 應收 - 已收 (+ 期間內但逾期繳 ??)
		SELECT	@pm_over_amt = @pm_over_amt - @wk_prepay_sum
		IF	@pm_over_amt < 0
			SELECT	@pm_over_amt = 0

		-- 法務及外包計算所有收回
		-- 12/08/07 新條件: 必須在指派區間內 (@pm_strt_date~@wk_close_date)
		IF	@pm_pusher_code LIKE 'L%'
		OR	@pm_pusher_code LIKE 'Z%'
			SELECT	@pm_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
				@pm_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
				@pm_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
			FROM	kcsd.kc_loanpayment
			WHERE	kc_case_no = @pm_case_no
			AND	kc_pay_date BETWEEN @pm_pstrt_date AND @pm_pstop_date
			AND	kc_pay_date BETWEEN @pm_strt_date AND @wk_close_date
		-- 催收
		-- 計算收回金額, 條件: 繳款日在區間內 & 應繳日在區間末之前 & 逾期繳款
		-- 12/08/07 新條件: 必須在指派區間內 (@pm_strt_date~@wk_close_date)
		ELSE
		IF	@pm_over_amt > 0
			SELECT	@pm_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
				@pm_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
				@pm_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
			FROM	kcsd.kc_loanpayment
			WHERE	kc_case_no = @pm_case_no
			AND	kc_pay_date BETWEEN @pm_pstrt_date AND @pm_pstop_date
			AND	kc_pay_date BETWEEN @pm_strt_date AND @wk_close_date
			AND	kc_expt_date < @pm_pstrt_date
	END
	ELSE	-- M0 or MX
	BEGIN
		-- 計算委託金額
		SELECT	@pm_over_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		AND	kc_expt_date <= @pm_pstop_date
		AND	kc_expt_date <= @wk_close_date
		AND	kc_perd_no < 50

		-- 計算已回收金額, 條件: 繳款日在區間前
		SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @pm_case_no
		--AND	kc_pay_date < @pm_pstrt_date
		AND	kc_pay_date < @wk_cut_date

		-- 委託金額 = 應收 - 已收 			(+ 期間內但逾期繳 ??)
		SELECT	@pm_over_amt = @pm_over_amt - @wk_prepay_sum
		IF	@pm_over_amt < 0
			SELECT	@pm_over_amt = 0
		
		-- 計算收回金額, 條件: 繳款日在區間內 & 應繳日在區間末之前 & 逾期繳款
		-- 12/08/07 新條件: 必須在指派區間內 (@pm_strt_date~@wk_close_date)
		IF	@pm_over_amt > 0
		BEGIN
			--IF	@pm_pusher_code NOT LIKE 'L%'
			--AND	@pm_pusher_code NOT LIKE 'Z%'
				SELECT	@pm_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
					@pm_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
					@pm_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
				FROM	kcsd.kc_loanpayment
				WHERE	kc_case_no = @pm_case_no
				AND	kc_pay_date BETWEEN @pm_pstrt_date AND @pm_pstop_date
				AND	kc_pay_date BETWEEN @pm_strt_date AND @wk_close_date
				AND	kc_expt_date <= @pm_pstop_date
				AND	kc_expt_date < kc_pay_date 
			/*
			-- 12/08/07 法務及外包比照 M1/MA
			ELSE	-- 法務及外包計算所有收回
				SELECT	@pm_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
					@pm_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
					@pm_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)				
				FROM	kcsd.kc_loanpayment
				WHERE	kc_case_no = @pm_case_no
				AND	kc_pay_date BETWEEN @pm_pstrt_date AND @pm_pstop_date
			*/
		END
	END

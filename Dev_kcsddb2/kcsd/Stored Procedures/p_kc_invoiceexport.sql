/*
-- ==========================================================================================
--2017-10-12 kc_pay_date 改 kc_invo_date
-- 05/17/2009 KC: 限制只有issu_code 東元資融01 (or NULL)才執行
01/19/08 其他收入現金繳款列入計算
05/13/07 Bravo!! Optimize from 40 -> 1.5 minutes (1 month invo) with index on case_no
05/11/07 a. use cusor fast_forward to improve performance
	 b. rename cursor_case_no to cursor_case_no_invoexp to avoid lock
	 c. use #tmp table as loop index */
-- 2016/08/18 更改計算增加01 03
	 
-- ==========================================================================================
CREATE                PROCEDURE [kcsd].[p_kc_invoiceexport]
	@pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL , @pm_issu_code varchar(2) = NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_invo_date	datetime,

	@wk_invo_amt	int,
	@wk_misc_amt	int,
	@wk_invo_no	varchar(10),
	@wk_invo_max	varchar(10),

	@wk_oinvo_amt	int,
	@wk_local_sum	int,
	@wk_item_no	int,
	@wk_item_sum	int,

	@wk_idle_date	datetime

CREATE TABLE #tmp_loop_invoexp
(kc_case_no	varchar(10),
kc_invo_date	datetime
)

SELECT	@wk_case_no=NULL, @wk_invo_date=NULL

INSERT	#tmp_loop_invoexp
SELECT	p.kc_case_no, p.kc_invo_date
	FROM	kcsd.kc_loanpayment p, kcsd.kc_customerloan c
	WHERE	p.kc_invo_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND (p.kc_case_no BETWEEN '0' AND '5' OR p.kc_case_no LIKE 'T%')
	AND	p.kc_pay_fee > 0
	AND	p.kc_case_no = c.kc_case_no
	AND	c.kc_loan_stat not in ('X','Y')
	AND	(c.kc_idle_date IS NULL	OR c.kc_idle_date>= @pm_strt_date)-- 05/13/05 KC: 呆帳不開發票
	AND	(c.kc_issu_code = @pm_issu_code)--2016/08/18 東元車業增加-- 05/17/2009 東元資融 only
	GROUP BY p.kc_case_no, p.kc_invo_date
	ORDER BY p.kc_case_no, p.kc_invo_date

DECLARE	cursor_case_no_invoexp	CURSOR FAST_FORWARD
FOR	SELECT	kc_case_no, kc_invo_date
	FROM	#tmp_loop_invoexp

OPEN cursor_case_no_invoexp
FETCH NEXT FROM cursor_case_no_invoexp INTO @wk_case_no, @wk_invo_date


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_invo_amt = 0, @wk_misc_amt = 0,
		@wk_oinvo_amt = 0, @wk_local_sum = 0,
		@wk_invo_no = NULL, @wk_invo_max = NULL,
		@wk_item_no = 0, @wk_item_sum = 0

	SELECT	@wk_oinvo_amt = MAX(kc_oinvo_amt)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_invo_date = @wk_invo_date

	SELECT	@wk_local_sum = SUM(kc_invo_amt2 + kc_proc_amt2 - kc_intr_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_invo_date = @wk_invo_date

	/* type 'C' 不要計算其他收入 */
	SELECT	@wk_misc_amt = SUM(kc_break_fee)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_invo_date = @wk_invo_date
	--AND	kc_pay_type <> 'C'

	IF	@wk_local_sum > @wk_oinvo_amt
		SELECT	@wk_invo_amt = @wk_local_sum - @wk_oinvo_amt
	ELSE
		SELECT	@wk_invo_amt = 0

	SELECT	@wk_invo_max = MAX(kc_invo_no)
	FROM	invodb.dbo.kc_invoice
	WHERE	kc_case_no = @wk_case_no

	IF	@wk_invo_max IS NULL
		SELECT	@wk_invo_no = @wk_case_no + '001'
	ELSE
	BEGIN
		SELECT	@wk_invo_no = '000'
			+ CONVERT(varchar(3), CONVERT(int, RIGHT(@wk_invo_max, 3))+1 )
		SELECT	@wk_invo_no = @wk_case_no + RIGHT(@wk_invo_no, 3)
	END

	/* 處理iv明細 */
	IF	@wk_invo_amt > 0
	BEGIN
		SELECT	@wk_item_no = @wk_item_no + 1,
			@wk_item_sum = @wk_item_sum + @wk_invo_amt

--		SELECT	@wk_case_no, @wk_invo_no, @wk_item_no, @wk_invo_amt, '財務收入'

		INSERT	invodb.dbo.kc_invoicedetail
			(kc_invo_no, kc_item_no, kc_item_name, kc_item_amt)
		VALUES	(@wk_invo_no, @wk_item_no, '財務收入', @wk_invo_amt)
	END

	IF	@wk_misc_amt > 0
	BEGIN
		SELECT	@wk_item_no = @wk_item_no + 1,
			@wk_item_sum = @wk_item_sum + @wk_misc_amt

--		SELECT	@wk_case_no, @wk_invo_no, @wk_item_no, @wk_misc_amt, '其他收入'

		INSERT	invodb.dbo.kc_invoicedetail
			(kc_invo_no, kc_item_no, kc_item_name, kc_item_amt)
		VALUES	(@wk_invo_no, @wk_item_no, '其他收入', @wk_misc_amt)
	END

	/* 轉入iv主檔*/
	IF	@wk_item_sum > 0
	BEGIN
--		SELECT	@wk_case_no, @wk_invo_date, @wk_invo_amt, @wk_misc_amt, @wk_item_sum, 'iv 主檔'

		INSERT	invodb.dbo.kc_invoice
			(kc_invo_no, kc_case_no, kc_invo_date, kc_invo_amt, kc_invo_flag)
		VALUES	(@wk_invo_no, @wk_case_no, @wk_invo_date, @wk_item_sum, 'N')
	END
	FETCH NEXT FROM cursor_case_no_invoexp INTO @wk_case_no, @wk_invo_date
END

DEALLOCATE	cursor_case_no_invoexp

DROP TABLE #tmp_loop_invoexp


/* IIf([wk_oinvo_amt]-[wk_local_sum]<0,[wk_local_sum]-[wk_oinvo_amt],0) */

/*
3/20/2004: KC 修改自 p_kc_pushonhand
以 3/1 ~ 3/31 為例:
* 件數:  需滿足條件1或條件二
  條件1: 指派開始日在  3/31(含) 日前, 且無結束日
或條件2: 指派開始日在  3/31(含) 日前, 且結束日在 3/1~3/31之間
或條件3: 指派開始日在  3/31(含) 日前, 且結束日在 3/31之後 (可與條件2合併) (KC: 5/1/2004)

6/11/2005 KC: add kc_break_sum
*/

CREATE      PROCEDURE [kcsd].[p_kc_pushonhand_lastperd] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,	/* 區間內該case最後指派時間 */
	@wk_close_date	datetime,	/* 區間內最後指派的結束時間 */
	@wk_pusher_code	varchar(6),
	@wk_over_amt	int,
	@wk_prepay_sum	int,		/* 區間前已繳 */
	@wk_pay_sum	int,
	@wk_intr_sum	int,		/* 折扣 */
	@wk_break_sum	int,		/* 違約 */
	@wk_m1_date	datetime,
	@wk_delay_code	varchar(4)

CREATE TABLE #tmp_pushonhand
(
	kc_case_no	varchar(10),
	kc_pusher_code	varchar(6),
	kc_strt_date	smalldatetime,
	kc_close_date	smalldatetime,
	kc_over_amt	int,
	kc_pay_sum	int,
	kc_intr_sum	int,
	kc_break_sum	int,
	kc_delay_code	varchar(4)
)


IF	@pm_strt_date IS NULL
	SELECT	@pm_strt_date = CONVERT(char(2), DATEPART(month, GETDATE())) + '/1/'
		+ CONVERT(char(4), DATEPART(year, GETDATE()))
IF	@pm_stop_date IS NULL
	SELECT	@pm_stop_date = DATEADD(day, -1, DATEADD(minute, 1, @pm_strt_date))

/* 計算M1基準日: 每月1日 */
SELECT	@wk_m1_date = CONVERT(char(2), DATEPART(month, @pm_stop_date)) + '/1/'
	+ CONVERT(char(4), DATEPART(year, @pm_stop_date))
SELECT	@wk_m1_date = DATEADD(month, -1, @wk_m1_date)

SELECT	@pm_stop_date = CONVERT(varchar(12), @pm_stop_date, 1)	/* MM/DD/YY */
SELECT	@pm_stop_date = DATEADD(minute, -1, DATEADD(day, 1, @pm_stop_date))

/* 找出 kc_case_no */
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	DISTINCT kc_case_no
	FROM	kcsd.kc_pushassign
	WHERE	(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
	OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
	/*OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date BETWEEN @pm_strt_date AND @pm_stop_date)*/
	ORDER BY kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_strt_date=NULL, @wk_close_date=NULL,
		@wk_pusher_code=NULL, @wk_delay_code = NULL,
		@wk_over_amt = 0, @wk_pay_sum = 0, @wk_intr_sum = 0,
		@wk_break_sum = 0,
		@wk_prepay_sum = 0 /*, @wk_prepay_sum2 = 0 */

	/* 找出區間內最後一位催款人 */
	SELECT	@wk_strt_date = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	(	(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
		OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
		/*OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date BETWEEN @pm_strt_date AND @pm_stop_date) )*/
		)
	/* 找出催款人 & 指派原因 */
	SELECT	@wk_pusher_code = kc_pusher_code,
		@wk_delay_code = kc_delay_code,
		@wk_close_date = kc_stop_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_date

	BEGIN
		/* 計算委託金額 */
		SELECT	@wk_over_amt = ISNULL(SUM(ISNULL(kc_expt_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_expt_date < @pm_strt_date
		AND	kc_perd_no < 50

		/* 計算已回收金額, 條件: 繳款日在區間前 */
		SELECT	@wk_prepay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date < @pm_strt_date

		/* 委託金額 = 應收 - 已收 + 期間內但逾期繳*/
		SELECT	@wk_over_amt = @wk_over_amt - @wk_prepay_sum
		IF	@wk_over_amt < 0
			SELECT	@wk_over_amt = 0
		
		/* 計算收回金額, 條件: 繳款日在區間內 & 應繳日在區間末之前 & 逾期繳款 */
		IF	@wk_over_amt > 0
			SELECT	@wk_pay_sum = ISNULL(SUM(ISNULL(kc_pay_fee, 0)), 0),
				@wk_intr_sum = ISNULL(SUM(ISNULL(kc_intr_fee, 0)), 0),
				@wk_break_sum = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)
			FROM	kcsd.kc_loanpayment
			WHERE	kc_case_no = @wk_case_no
			AND	kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
			AND	kc_expt_date < @pm_strt_date
	END

	INSERT	#tmp_pushonhand
		(kc_case_no, kc_pusher_code, kc_strt_date, kc_close_date,
		kc_over_amt, kc_pay_sum, kc_intr_sum, kc_break_sum, kc_delay_code)
	VALUES	(@wk_case_no, @wk_pusher_code, @wk_strt_date, @wk_close_date,
		@wk_over_amt, @wk_pay_sum, @wk_intr_sum, @wk_break_sum, @wk_delay_code)
	
	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_pushonhand
ORDER BY kc_case_no, kc_pusher_code

DROP TABLE #tmp_pushonhand

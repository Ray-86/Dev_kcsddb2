/*
-- ==========================================================================================
01/12/2008 委派0且收回0不顯示
-- ==========================================================================================*/
CREATE PROCEDURE [kcsd].[p_kc_pushonhand_xpushlaw] @pm_strt_date datetime=NULL, @pm_stop_date datetime=NULL,
			@pm_case_no varchar(10)=NULL
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,	/* 區間內該case最後指派時間 */
	@wk_close_date	datetime,	/* 區間內最後指派的結束時間 */
	@wk_pusher_code	varchar(6),
	@wk_over_amt	int,
	@wk_prepay_sum	int,		/* 區間前已繳 */
	/*@wk_prepay_sum2	int,		*//* 期間內逾期已繳,多扣再加回 */
	@wk_pay_sum	int,
	@wk_intr_sum	int,		/* 折扣 */
	@wk_break_sum	int,		/* 違約金 */
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


/* 條件:	kc_strt_date<=區間結束 & kc_stop_date IS NULL
	OR	kc_strt_date<=區間結束 & kc_stop_date>= 區間開始
*/

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

-- 找出 kc_case_no
IF	@pm_case_no IS NULL
	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	DISTINCT kc_case_no
		FROM	kcsd.kc_pushassign
		WHERE	(
				(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
			OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
			)
		ORDER BY kc_case_no
ELSE	-- 限定 case (deubg use)
	DECLARE	cursor_case_no	CURSOR
	FOR	SELECT	DISTINCT kc_case_no
		FROM	kcsd.kc_pushassign
		WHERE	(
				(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
			OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
			)
		AND	kc_case_no = @pm_case_no
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

	DECLARE	cursor_pushonhand_pusher CURSOR
	FOR	SELECT	kc_strt_date, kc_pusher_code
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	(	(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
			OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
			)
		ORDER BY kc_strt_date, kc_pusher_code
/*
	-- 找出區間內最後一位催款人
	SELECT	@wk_strt_date = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	(	(kc_strt_date <= @pm_stop_date AND kc_stop_date IS NULL)
		OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date >= @pm_strt_date)
		--OR	(kc_strt_date <= @pm_stop_date AND kc_stop_date BETWEEN @pm_strt_date AND @pm_stop_date)
		)
	-- 找出催款人 & 指派原因
	SELECT	@wk_pusher_code = kc_pusher_code,
		@wk_delay_code = kc_delay_code,
		@wk_close_date = kc_stop_date
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_date
*/
	OPEN cursor_pushonhand_pusher
	FETCH NEXT FROM cursor_pushonhand_pusher INTO @wk_strt_date, @wk_pusher_code

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		-- 找出指派原因
		SELECT	@wk_delay_code = kc_delay_code,
			@wk_close_date = kc_stop_date
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date = @wk_strt_date
		AND	kc_pusher_code = @wk_pusher_code

		EXECUTE	kcsd.p_kc_pushonhand_sub
			@pm_strt_date, @pm_stop_date, @wk_case_no, @wk_strt_date, @wk_pusher_code,
			@wk_over_amt OUTPUT, @wk_pay_sum OUTPUT, @wk_intr_sum OUTPUT, @wk_break_sum OUTPUT

		IF	@wk_over_amt > 0
		OR	@wk_pay_sum > 0 
			INSERT	#tmp_pushonhand
				(kc_case_no, kc_pusher_code, kc_strt_date, kc_close_date,
				kc_over_amt, kc_pay_sum, kc_intr_sum, kc_break_sum, kc_delay_code)
			VALUES	(@wk_case_no, @wk_pusher_code, @wk_strt_date, @wk_close_date,
				@wk_over_amt, @wk_pay_sum, @wk_intr_sum, @wk_break_sum, @wk_delay_code)
		
		FETCH NEXT FROM cursor_pushonhand_pusher INTO @wk_strt_date, @wk_pusher_code
	END	

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no

	DEALLOCATE	cursor_pushonhand_pusher
END

DEALLOCATE	cursor_case_no

SELECT	*
FROM	#tmp_pushonhand

DROP TABLE #tmp_pushonhand

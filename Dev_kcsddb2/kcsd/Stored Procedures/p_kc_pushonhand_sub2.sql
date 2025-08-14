-- ==========================================================================================
--01/19/08 當月未收款但轉指派, 刪除舊指派的指派金額
--TEST case: 0617050 1/1/2008~1/31/2008
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_pushonhand_sub2]
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

CREATE TABLE #tmp_pushonhand_sub2
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



-- 找出 kc_case_no
DECLARE	csr_case_no_pushoh_sub	CURSOR LOCAL
FOR	SELECT	DISTINCT kc_case_no, kc_strt_date
	FROM	#tmp_pushonhand
	ORDER BY kc_case_no, kc_strt_date

OPEN csr_case_no_pushoh_sub
FETCH NEXT FROM csr_case_no_pushoh_sub INTO @wk_case_no, @wk_strt_date

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_pusher_code=NULL, @wk_close_date=NULL,
		@wk_over_amt=0, @wk_pay_sum=0, @wk_intr_sum=0,
		@wk_break_sum=0, @wk_delay_code=NULL

	SELECT	@wk_pay_sum = kc_pay_sum,
		@wk_break_sum = kc_break_sum,
		@wk_pusher_code = kc_pusher_code,
		@wk_close_date = kc_close_date,
		@wk_over_amt = kc_over_amt,
		@wk_intr_sum = kc_intr_sum, 
		@wk_delay_code = kc_delay_code
	FROM	#tmp_pushonhand
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_date

	IF	@wk_pay_sum = 0
	AND	@wk_break_sum = 0
	AND	@wk_intr_sum = 0
	AND	EXISTS	(SELECT	'*'
			FROM	#tmp_pushonhand	
			WHERE	kc_case_no = @wk_case_no
			AND	kc_strt_date > @wk_strt_date
			AND	kc_over_amt > 0)
	BEGIN
		INSERT	#tmp_pushonhand_sub2
			(kc_case_no, kc_pusher_code, kc_strt_date, kc_close_date,
			kc_over_amt, kc_pay_sum, kc_intr_sum, kc_break_sum, kc_delay_code)
		VALUES	(@wk_case_no, @wk_pusher_code, @wk_strt_date, @wk_close_date,
			@wk_over_amt, @wk_pay_sum, @wk_intr_sum, @wk_break_sum, @wk_delay_code)

		DELETE
		FROM	#tmp_pushonhand
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date = @wk_strt_date
	END

	FETCH NEXT FROM csr_case_no_pushoh_sub INTO @wk_case_no, @wk_strt_date
END

DEALLOCATE	csr_case_no_pushoh_sub

--SELECT	*
--FROM	#tmp_pushonhand_sub2

DROP TABLE #tmp_pushonhand_sub2

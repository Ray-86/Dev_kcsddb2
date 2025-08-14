CREATE   PROCEDURE [kcsd].[p_kc_stat_subcontract(保留舊的)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_pusher_code		varchar(6),
	@wk_pusher_amt	int,
	@wk_break_amt	int,
	@wk_pay_amt	int,	/* 收回金額 */
	@wk_payb_amt	int,	/* 收回違約金 */

	@wk_lstrt_date	datetime,		/* 上次外包 */
	@wk_lpusher_name	varchar(20),
	
	@wk_lpay_date		datetime,	/* 最後繳款 */
	@wk_lpay_amt		int,
	@wk_pusher_count	int

SELECT	@wk_case_no=NULL

CREATE TABLE #tmp_subcon
(kc_case_no	varchar(10),
kc_pusher_code	varchar(6) NULL,
kc_strt_date	datetime NULL,
kc_pusher_amt	int NULL,
kc_break_amt	int NULL,
kc_pusher_amtr	int NULL,
kc_break_amtr	int NULL,
kc_pusher_count int NULL,
kc_lpusher_name varchar(20) NULL,
kc_lstrt_date	datetime NULL,
kc_lpay_date	datetime NULL,
kc_lpay_amt	int NULL)


DECLARE	cursor_case_no_subcon	CURSOR
FOR	SELECT DISTINCT	c.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_pushassign p
	WHERE	c.kc_case_no = p.kc_case_no
	AND	p.kc_pusher_code LIKE 'Z%'
	/* AND	c.kc_case_no < '030153' */
	ORDER BY c.kc_case_no

OPEN cursor_case_no_subcon
FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_strt_date = NULL, @wk_lstrt_date = NULL,
		@wk_pusher_code = NULL, @wk_lpusher_name = NULL,
		@wk_pusher_amt = 0, @wk_break_amt = 0,
		@wk_pay_amt = 0, @wk_payb_amt = 0,
		@wk_lpay_date = NULL, @wk_lpay_amt = 0

	SELECT	@wk_lpay_date = MAX(kc_pay_date)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	IF	@wk_lpay_date IS NOT NULL
		SELECT	@wk_lpay_amt = SUM(ISNULL(kc_pay_fee, 0))
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date = @wk_lpay_date

	/* 最後的外包 */
	SELECT	@wk_strt_date = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign p
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pusher_code LIKE 'Z%'

	SELECT	@wk_pusher_code = kc_pusher_code,
		@wk_pusher_amt = ISNULL(kc_pusher_amt, 0), @wk_break_amt = ISNULL(kc_break_amt, 0)
	FROM	kcsd.kc_pushassign 
	WHERE	kc_case_no = @wk_case_no
	AND	kc_strt_date = @wk_strt_date

	SELECT	@wk_pay_amt = ISNULL(SUM(ISNULL(kc_pay_fee, 0)),0),
		@wk_payb_amt = ISNULL(SUM(ISNULL(kc_break_fee, 0)), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date >= @wk_strt_date

	/* 上一個外包 */
	SELECT	@wk_lstrt_date = MAX(kc_strt_date)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pusher_code LIKE 'Z%'
	AND	kc_pusher_code <> @wk_pusher_code
	AND	kc_strt_date < @wk_strt_date

	IF	@wk_lstrt_date IS NOT NULL
	BEGIN
		SELECT	@wk_lpusher_name = DelegateName
		FROM	kcsd.Delegate e, kcsd.kc_pushassign p
		WHERE	p.kc_case_no = @wk_case_no
		AND	p.kc_strt_date = @wk_lstrt_date
		AND	e.DelegateCode = p.kc_pusher_code
	END

	SELECT	@wk_pusher_count = COUNT(kc_case_no)
	FROM	kcsd.kc_pushassign
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pusher_code LIKE 'Z%'

	INSERT	#tmp_subcon
		(kc_case_no, kc_pusher_code, kc_strt_date,
		kc_pusher_amt, kc_break_amt, kc_pusher_amtr, kc_break_amtr,
		kc_pusher_count, kc_lpusher_name, kc_lstrt_date, kc_lpay_date, kc_lpay_amt)
	VALUES	(@wk_case_no, @wk_pusher_code, @wk_strt_date,
		@wk_pusher_amt, @wk_break_amt, @wk_pusher_amt-@wk_pay_amt, @wk_break_amt-@wk_payb_amt ,
		@wk_pusher_count, @wk_lpusher_name, @wk_lstrt_date, @wk_lpay_date, @wk_lpay_amt)

	FETCH NEXT FROM cursor_case_no_subcon INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_subcon

SELECT	*
FROM	#tmp_subcon s

DROP TABLE #tmp_subcon

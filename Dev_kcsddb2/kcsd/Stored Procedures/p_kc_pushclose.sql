CREATE  PROCEDURE [kcsd].[p_kc_pushclose]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_strt_date	datetime,
	@wk_pusher_code	varchar(6),
	@wk_loan_stat	varchar(1),
	@wk_lpay_date	datetime,
	@wk_close_date	datetime

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_strt_date, kc_pusher_code
	FROM	kcsd.kc_pushassign
	WHERE	kc_stop_date IS NULL
	AND	kc_pusher_code IS NOT NULL
	ORDER BY kc_case_no

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_strt_date, @wk_pusher_code


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_loan_stat = kc_loan_stat
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no	

	/* 已結清或正常 */
	IF	@wk_loan_stat = 'C'
	OR	@wk_loan_stat = 'E'
	OR	@wk_loan_stat = 'G'
	BEGIN
		SELECT	@wk_lpay_date = MAX(kc_pay_date)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_pay_date IS NOT NULL

		SELECT	@wk_close_date = DATEADD(day, -DATEPART(day, @wk_lpay_date), DATEADD(month, 1, @wk_lpay_date) )

		/* SELECT	@wk_case_no, @wk_pusher_code, @wk_loan_stat, @wk_lpay_date, @wk_close_date */

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = NULL, kc_pusher_date = NULL
		WHERE	kc_case_no = @wk_case_no	

		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @wk_close_date
		WHERE	kc_case_no = @wk_case_no
		AND	kc_strt_date = @wk_strt_date
		AND	kc_pusher_code = @wk_pusher_code
	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no, @wk_strt_date, @wk_pusher_code
END

DEALLOCATE	cursor_case_no

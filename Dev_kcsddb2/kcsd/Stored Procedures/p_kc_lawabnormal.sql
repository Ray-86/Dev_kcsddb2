CREATE  PROCEDURE [kcsd].[p_kc_lawabnormal]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_lpay_date	datetime,
	@wk_lpush_date	datetime,
	@wk_pusher_code	varchar(10)

SELECT	@wk_case_no=NULL

CREATE TABLE #tmp_lawabnormal
(kc_case_no	varchar(10),
kc_pusher_code	varchar(10)
)

DECLARE	cursor_case_no_lawabnormal	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'D'
	ORDER BY kc_case_no

OPEN cursor_case_no_lawabnormal
FETCH NEXT FROM cursor_case_no_lawabnormal INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_lpay_date = NULL, @wk_lpush_date = NULL,
		@wk_pusher_code = NULL

	SELECT	@wk_lpay_date = MAX(kc_pay_date)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_lpush_date = MAX(kc_push_date)
	FROM	kcsd.kc_push
	WHERE	kc_case_no = @wk_case_no
	AND	kc_push_note NOT like '約收%'

	SELECT	@wk_pusher_code = kc_pusher_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
	
	IF	@wk_lpay_date BETWEEN '6/1/2004' AND '8/31/2004'
	AND	@wk_lpush_date < '9/1/2004'
	AND	@wk_pusher_code NOT LIKE 'Z%'
		INSERT	#tmp_lawabnormal
			(kc_case_no, kc_pusher_code)
		VALUES	(@wk_case_no, @wk_pusher_code)

	FETCH NEXT FROM cursor_case_no_lawabnormal INTO @wk_case_no
END

DEALLOCATE	cursor_case_no_lawabnormal
SELECT	*
FROM	#tmp_lawabnormal
ORDER BY kc_pusher_code, kc_case_no

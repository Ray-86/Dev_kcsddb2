
-- ==========================================================================================
-- 2017-11-31 正常結案原車買賣自動簡訊
-- ==========================================================================================

CREATE	PROCEDURE [kcsd].[p_kc_autosms_clear]
	@pm_run_code VARCHAR(20) = NULL
AS
DECLARE	
	@wk_case_no		VARCHAR(10),
	@wk_area_code	VARCHAR(2),
	@wk_mobil_no	VARCHAR(10),
	@wk_sms_msg		VARCHAR(300),
	@wk_sms_no		INT,
	@wk_push_no		INT,
	@wk_push_date	DATETIME,
	@wk_push_link	VARCHAR(10)

--SELECT @wk_sms_msg = '原機車已繳清，請立即點選 https://line.me/R/ti/p/%40dy22268886 加入東元分期LINE好友！3-5萬原車分期優惠專案詳情請電洽：02-22268886或搜尋LINEID：@dy22268886'
SELECT @wk_sms_msg = '3-5萬原車融資，https://line.me/R/ti/p/%40dy22268886 加入東元LINE洽詢!或電02-22268886'
SELECT @wk_sms_no = 0, @wk_push_no = 0, @wk_push_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

DECLARE	cursor_clear_caseNo	CURSOR
FOR	
	SELECT A.kc_case_no, A.kc_area_code, A.kc_mobil_no
	FROM kcsd.kc_customerloan A
	LEFT JOIN (SELECT kc_case_no,MAX(kc_pay_date) AS MaxPayDate FROM kcsd.kc_loanpayment GROUP BY kc_case_no) B on A.kc_case_no = B.kc_case_no
	WHERE A.kc_loan_stat IN ('C') 
	AND A.kc_break_amt2 < 500
	AND A.kc_car_stat NOT IN ('D')
	AND A.kc_mobil_no IS NOT NULL
	AND DATEADD(DAY, 90, A.kc_buy_date) < B.MaxPayDate
	AND DATEADD(YEAR, 20, A.kc_birth_date) <= DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))
	AND DATEADD(DAY, 30, B.MaxPayDate) = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))
	and not EXISTS 
	(
	select 'x' from kcsd.kc_customerloan C where C.kc_id_no = A.kc_id_no and C.kc_loan_stat in ('D','G') and (C.kc_break_amt2 >500 or C.kc_rema_amt>20000)
	)

OPEN cursor_clear_caseNo
FETCH NEXT FROM cursor_clear_caseNo INTO @wk_case_no, @wk_area_code, @wk_mobil_no

WHILE (@@FETCH_STATUS = 0)
BEGIN

	IF @pm_run_code = 'EXECUTE'
	BEGIN
		SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
		SELECT @wk_push_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no
		SELECT @wk_push_link = '0000' + @wk_sms_no
		--催繳
		INSERT INTO kc_push (kc_case_no, kc_item_no, kc_area_code, kc_push_date, kc_push_note, kc_updt_date, kc_updt_user, kc_sms_no, kc_push_link) 
		VALUES (@wk_case_no, @wk_push_no, @wk_area_code, @wk_push_date, @wk_sms_msg, GETDATE(), USER, @wk_sms_no, @wk_push_link)
		--簡訊
		INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link) 
		VALUES (@wk_case_no, @wk_sms_no, @wk_push_date, @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link)
	END

	FETCH NEXT FROM cursor_clear_caseNo INTO @wk_case_no, @wk_area_code, @wk_mobil_no
END
CLOSE cursor_clear_caseNo
DEALLOCATE cursor_clear_caseNo


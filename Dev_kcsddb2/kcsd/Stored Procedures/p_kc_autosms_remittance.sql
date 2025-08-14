
-- ==========================================================================================
-- 2021-07-30 新增產品別11原機
-- 2019-03-13 原車買賣電匯後自動簡訊
-- ==========================================================================================

CREATE	PROCEDURE [kcsd].[p_kc_autosms_remittance]
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
	@wk_push_link	VARCHAR(10),
	@wk_issu_desc 	VARCHAR(20),
	@wk_cust_nameu 	VARCHAR(10),
	@wk_give_amt	int

SELECT @wk_sms_no = 0, @wk_push_no = 0, @wk_push_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

DECLARE	cursor_clear_caseNo	CURSOR
FOR
	SELECT c.kc_case_no, c.kc_area_code, c.kc_mobil_no, i.kc_issu_desc , c.kc_give_amt, c.kc_cust_nameu
	FROM kcsd.kc_remittance r left join kcsd.kc_customerloan c on c.kc_case_no = r.kc_case_no
	                          left join kcsd.kct_issuecompany i on i.kc_issu_code = c.kc_issu_code
	WHERE r.kc_remit_date = CONVERT(varchar(10), GETDATE(), 23)
	and c.kc_prod_type in('04', '11')

OPEN cursor_clear_caseNo
FETCH NEXT FROM cursor_clear_caseNo INTO @wk_case_no, @wk_area_code, @wk_mobil_no, @wk_issu_desc, @wk_give_amt, @wk_cust_nameu

WHILE (@@FETCH_STATUS = 0)
BEGIN

	IF @pm_run_code = 'EXECUTE'
	BEGIN
		SELECT @wk_sms_msg = @wk_issu_desc+'通知:申辦'+CONVERT(varchar(6), @wk_give_amt)+'元扣除相關費用後，款項將於今日匯入指定帳戶，匯票付款則於今日寄出，請查收，祝一切順心。' 
		SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
		SELECT @wk_push_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no
		SELECT @wk_push_link = '0000' + @wk_sms_no
		--催繳
		INSERT INTO kc_push (kc_case_no, kc_item_no, kc_area_code, kc_push_date, kc_push_note, kc_updt_date, kc_updt_user, kc_sms_no, kc_push_link) 
		VALUES (@wk_case_no, @wk_push_no, @wk_area_code, @wk_push_date, @wk_sms_msg, GETDATE(), USER, @wk_sms_no, @wk_push_link)
		--簡訊
		INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link) 
		VALUES (@wk_case_no, @wk_sms_no, @wk_push_date, @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link)
		--print @wk_case_no + ' ' +@wk_sms_msg
	END

	FETCH NEXT FROM cursor_clear_caseNo INTO @wk_case_no, @wk_area_code, @wk_mobil_no, @wk_issu_desc, @wk_give_amt, @wk_cust_nameu
END
CLOSE cursor_clear_caseNo
DEALLOCATE cursor_clear_caseNo


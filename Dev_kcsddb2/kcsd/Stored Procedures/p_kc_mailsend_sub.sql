-- ==========================================================================================
-- 2017-11-14 改寫新法務計算
-- 2014/03/31 增加C/CI,CE,CF轉催繳記錄
-- 2014/02/10 增加C/C0轉催繳記錄
-- 2013/12/27 增加V,J轉催繳記錄
-- 2013-06-05 增加C/C8 勾選完成後轉催繳記錄
-- 2013-05-23 增加C/C5~CJ and F/F1~F5 勾選完成後轉催繳記錄
-- 2012/07/24 違約金大於0且小餘200 顯示為200
-- 02/20/11 KC: '發出'改為-->'完成'
-- 01/11/07 KC: bug for NULL push_note (cause: doc_no, court_code NULL)
-- 01/06/07 KC: 新增 C6債證增加案號及法院 (send @wk_doc_no, @wk_court_code)
-- 10/06/06 KC: 新增處理 law_code F
-- 12/22/05 KC: 法務事件轉到催繳記錄
-- ==========================================================================================
CREATE	PROCEDURE [kcsd].[p_kc_mailsend_sub]
	@pm_case_no		VARCHAR(10) = NULL, 
	@pm_law_code	VARCHAR(2) = NULL, 
	@pm_law_fmt		VARCHAR(4) = NULL,
	@pm_addr_desc	VARCHAR(50) = NULL, 
	@pm_mail_flag	VARCHAR(2) = NULL, 
	@pm_doc_date	DATETIME = NULL,
	@pm_doc_no		VARCHAR(40) = '', 
	@pm_court_code	VARCHAR(10) = '',
	@pm_law_amt		INT = 0,
	@pm_law_date	DATETIME = NULL,
	@pm_updt_user	VARCHAR(20) = NULL, 
	@pm_claims_amt	INT = NULL,
	@pm_value_date	DATETIME = NULL,
	@pm_rate_fee	REAL = NULL,
	@pm_litigation_amt	INT = 0,
	@pm_litigation_amt1	INT = 0
AS
DECLARE	
	@wk_push_note	VARCHAR(200),
	@wk_push_date	DATETIME,
	@wk_push_datec	VARCHAR(20),
	@wk_law_desc	VARCHAR(50),
	@wk_fmt_desc	VARCHAR(50),
	@wk_break_amt	INT,
	@wk_court_name	VARCHAR(40),
	@wk_claims_amt	INT,
	@wk_value_date	DATETIME,
	@wk_rate_fee	INT,
	@wk_area_code	VARCHAR(2),
	@wk_item_no		INT,
	@wk_intr_fee	INT,
	@wk_litigation_amt		INT,
	@wk_litigation_amt1		INT


SELECT @wk_area_code = kc_area_code FROM kcsd.kc_customerloan WHERE kc_case_no = @pm_case_no
SELECT @wk_item_no = max(isnull(kc_item_no,1)) + 1 FROM kcsd.kc_push WHERE kc_case_no = @pm_case_no

/* 寄件成功轉入催繳記錄 */
SELECT	@wk_push_date = GETDATE()
SELECT	@wk_push_datec = CONVERT(VARCHAR(10), GETDATE(),111)

/* 取格式與代碼*/
SELECT @wk_law_desc = ISNULL(Text,'') FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'LawCode' AND IsEnable = 1 AND Value = @pm_law_code
SELECT @wk_fmt_desc = ISNULL(Text,'') FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'LawFmt' AND IsEnable = 1 AND Value = @pm_law_fmt
SELECT @wk_court_name = ISNULL(Text,'') FROM [Zephyr.Sys].dbo.sys_code WHERE CodeType = 'CourtCode' AND IsEnable = 1 AND Value = @pm_court_code

IF	@pm_updt_user IS NULL
	SELECT	@pm_updt_user = USER

IF	@wk_fmt_desc IS NULL
	SELECT	@wk_fmt_desc = '*'

/* 收到公文 */
IF	@pm_doc_date IS NOT NULL AND @pm_law_code <> 'W'
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + '<' + @wk_law_desc + @wk_fmt_desc 	+ '>於' + @wk_push_datec + '收文'
	IF	@pm_doc_no IS NOT NULL
		SELECT	@wk_push_note = @wk_push_note + ' <案號' + @pm_doc_no + '>'
	IF	@wk_court_name IS NOT NULL
		SELECT	@wk_push_note = @wk_push_note + '<法院' + @wk_court_name + '>'

	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())

	RETURN
END

IF	@pm_law_code = 'B'
OR	@pm_law_code = 'D'	/* 12/22/05 New */
OR	@pm_law_code = 'L'
OR	@pm_law_code = 'O'	/* 律師函123*/
OR	@pm_law_code = 'R'	/* 律師函123*/
OR	@pm_law_code = 'U'
OR	@pm_law_code = '4'	/* 律師函4  */
OR	@pm_law_code = '5'	/* 12/22/05 New */
OR	@pm_law_code = 'P'
OR	@pm_law_code = '7'
BEGIN
	SELECT	@wk_break_amt = ISNULL(kc_break_amt2, 0)
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @pm_case_no

	IF @wk_break_amt > 0 AND @wk_break_amt < 200 
		SELECT @wk_break_amt = 200

	SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + '<' + @wk_law_desc + '>'+ CONVERT(varchar(10), @wk_break_amt) + '於' + @wk_push_datec + '完成'

	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())

END

/* 12/22/05 新增 */
ELSE IF	@pm_law_code = 'C'
OR	@pm_law_code = 'E'
OR	@pm_law_code = 'H'
OR	@pm_law_code = 'K'
BEGIN
	IF	@pm_law_fmt = 'C5'
	OR	@pm_law_fmt = 'CA'
	OR	@pm_law_fmt = 'CC'
	OR	@pm_law_fmt = 'CJ'
	OR	@pm_law_fmt = 'C0'
	OR	@pm_law_fmt = 'CI'
	OR	@pm_law_fmt = 'CE'
	OR	@pm_law_fmt = 'CF'
	BEGIN
		SELECT	@wk_claims_amt = ISNULL(@pm_claims_amt, 0),@wk_value_date= ISNULL(@pm_value_date, ''),@wk_rate_fee= ISNULL(@pm_rate_fee, 0)
		SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + '<' + @wk_law_desc + @wk_fmt_desc + '>於' + @wk_push_datec + '完成'
		IF	@wk_court_name IS NOT NULL
			SELECT	@wk_push_note = @wk_push_note + '<法院' + @wk_court_name + '>'
		IF	@wk_claims_amt IS NOT NULL
			SELECT	@wk_push_note = @wk_push_note + '<執行' + CONVERT(varchar(10), @wk_claims_amt)+ '元及'
		IF	@wk_value_date IS NOT NULL
			SELECT	@wk_push_note = @wk_push_note + '自' + CONVERT(varchar(10),  @wk_value_date, 101)+ '起'
		IF	@wk_rate_fee IS NOT NULL
			SELECT	@wk_push_note = @wk_push_note  + CONVERT(varchar(10),@wk_rate_fee)+ '%計息>' 

		INSERT	kcsd.kc_push
				(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())

             END
	ELSE  IF	@pm_law_fmt = 'C8'
	BEGIN
		IF @pm_mail_flag ='Y'
		BEGIN 
			SELECT	@wk_claims_amt = ISNULL(@pm_claims_amt, 0),@wk_value_date= ISNULL(@pm_value_date, ''),@wk_rate_fee= ISNULL(@pm_rate_fee, 0),@wk_litigation_amt = ISNULL(@pm_litigation_amt, 0),@wk_litigation_amt1 = ISNULL(@pm_litigation_amt1, 0) 
			SELECT  @wk_intr_fee = convert(int,Round(((@wk_claims_amt *(@wk_rate_fee*0.01)/365) * (datediff(day,@wk_value_date,@pm_law_date)+1)),0))
			SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + '<寄['+ SUBSTRING(@pm_addr_desc,1,4) +']法扣函>本金' + CONVERT(varchar(10), @wk_claims_amt)+','
			SELECT	@wk_push_note = @wk_push_note + '起息日' + CONVERT(varchar(10),  @wk_value_date, 111) +','
			SELECT	@wk_push_note = @wk_push_note  + '利率' + CONVERT(varchar(10),@wk_rate_fee) + '%,' 
			SELECT	@wk_push_note = @wk_push_note + '利息' + CONVERT(varchar(10), @wk_intr_fee) + ',' 
			SELECT	@wk_push_note = @wk_push_note + '訴訟費' + CONVERT(varchar(10), @wk_litigation_amt + @wk_litigation_amt1) + ','
			SELECT	@wk_push_note = @wk_push_note + '總計' + CONVERT(varchar(10), @wk_claims_amt + @wk_intr_fee + @wk_litigation_amt + @wk_litigation_amt1) + '元' 
			INSERT	kcsd.kc_push
					(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
			VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())
		END
             END
	ELSE
	BEGIN
		SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + '<' + @wk_law_desc + @wk_fmt_desc + '>於' + @wk_push_datec + '完成'
		INSERT	kcsd.kc_push
				(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())
	END
END

ELSE IF	@pm_law_code = 'Q' OR @pm_law_code = 'T'
BEGIN
	IF	@pm_mail_flag = 'Y'
	BEGIN
		SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + + '<' + @wk_law_desc + '>' 	+'於' + @wk_push_datec + '發出至' + @pm_addr_desc
		INSERT	kcsd.kc_push
				(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())
	END
END

ELSE IF	@pm_law_code = 'F'
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + @pm_updt_user + + '<' + @wk_law_desc + @wk_fmt_desc + '>' +'於' + @wk_push_datec + '完成'
	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,@pm_updt_user,GETDATE())
END

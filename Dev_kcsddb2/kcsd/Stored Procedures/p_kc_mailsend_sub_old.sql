-- ==========================================================================================
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
CREATE          PROCEDURE [kcsd].[p_kc_mailsend_sub_old]
	@pm_case_no varchar(10)=NULL, @pm_law_code varchar(2)=NULL, @pm_law_fmt varchar(4)=NULL,
	@pm_addr_desc varchar(50)=NULL, @pm_mail_flag varchar(2)=NULL, @pm_doc_date datetime=NULL,
	@pm_doc_no varchar(40)='', @pm_court_code varchar(10)='',@pm_law_amt INT=0,@pm_law_date datetime=NULL
AS
DECLARE	@wk_push_note	varchar(200),
	@wk_push_date	datetime,
	@wk_push_datec	varchar(20),
	@wk_law_desc	varchar(50),
	@wk_fmt_desc	varchar(50),
	@wk_break_amt	int,
	@wk_court_name	varchar(40),
	@wk_claims_amt	int,
	@wk_value_date	datetime,
	@wk_rate_fee		int,
	@wk_area_code	varchar(2),
	@wk_item_no		smallint


SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where kc_case_no =@pm_case_no
SELECT @wk_item_no = max(isnull(kc_item_no,1))+1 from kcsd.kc_push where kc_case_no =@pm_case_no

/* 寄件成功轉入催繳記錄 */
SELECT	@wk_push_date = CONVERT(varchar(2), DATEPART(month,GETDATE()) ) + '/' +	CONVERT(varchar(2), DATEPART(day,GETDATE()) ) + '/' + CONVERT(varchar(4), DATEPART(year,GETDATE()) )
SELECT	@wk_push_datec = CONVERT(varchar(2), DATEPART(month,GETDATE()) ) + '/' +	CONVERT(varchar(2), DATEPART(day,GETDATE()) ) + '/' + CONVERT(varchar(4), DATEPART(year,GETDATE()) )

/* Law desc & Format*/
SELECT @wk_law_desc = kc_law_desc FROM kcsd.kc_lawcode WHERE kc_law_code = @pm_law_code
SELECT @wk_fmt_desc = kc_fmt_desc FROM kcsd.kct_lawformat WHERE kc_law_fmt = @pm_law_fmt
SELECT @wk_court_name = ISNULL(kc_court_name, '') FROM kcsd.kct_court WHERE kc_court_code = @pm_court_code

IF	@wk_fmt_desc IS NULL
	SELECT	@wk_fmt_desc = '*'

/* 收到公文 */
IF	@pm_doc_date IS NOT NULL and @pm_law_code <>'W'
BEGIN

	SELECT	@wk_push_datec = CONVERT(varchar(2), DATEPART(month,@pm_doc_date) ) + '/' +
		CONVERT(varchar(2), DATEPART(day,@pm_doc_date) ) + '/' +
		CONVERT(varchar(4), DATEPART(year,@pm_doc_date) )

	SELECT	@wk_push_note = '[系統]: ' + USER + '<' + @wk_law_desc + @wk_fmt_desc
				+ '>於' + @wk_push_datec + '收文'
	IF	@pm_doc_no IS NOT NULL
		SELECT	@wk_push_note = @wk_push_note + ' <案號' + @pm_doc_no + '>'
	IF	@wk_court_name IS NOT NULL
		SELECT	@wk_push_note = @wk_push_note + '<法院' + @wk_court_name + '>'

	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())

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
BEGIN
	SELECT	@wk_break_amt = ISNULL(kc_break_amt2, 0)
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @pm_case_no

	IF @wk_break_amt > 0 AND @wk_break_amt < 200 
		SELECT @wk_break_amt = 200

	SELECT	@wk_push_note = '[系統]: ' + USER + '<' + @wk_law_desc + '>'+ CONVERT(varchar(10), @wk_break_amt) + '於' + @wk_push_datec + '完成'

	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())

END

/* 12/22/05 新增 */
IF	@pm_law_code = 'C'
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
		SELECT	@wk_claims_amt = ISNULL(kc_claims_amt, 0),@wk_value_date= ISNULL(kc_value_date, ''),@wk_rate_fee= ISNULL(kc_rate_name, 0)  FROM kcsd.kc_customerloan,kcsd.kct_lawrate  WHERE  kcsd.kc_customerloan.kc_rate_fee = kcsd.kct_lawrate.kc_rate_code AND kc_case_no = @pm_case_no

		SELECT	@wk_push_note = '[系統]: ' + USER + '<' + @wk_law_desc + @wk_fmt_desc + '>於' + @wk_push_datec + '完成'
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
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())

             END
	ELSE  IF	@pm_law_fmt = 'C8'
	BEGIN
		IF @pm_mail_flag ='Y'
		BEGIN 
			SELECT	@wk_claims_amt = ISNULL(kc_claims_amt, 0),@wk_value_date= ISNULL(kc_value_date, ''),@wk_rate_fee= ISNULL(kc_rate_name, 0)  FROM kcsd.kc_customerloan,kcsd.kct_lawrate  WHERE  kcsd.kc_customerloan.kc_rate_fee = kcsd.kct_lawrate.kc_rate_code AND kc_case_no = @pm_case_no
			SELECT	@wk_push_note = '[系統]: ' + USER + '<寄['+ SUBSTRING(@pm_addr_desc,1,4) +']法扣函>本金' + CONVERT(varchar(10), @wk_claims_amt)+','
			SELECT	@wk_push_note = @wk_push_note + '起息日' + CONVERT(varchar(10),  @wk_value_date, 101) +','
			SELECT	@wk_push_note = @wk_push_note  + '利率' + CONVERT(varchar(10),@wk_rate_fee)+ '%,' 
			SELECT	@wk_push_note = @wk_push_note + '本利計' + CONVERT(varchar(100), @wk_claims_amt + convert(int,Round(((@wk_claims_amt *(@wk_rate_fee*0.01)/365) * (datediff(day,@wk_value_date,@pm_law_date)+1)),0)))+ ' ,' 
			SELECT	@wk_push_note = @wk_push_note + '訴訟費' + CONVERT(varchar(10), ISNULL(@pm_law_amt,0))+ '元'
			INSERT	kcsd.kc_push
					(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
			VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
		END
             END
	ELSE
	BEGIN
		SELECT	@wk_push_note = '[系統]: ' + USER + '<' + @wk_law_desc + @wk_fmt_desc + '>於' + @wk_push_datec + '完成'
		INSERT	kcsd.kc_push
				(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
	END
END

ELSE IF	@pm_law_code = 'Q'
BEGIN
	IF	@pm_mail_flag = 'Y'
	BEGIN
		SELECT	@wk_push_note = '[系統]: ' + USER + + '<' + @wk_law_desc + '>' 	+'於' + @wk_push_datec + '發出至' + @pm_addr_desc
		INSERT	kcsd.kc_push
				(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
	END
END
ELSE IF	@pm_law_code = 'F'
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + USER + + '<' + @wk_law_desc + @wk_fmt_desc + '>' +'於' + @wk_push_datec + '完成'
	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
END
ELSE IF	@pm_law_code = 'V'
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + USER + + '<' + @wk_law_desc +'>確認無法處理，轉協商部'
	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
END
ELSE IF	@pm_law_code = 'J'
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + USER + + '<' + @wk_law_desc +'>車已歸還' + @pm_doc_no
	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
END
ELSE IF	@pm_law_code = 'W' and @pm_law_fmt is null
BEGIN
	SELECT	@wk_push_note = '[系統]: ' + USER + '<' + @wk_law_desc +'>於' + CONVERT(varchar(10),  @pm_doc_date, 101) + '歸責' + CONVERT(varchar(10), @pm_law_amt)+ '元 <案號' + @pm_doc_no + '>' 	
	INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@pm_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
END

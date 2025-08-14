-- ==========================================================================================
-- 12/09/06 KC: 新增處理代碼H% 戶籍謄本
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_mailreject_sub]
	@pm_case_no varchar(10)=NULL, @pm_addr_desc varchar(50)=NULL,
	@pm_law_code varchar(2)=NULL,
	@pm_mail_flag varchar(2)=NULL, @pm_mail_type varchar(2)=NULL,
	@pm_doc_date datetime=NULL
AS
DECLARE	@wk_push_note	varchar(200),
	@wk_law_desc	varchar(100),
	@wk_rej_desc	varchar(50),
	@wk_mail_desc	varchar(50),
	@wk_push_date	datetime,
	@wk_area_code	varchar(2)

IF	@pm_case_no IS NULL
OR	@pm_law_code IS NULL
OR	@pm_mail_flag IS NULL
	RETURN

SELECT	@wk_push_date = CONVERT(varchar(2), DATEPART(month,GETDATE()) ) + '/' +
	CONVERT(varchar(2), DATEPART(day,GETDATE()) ) + '/' +
	CONVERT(varchar(4), DATEPART(year,GETDATE()) )
SELECT	@wk_area_code = kc_area_code FROM kcsd.kc_customerloan WHERE kc_case_no = @pm_case_no

-- 戶籍謄本
IF	@pm_mail_flag LIKE 'H%'
BEGIN
	/* Rej desc */
	SELECT	@wk_rej_desc = kc_rej_desc
	FROM	kcsd.kct_mailreject
	WHERE	kc_rej_code = @pm_mail_flag

	SELECT	@wk_push_note = ISNULL(@pm_doc_date, '*') + ' 謄本完成, ' +
		ISNULL(@wk_rej_desc, '*')
	INSERT	kcsd.kc_push
		(kc_case_no, kc_push_date, kc_push_note, kc_effe_flag, kc_updt_user, kc_updt_date, kc_area_code)
	VALUES	(@pm_case_no, @wk_push_date, @wk_push_note, 0, USER, GETDATE(), @wk_area_code)
	
	RETURN
END

-- 戶籍謄本(單獨,單獨戶長等)
IF	@pm_mail_flag <> 'Y'
AND	@pm_mail_flag <> 'N'
BEGIN
	/* Law desc*/
	SELECT	@wk_law_desc = kc_law_desc
	FROM	kcsd.kc_lawcode
	WHERE	kc_law_code = @pm_law_code

	/* Rej desc */
	SELECT	@wk_rej_desc = kc_rej_desc
	FROM	kcsd.kct_mailreject
	WHERE	kc_rej_code = @pm_mail_flag

	/* Mail desc */
	SELECT	@wk_mail_desc = kc_mail_desc
	FROM	kcsd.kct_mailtype
	WHERE	kc_mail_type = @pm_mail_type

	SELECT	@wk_push_note = ISNULL(@pm_addr_desc, '*') + ',' +
		ISNULL(@wk_mail_desc, '*') + ',' +
		ISNULL(@wk_law_desc, '*') + ',' +
		ISNULL(@wk_rej_desc, '*')
	INSERT	kcsd.kc_push
		(kc_case_no, kc_push_date, kc_push_note, kc_effe_flag, kc_updt_user, kc_updt_date, kc_area_code)
	VALUES	(@pm_case_no, @wk_push_date, @wk_push_note, 0, USER, GETDATE(), @wk_area_code)
END

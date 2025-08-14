CREATE TABLE [kcsd].[kc_dailytrans(停用)] (
    [kc_comp_char]  VARCHAR (1)   NOT NULL,
    [kc_item_date]  DATETIME      NOT NULL,
    [kc_item_no]    INT           NULL,
    [kc_item_type]  VARCHAR (2)   NOT NULL,
    [kc_item_name]  VARCHAR (50)  NULL,
    [kc_item_in]    INT           NOT NULL,
    [kc_item_out]   INT           NOT NULL,
    [kc_indi_name]  VARCHAR (12)  NULL,
    [kc_acc_code]   VARCHAR (2)   NULL,
    [kc_chk_flag]   BIT           NOT NULL,
    [kc_chk_date]   SMALLDATETIME NULL,
    [kc_chk_no]     VARCHAR (7)   NULL,
    [kc_comp_ymd]   VARCHAR (7)   NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_comp_char2] VARCHAR (2)   NULL,
    [kc_comp_ymd2]  VARCHAR (8)   NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_dailytrans_2]
    ON [kcsd].[kc_dailytrans(停用)]([kc_indi_name] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_dailytrans_3]
    ON [kcsd].[kc_dailytrans(停用)]([kc_comp_char2] ASC, [kc_item_date] ASC, [kc_item_no] ASC);


GO



CREATE   TRIGGER [kcsd].[t_kc_dailytrans_i]
ON [kcsd].[kc_dailytrans(停用)] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_comp_char	varchar(2),
	@wk_item_date	datetime,
	@wk_item_no	int,
	@wk_item_type	varchar(2),
	@wk_item_out	int,
	@wk_item_name	varchar(50),
	@wk_rece_name	varchar(30),
	@wk_chk_date	datetime,	

	/* ╗╚ªµªs┤┌Ñ╬ */
	@wk_acc_code	varchar(2),
	@wk_chk_flag	bit,

	@wk_chk_max	varchar(7),	/* ñõ▓╝Ñ╬ */
	@wk_chk_no	varchar(7)
	

SELECT	@wk_comp_char = NULL, @wk_item_date = NULL, @wk_item_no = NULL,
	@wk_acc_code = NULL, @wk_chk_flag = NULL, @wk_rece_name = NULL,
	@wk_chk_date = NULL

SELECT	@wk_comp_char = kc_comp_char2,
	@wk_item_date = kc_item_date, @wk_item_no = kc_item_no,
	@wk_item_type = kc_item_type, @wk_item_out = kc_item_out,
	@wk_item_name = kc_item_name,
	@wk_acc_code = kc_acc_code, @wk_chk_flag = kc_chk_flag,
	@wk_chk_date = kc_chk_date
FROM	inserted

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no),0)+1
	FROM	kcsd.kc_dailytrans
	WHERE	kc_comp_char2 = @wk_comp_char
	AND	kc_item_date = @wk_item_date

	UPDATE	kcsd.kc_dailytrans
	SET	kc_item_no = @wk_item_no,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_comp_char2 = @wk_comp_char
	AND	kc_item_date = @wk_item_date
	AND	kc_item_no IS NULL
END


/* ¡p║Ô╗╚ªµªsñJ┤┌ÂÁ */
/* ┬┬¬®, 8/19/2000 ░▒ñ¯¿¤Ñ╬

IF	@wk_item_type = '79'
BEGIN
	SELECT	@wk_acc_code = MAX(kc_acc_code)
	FROM	kcsd.kc_syscontrol

	INSERT	kcsd.kc_banktrans
		(kc_acc_code, kc_bank_date, 
		kc_depo_amt, kc_wdrw_amt, kc_trans_memo)

	VALUES	(@wk_acc_code,@wk_item_date,
		@wk_item_out, 0, @wk_item_name)
END
*/

IF	@wk_acc_code <> NULL
BEGIN
	/* ÑÊªs */
	IF @wk_chk_flag = 0
	BEGIN
		INSERT	kcsd.kc_banktrans
			(kc_acc_code, kc_bank_date, 
			kc_depo_amt, kc_wdrw_amt, kc_trans_memo)
		VALUES	(@wk_acc_code,@wk_item_date,
			@wk_item_out, 0, @wk_item_name)
	END
	/* ▓úÑ═ñõ▓╝¼÷┐² (B3) */
	ELSE	
	BEGIN
		IF	@wk_chk_date IS NULL
		BEGIN
			RAISERROR ('支票資料不齊全 (B3)',18,2) WITH SETERROR
			ROLLBACK TRANSACTION
			RETURN
		END


		SELECT	@wk_chk_max = ISNULL(MAX(kc_chk_no),'0000000')
		FROM	kcsd.kc_check
		WHERE	kc_acc_code = @wk_acc_code

		SELECT	@wk_chk_no = RIGHT('0000000'+LTRIM(RTRIM(CONVERT(char,CONVERT(int,@wk_chk_max)+1 ))),7)
		SELECT	@wk_rece_name = RTRIM(SUBSTRING(@wk_item_name,1,30))
			
		INSERT	kcsd.kc_check
			(kc_acc_code, kc_chk_no, kc_write_date, kc_pay_date,
			kc_pay_amt, kc_rece_name,
			kc_chk_stat,kc_chk_type, kc_chk_memo)
		VALUES	(@wk_acc_code, @wk_chk_no, @wk_item_date, @wk_chk_date, 
			@wk_item_out, @wk_rece_name,
			'W', @wk_item_type, @wk_item_name)

		UPDATE	kcsd.kc_dailytrans
		SET	kc_chk_no = @wk_chk_no
		WHERE	kc_comp_char2 = @wk_comp_char
		AND	kc_item_date = @wk_item_date
		AND	kc_item_no = @wk_item_no
	END
END





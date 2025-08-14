CREATE TABLE [kcsd].[kc_checkconvraw] (
    [交易日期]         SMALLDATETIME NULL,
    [票據號碼]         VARCHAR (20)  NULL,
    [支出金額]         INT           NULL,
    [kc_conv_no]   INT           NULL,
    [kc_updt_user] VARCHAR (50)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_checkconvraw]
    ON [kcsd].[kc_checkconvraw]([kc_conv_no] ASC);


GO
CREATE TRIGGER [kcsd].[t_kc_checkconvraw_i] ON [kcsd].[kc_checkconvraw] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_conv_no	int

SELECT	@wk_conv_no = NULL

SELECT	@wk_conv_no = kc_conv_no
FROM	inserted

IF	@wk_conv_no IS NULL
BEGIN
	SELECT	@wk_conv_no = ISNULL(MAX(kc_conv_no), 0) + 1
	FROM	kcsd.kc_checkconvraw

	UPDATE	kcsd.kc_checkconvraw
	SET	kc_conv_no = @wk_conv_no,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_conv_no IS NULL
END

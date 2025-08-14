CREATE TABLE [kcsd].[kc_convraw] (
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    [kc_conv_no]   INT           NULL,
    [日期]           VARCHAR (30)  NULL,
    [摘要]           VARCHAR (30)  NULL,
    [支出]           VARCHAR (30)  NULL,
    [存入]           INT           NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_convraw]
    ON [kcsd].[kc_convraw]([kc_conv_no] ASC);


GO



CREATE   TRIGGER [kcsd].[t_kc_convraw_i] ON [kcsd].[kc_convraw] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_conv_no	int

SELECT	@wk_conv_no = NULL

SELECT	@wk_conv_no = kc_conv_no
FROM	inserted

IF	@wk_conv_no IS NULL
BEGIN
	SELECT	@wk_conv_no = ISNULL(MAX(kc_conv_no), 0) + 1
	FROM	kcsd.kc_convraw

	UPDATE	kcsd.kc_convraw
	SET	kc_conv_no = @wk_conv_no
	WHERE	kc_conv_no IS NULL
END




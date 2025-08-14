CREATE TABLE [kcsd].[kc_caseloan(停用)] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_item_no]   SMALLINT      NOT NULL,
    [kc_item_date] SMALLDATETIME NOT NULL,
    [kc_item_in]   INT           NOT NULL,
    [kc_item_out]  INT           NOT NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_caseloan_1__38] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);


GO


CREATE  TRIGGER [kcsd].[t_kc_caseloan_iu] ON [kcsd].[kc_caseloan(停用)] 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_item_no	int,
	@wk_item_oldno	int

SELECT	@wk_case_no = kc_case_no,
	@wk_item_oldno = kc_item_no
FROM	inserted

IF	@wk_item_oldno = 0
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no)+1, 0)
	FROM	kcsd.kc_caseloan
	WHERE	kc_case_no = @wk_case_no
END
ELSE
	SELECT	@wk_item_no = @wk_item_oldno

/* log change */
UPDATE	kcsd.kc_caseloan
SET	kc_updt_user = USER, kc_updt_date = GETDATE(),
	kc_item_no = @wk_item_no
WHERE	kc_case_no = @wk_case_no
AND	kc_item_no = @wk_item_oldno



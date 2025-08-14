CREATE TABLE [kcsd].[kc_insurance_import] (
    [kc_insu_no]    VARCHAR (8)   NULL,
    [來源]            VARCHAR (2)   NULL,
    [保單種類]          VARCHAR (2)   NULL,
    [客戶姓名]          VARCHAR (10)  NULL,
    [發照日期]          VARCHAR (10)  NULL,
    [kc_licn_date]  SMALLDATETIME NULL,
    [廠牌]            VARCHAR (2)   NULL,
    [型號]            VARCHAR (50)  NULL,
    [引擎號碼]          VARCHAR (30)  NULL,
    [牌照號碼]          VARCHAR (10)  NULL,
    [承保金額]          INT           NULL,
    [保險費]           SMALLINT      NULL,
    [實收保費]          SMALLINT      NULL,
    [收款方式]          VARCHAR (1)   NULL,
    [身份證號]          VARCHAR (10)  NULL,
    [出生日期]          VARCHAR (10)  NULL,
    [kc_birth_date] SMALLDATETIME NULL,
    [車行]            VARCHAR (30)  NULL,
    [施工方式]          VARCHAR (1)   NULL,
    [施工人員]          VARCHAR (30)  NULL,
    [理賠方式]          VARCHAR (2)   NULL,
    [保卡號碼]          VARCHAR (9)   NULL,
    [保卡種類]          VARCHAR (2)   NULL,
    [戶籍地址]          VARCHAR (100) NULL,
    [kc_impo_no]    INT           NULL,
    [kc_lock_date]  SMALLDATETIME NULL,
    [投保日期]          VARCHAR (10)  NULL,
    [kc_fax_date]   SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_kc_insurance_import]
    ON [kcsd].[kc_insurance_import]([kc_impo_no] ASC);


GO
CREATE TRIGGER [kcsd].[t_kc_insurance_import_i] ON [kcsd].[kc_insurance_import]
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_impo_no	int

SELECT	@wk_impo_no = NULL

SELECT	@wk_impo_no = kc_impo_no
FROM	inserted

IF	@wk_impo_no IS NULL
BEGIN
	SELECT	@wk_impo_no = ISNULL(MAX(kc_impo_no), 0) + 1
	FROM	kcsd.kc_insurance_import

	UPDATE	kcsd.kc_insurance_import
	SET	kc_impo_no = @wk_impo_no
	WHERE	kc_impo_no IS NULL
END

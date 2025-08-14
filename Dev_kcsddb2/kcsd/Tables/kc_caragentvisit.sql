CREATE TABLE [kcsd].[kc_caragentvisit] (
    [kc_agent_code] VARCHAR (30)  NOT NULL,
    [kc_visit_date] SMALLDATETIME NOT NULL,
    [kc_sales_code] VARCHAR (10)  NOT NULL,
    [kc_visit_note] VARCHAR (200) NOT NULL,
    [kc_item_no]    SMALLINT      NULL,
    [kc_crdt_user]  VARCHAR (4)   NULL,
    [kc_crdt_date]  SMALLDATETIME NULL,
    [kc_is_cfm]     INT           CONSTRAINT [DF_kc_caragentvisit_kc_is_cfm] DEFAULT ((0)) NOT NULL,
    [kc_cfm_user]   VARCHAR (5)   NULL,
    [kc_updt_user]  VARCHAR (20)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_caragentvisit]
    ON [kcsd].[kc_caragentvisit]([kc_agent_code] ASC, [kc_visit_date] ASC, [kc_item_no] ASC);


GO
-- =============================================
-- 04/26/08 KC: Log Trigger
-- =============================================
CREATE  TRIGGER [kcsd].[t_kc_caragentvisit_iu] ON kcsd.kc_caragentvisit
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_agent_code	varchar(30),
	@wk_visit_date	datetime,
	@wk_item_no	int,
	@wk_area_code	varchar(4)

SELECT	@wk_agent_code = kc_agent_code, @wk_visit_date = kc_visit_date,
	@wk_item_no = kc_item_no
FROM	inserted

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
	FROM	kcsd.kc_caragentvisit
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_visit_date = @wk_visit_date

	-- push 避免衝突: 若在HQ輸入非HQ催繳記錄則 no+10
	-- visit避免衝突: 若在非HQ輸入, 則 no+10
	IF	@@servername <> 'DYS01' and @@servername <> 'DYAP01'
		SELECT	@wk_item_no = @wk_item_no + 10

	UPDATE	kcsd.kc_caragentvisit
	SET	kc_item_no = @wk_item_no,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_visit_date = @wk_visit_date
	AND	kc_item_no IS NULL
END
ELSE
BEGIN
	UPDATE	kcsd.kc_caragentvisit
	SET	kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_agent_code = @wk_agent_code
	AND	kc_visit_date = @wk_visit_date
	AND	kc_item_no = @wk_item_no
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 核准 ( 25.07.02 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentvisit', @level2type = N'COLUMN', @level2name = N'kc_is_cfm';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 簽核人員 ( 25.07.02 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentvisit', @level2type = N'COLUMN', @level2name = N'kc_cfm_user';


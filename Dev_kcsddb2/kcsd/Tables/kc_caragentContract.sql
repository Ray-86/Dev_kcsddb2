CREATE TABLE [kcsd].[kc_caragentContract] (
    [kc_agent_code]    VARCHAR (10)  NOT NULL,
    [kc_item_no]       INT           NOT NULL,
    [kc_contract_type] NVARCHAR (30) NOT NULL,
    [kc_contract_date] DATE          NOT NULL,
    [kc_partyB]        NVARCHAR (30) NOT NULL,
    [CreatePerson]     VARCHAR (10)  NULL,
    [CreateDate]       DATETIME      CONSTRAINT [DF_kc_caragentContract_CreateDate] DEFAULT (getdate()) NULL,
    [kc_updt_user]     VARCHAR (10)  NULL,
    [kc_updt_date]     DATETIME      NULL,
    CONSTRAINT [PK_kc_caragentContract] PRIMARY KEY CLUSTERED ([kc_agent_code] ASC, [kc_item_no] ASC),
    CONSTRAINT [FK_kc_caragentContract_kc_caragentContract] FOREIGN KEY ([kc_agent_code], [kc_item_no]) REFERENCES [kcsd].[kc_caragentContract] ([kc_agent_code], [kc_item_no])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'經銷商', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_agent_code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'序號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_item_no';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'契約書類型', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_contract_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'簽約日期', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_contract_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'公司別 (乙方)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_partyB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'CreatePerson';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'CreateDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_updt_user';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragentContract', @level2type = N'COLUMN', @level2name = N'kc_updt_date';


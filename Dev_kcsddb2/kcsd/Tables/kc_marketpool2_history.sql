CREATE TABLE [kcsd].[kc_marketpool2_history] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [kc_case_no]   VARCHAR (10) NOT NULL,
    [kc_case_stat] VARCHAR (1)  NOT NULL,
    [kc_updt_user] VARCHAR (10) NULL,
    [kc_updt_date] DATETIME     NULL,
    [DeleteDate]   DATETIME     CONSTRAINT [DF_kc_marketpool2_history_DeleteDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_kc_marketpool2_history] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'識別碼', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'客編', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'kc_case_no';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'狀態, A (待委派) / B (已委派)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'kc_case_stat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'kc_updt_user';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'kc_updt_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'刪除時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_marketpool2_history', @level2type = N'COLUMN', @level2name = N'DeleteDate';


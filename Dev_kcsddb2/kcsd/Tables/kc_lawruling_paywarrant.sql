CREATE TABLE [kcsd].[kc_lawruling_paywarrant] (
    [kc_file_no]       VARCHAR (10) NOT NULL,
    [kc_file_name]     VARCHAR (20) NOT NULL,
    [kc_law_date]      DATE         CONSTRAINT [DF_kc_lawruling_paywarrant_kc_law_date] DEFAULT (getdate()) NOT NULL,
    [kc_law_code]      VARCHAR (1)  CONSTRAINT [DF_kc_lawruling_paywarrant_kc_law_code] DEFAULT ('C') NOT NULL,
    [kc_law_fmt]       VARCHAR (4)  CONSTRAINT [DF_kc_lawruling_paywarrant_kc_law_fmt] DEFAULT ('CY') NOT NULL,
    [kc_court_code]    VARCHAR (10) NOT NULL,
    [kc_case_no]       VARCHAR (10) NOT NULL,
    [kc_doc_no]        VARCHAR (40) NOT NULL,
    [kc_doc_type]      VARCHAR (20) NOT NULL,
    [kc_perm_flag]     VARCHAR (1)  NOT NULL,
    [kc_perm_flag1]    VARCHAR (1)  NOT NULL,
    [kc_perm_flag2]    VARCHAR (1)  NOT NULL,
    [kc_archived_flag] VARCHAR (1)  CONSTRAINT [DF_kc_lawruling_paywarrant_kc_fin_flag1] DEFAULT ('N') NOT NULL,
    [kc_fin_flag]      VARCHAR (1)  CONSTRAINT [DF_kc_lawruling_paywarrant_kc_fin_flag] DEFAULT ('N') NOT NULL,
    [CreatePerson]     VARCHAR (20) NOT NULL,
    [CreateDate]       DATETIME     CONSTRAINT [DF_kc_lawruling_paywarrant_CreateDate] DEFAULT (getdate()) NOT NULL,
    [kc_updt_user]     VARCHAR (20) NULL,
    [kc_updt_date]     DATETIME     NULL,
    CONSTRAINT [PK_kc_paywarrant_1] PRIMARY KEY CLUSTERED ([kc_file_no] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'序號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_file_no';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'圖片檔名', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_file_name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'日期', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_law_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'代碼', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_law_code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'格式', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_law_fmt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'法院', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_court_code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'客戶編號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_case_no';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'法院案號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_doc_no';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'文件類別', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_doc_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'本人', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_perm_flag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'保1', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_perm_flag1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'保2', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_perm_flag2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'歸檔完成', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_archived_flag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'拋轉完成', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_fin_flag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'CreatePerson';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立日期', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'CreateDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_updt_user';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_lawruling_paywarrant', @level2type = N'COLUMN', @level2name = N'kc_updt_date';


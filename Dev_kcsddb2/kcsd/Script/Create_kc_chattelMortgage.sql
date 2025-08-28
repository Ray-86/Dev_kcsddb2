CREATE TABLE [kcsd].[kc_chattelMortgage](
	[kc_file_no] VARCHAR(10) NOT NULL,
	[kc_file_name] VARCHAR(20) NOT NULL,
	[kc_cp_no] VARCHAR(10) NOT NULL,
	[kc_archived_flag] VARCHAR(1) CONSTRAINT [DF_kc_chattelMortagage_kc_archieved_flag] DEFAULT ('N') NOT NULL,
	[kc_fin_flag] VARCHAR(1) CONSTRAINT [DF_kc_chattelMortagage_kc_fin_flag] DEFAULT ('N') NOT NULL,
    [CreatePerson] VARCHAR (20) NOT NULL,
    [CreateDate] DATETIME CONSTRAINT [DF_kc_chattelMortagage_CreateDate] DEFAULT (getdate()) NOT NULL,
    [kc_updt_user] VARCHAR (20) NULL,
    [kc_updt_date] DATETIME NULL,
	CONSTRAINT [PK_kc_chattelMortgage] PRIMARY KEY CLUSTERED ([kc_file_no] ASC)
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'序號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_file_no';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'圖片檔名', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_file_name';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CP編號', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_cp_no';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'歸檔完成', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_archived_flag';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'拋轉完成', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_fin_flag';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'CreatePerson';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'建立日期', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'CreateDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新人員', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_updt_user';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'更新時間', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_chattelMortgage', @level2type = N'COLUMN', @level2name = N'kc_updt_date';

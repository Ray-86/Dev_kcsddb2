CREATE TABLE [kcsd].[z_InVoicePlatForm] (
    [id]                    INT             IDENTITY (1, 1) NOT NULL,
    [ban]                   NVARCHAR (8)    NULL,
    [token]                 NVARCHAR (1000) NULL,
    [nonce]                 NVARCHAR (16)   NULL,
    [member_no]             NVARCHAR (11)   NULL,
    [id_no]                 NVARCHAR (10)   NULL,
    [time]                  DATETIME        NULL,
    [brand_code]            NVARCHAR (2)    NULL,
    [brand_name]            NVARCHAR (50)   NULL,
    [result_flag]           NVARCHAR (1)    NULL,
    [case_no]               NVARCHAR (10)   NULL,
    [type]                  NVARCHAR (20)   NULL,
    [card_type]             NVARCHAR (50)   NULL,
    [small_large_returnUrl] NVARCHAR (1500) NULL,
    [CompanyID]             NVARCHAR (10)   NULL,
    [call_gov_url_StoL]     NVARCHAR (1500) NULL,
    CONSTRAINT [PK_z_InVoicePlatForm] PRIMARY KEY CLUSTERED ([id] ASC)
);


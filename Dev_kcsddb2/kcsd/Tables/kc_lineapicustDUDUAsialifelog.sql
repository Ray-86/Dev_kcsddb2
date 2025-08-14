CREATE TABLE [kcsd].[kc_lineapicustDUDUAsialifelog] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [kc_line_id]   VARCHAR (33)  NULL,
    [kc_case_no]   VARCHAR (10)  NULL,
    [kc_perd_no]   VARCHAR (10)  NULL,
    [kc_perd_fee]  VARCHAR (500) NULL,
    [CreatePerson] VARCHAR (20)  NULL,
    [CreateDate]   DATETIME      NULL,
    [kc_updt_user] VARCHAR (20)  NULL,
    [kc_updt_date] DATETIME      NULL,
    CONSTRAINT [PK_kc_lineapicustDUDUXmarketlog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


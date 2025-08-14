CREATE TABLE [kcsd].[ConvertCheck] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [ConvertDate]      VARCHAR (30)  NOT NULL,
    [ConvertCheckno]   VARCHAR (30)  NOT NULL,
    [ConvertAmt]       INT           NOT NULL,
    [kc_wdrw_date]     DATETIME      NULL,
    [kc_write_date]    DATETIME      NULL,
    [kc_rece_name]     VARCHAR (100) NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     DATETIME      NULL,
    [kc_recorded_user] VARCHAR (20)  NULL,
    [kc_recorded_date] DATETIME      NULL,
    CONSTRAINT [PK_ConvertCheck] PRIMARY KEY CLUSTERED ([ID] ASC)
);


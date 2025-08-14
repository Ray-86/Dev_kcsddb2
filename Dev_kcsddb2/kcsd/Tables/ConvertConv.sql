CREATE TABLE [kcsd].[ConvertConv] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [ConvertDate]      VARCHAR (30)  NOT NULL,
    [ConvertData]      VARCHAR (30)  NOT NULL,
    [ConvertExp]       VARCHAR (30)  NOT NULL,
    [ConvertAmt]       INT           NOT NULL,
    [kc_case_no]       VARCHAR (10)  NULL,
    [kc_pay_date]      SMALLDATETIME NULL,
    [kc_pay_fee]       INT           NULL,
    [kc_break_fee]     INT           NULL,
    [kc_memo]          VARCHAR (50)  NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_recorded_user] VARCHAR (20)  NULL,
    [kc_recorded_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_ConvertConv] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_convertconv_2]
    ON [kcsd].[ConvertConv]([ConvertDate] ASC, [ConvertData] ASC, [ConvertExp] ASC);


GO
CREATE NONCLUSTERED INDEX [i_convertconv_1]
    ON [kcsd].[ConvertConv]([kc_case_no] ASC, [kc_recorded_date] ASC);


CREATE TABLE [kcsd].[ConvertAtm_member] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [ConvertDate]      VARCHAR (30)  NOT NULL,
    [ConvertData]      VARCHAR (30)  NOT NULL,
    [ConvertExp]       VARCHAR (30)  NOT NULL,
    [ConvertAmt]       INT           NOT NULL,
    [kc_member_no]     VARCHAR (20)  NULL,
    [kc_pay_date]      SMALLDATETIME NULL,
    [kc_pay_fee]       INT           NULL,
    [kc_break_fee]     INT           NULL,
    [kc_break_fee2]    INT           NULL,
    [kc_dudupoint_fee] INT           NULL,
    [kc_memo]          VARCHAR (50)  NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_recorded_user] VARCHAR (20)  NULL,
    [kc_recorded_date] SMALLDATETIME NULL,
    [kc_discount_fee]  INT           NULL,
    [kc_discount_fee2] INT           NULL,
    CONSTRAINT [PK_ConvertAtm_member] PRIMARY KEY CLUSTERED ([ID] ASC)
);


CREATE TABLE [kcsd].[ConvertAsialife] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [kc_list_no]         VARCHAR (30)  NOT NULL,
    [kc_pay_date]        SMALLDATETIME NOT NULL,
    [kc_listpay_fee]     INT           NOT NULL,
    [kc_servicepay_fee]  INT           NOT NULL,
    [kc_servicepay_fee1] INT           NOT NULL,
    [kc_case_no]         VARCHAR (10)  NULL,
    [kc_pay_fee]         INT           NULL,
    [kc_break_fee]       INT           NULL,
    [kc_memo]            VARCHAR (50)  NULL,
    [kc_updt_user]       VARCHAR (20)  NULL,
    [kc_updt_date]       SMALLDATETIME NULL,
    [kc_recorded_user]   VARCHAR (20)  NULL,
    [kc_recorded_date]   SMALLDATETIME NULL,
    CONSTRAINT [PK_ConvertAsialife] PRIMARY KEY CLUSTERED ([ID] ASC)
);


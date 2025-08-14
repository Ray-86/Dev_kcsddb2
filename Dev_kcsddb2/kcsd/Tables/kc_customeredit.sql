CREATE TABLE [kcsd].[kc_customeredit] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_edit_date] SMALLDATETIME NOT NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    [kc_edit_memo] VARCHAR (50)  NULL,
    CONSTRAINT [PK_kc_customeredit] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_edit_date] ASC)
);


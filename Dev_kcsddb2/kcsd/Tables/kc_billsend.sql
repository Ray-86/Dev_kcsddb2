CREATE TABLE [kcsd].[kc_billsend] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_send_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_billsend] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);


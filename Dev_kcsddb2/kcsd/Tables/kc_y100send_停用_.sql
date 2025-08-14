CREATE TABLE [kcsd].[kc_y100send(停用)] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_perd_no]   SMALLINT      NOT NULL,
    [kc_expt_date] SMALLDATETIME NOT NULL,
    [kc_send_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_y100send] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_perd_no] ASC)
);


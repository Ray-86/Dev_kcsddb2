CREATE TABLE [kcsd].[kc_LOCdata] (
    [kc_LOC_no]         VARCHAR (10)  NOT NULL,
    [kc_LOC_date]       DATETIME      NULL,
    [kc_id_no]          VARCHAR (10)  NULL,
    [kc_mobile_no]      VARCHAR (10)  NULL,
    [kc_transaction_pw] VARCHAR (10)  NULL,
    [kc_line_no]        VARCHAR (10)  NULL,
    [kc_curr_addr]      VARCHAR (100) NULL,
    [kc_birth_date]     DATETIME      NULL,
    [kc_further_flag]   VARCHAR (10)  NULL,
    [kc_further_user]   VARCHAR (10)  NULL,
    [kc_further_date]   DATETIME      NULL,
    [kc_LOC_fee]        INT           NULL,
    CONSTRAINT [PK_kc_LOCdata] PRIMARY KEY CLUSTERED ([kc_LOC_no] ASC)
);


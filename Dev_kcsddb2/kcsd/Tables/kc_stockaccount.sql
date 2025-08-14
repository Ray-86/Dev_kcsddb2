CREATE TABLE [kcsd].[kc_stockaccount] (
    [kc_acc_no]     VARCHAR (4)   NOT NULL,
    [kc_acc_name]   VARCHAR (20)  NULL,
    [kc_acc_id]     VARCHAR (10)  NULL,
    [kc_birth_date] DATETIME      NULL,
    [kc_perm_addr]  VARCHAR (50)  NULL,
    [kc_curr_addr]  VARCHAR (50)  NULL,
    [kc_curr_phone] VARCHAR (11)  NULL,
    [kc_acc_memo]   VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_stockaccount] PRIMARY KEY CLUSTERED ([kc_acc_no] ASC)
);


CREATE TABLE [kcsd].[kc_piccsno] (
    [kc_cp_no]    VARCHAR (10)  NOT NULL,
    [ID0K_0_flag] VARCHAR (1)   NULL,
    [ID0K_0_date] SMALLDATETIME NULL,
    [ID0L_0_flag] VARCHAR (1)   NULL,
    [ID0L_0_date] SMALLDATETIME NULL,
    [ID0M_0_flag] VARCHAR (1)   NULL,
    [ID0M_0_date] SMALLDATETIME NULL,
    [ID0K_1_flag] VARCHAR (1)   NULL,
    [ID0K_1_date] SMALLDATETIME NULL,
    [ID0L_1_flag] VARCHAR (1)   NULL,
    [ID0L_1_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_piccsno] PRIMARY KEY CLUSTERED ([kc_cp_no] ASC)
);


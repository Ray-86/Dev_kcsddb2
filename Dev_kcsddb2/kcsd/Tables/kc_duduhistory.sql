CREATE TABLE [kcsd].[kc_duduhistory] (
    [uid]          VARCHAR (10)  NOT NULL,
    [kc_item_no]   INT           NULL,
    [kc_data_type] VARCHAR (20)  NULL,
    [kc_data_old]  VARCHAR (100) NULL,
    [kc_data_new]  VARCHAR (100) NULL,
    [CreatePerson] VARCHAR (10)  NULL,
    [CreateDate]   DATETIME      NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


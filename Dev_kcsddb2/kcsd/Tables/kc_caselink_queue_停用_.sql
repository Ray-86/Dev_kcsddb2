CREATE TABLE [kcsd].[kc_caselink_queue(停用)] (
    [kc_case_no] VARCHAR (10) NOT NULL,
    [kc_cp_no]   VARCHAR (10) NULL,
    CONSTRAINT [PK_kc_caselink_queue] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);


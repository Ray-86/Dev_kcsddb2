CREATE TABLE [kcsd].[kc_caselink(停用)] (
    [kc_link_no]   INT           NOT NULL,
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_updt_user] VARCHAR (20)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_kc_caselink]
    ON [kcsd].[kc_caselink(停用)]([kc_link_no] ASC, [kc_case_no] ASC) WITH (IGNORE_DUP_KEY = ON);


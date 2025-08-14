CREATE TABLE [kcsd].[kct_cfmtemplate] (
    [kc_cfm_type]      NVARCHAR (2)   NOT NULL,
    [kc_cfm_no]        INT            NOT NULL,
    [kc_cfm_desc]      NVARCHAR (200) NOT NULL,
    [kc_cfm_stat]      BIT            NULL,
    [kc_cfm_stat1]     BIT            NULL,
    [kc_template_type] VARCHAR (2)    NULL,
    [kc_cfm_stat2]     BIT            NULL,
    [kc_cfm_stat3]     BIT            NULL,
    [kc_cfm_stat4]     BIT            NULL
);


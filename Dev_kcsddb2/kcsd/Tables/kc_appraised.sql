CREATE TABLE [kcsd].[kc_appraised] (
    [kc_case_no]       VARCHAR (10)  NOT NULL,
    [kc_area_code]     VARCHAR (2)   NOT NULL,
    [kc_item_no]       SMALLINT      NOT NULL,
    [kc_column_no]     SMALLINT      NOT NULL,
    [kc_appraise_date] DATETIME      NOT NULL,
    [kc_target_name]   VARCHAR (10)  NULL,
    [kc_appraise_fee]  INT           NULL,
    [kc_estproc_fee]   INT           NULL,
    [kc_proc_fee]      INT           NULL,
    [kc_confirm_fig]   VARCHAR (2)   NULL,
    [kc_data_memo]     VARCHAR (150) NULL,
    [kc_updt_user]     VARCHAR (10)  NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_confirm_fig1]  VARCHAR (2)   NULL,
    [CreatePerson]     VARCHAR (10)  NULL,
    [CreateDate]       DATETIME      NULL,
    [kc_confirm_date]  DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_appraised_1]
    ON [kcsd].[kc_appraised]([kc_case_no] ASC, [kc_area_code] ASC, [kc_item_no] ASC, [kc_column_no] ASC);


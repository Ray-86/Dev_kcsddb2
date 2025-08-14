CREATE TABLE [kcsd].[kc_customerloan1] (
    [kc_case_no]        VARCHAR (10)  NOT NULL,
    [kc_rcpt_date]      SMALLDATETIME NULL,
    [kc_rcpt_user]      VARCHAR (10)  NULL,
    [kc_bill_fdate]     SMALLDATETIME NULL,
    [kc_bill_cnt]       INT           NULL,
    [kc_icard_fdate]    SMALLDATETIME NULL,
    [kc_icard_cnt]      INT           NULL,
    [kc_cust_name5u]    NVARCHAR (60) NULL,
    [kc_id_no5]         VARCHAR (10)  NULL,
    [kc_birth_date5]    SMALLDATETIME NULL,
    [kc_mobil_no5]      VARCHAR (12)  NULL,
    [kc_mobil_no5_nt]   VARCHAR (40)  NULL,
    [kc_papa_name5u]    NVARCHAR (60) NULL,
    [kc_mama_name5u]    NVARCHAR (60) NULL,
    [kc_mate_name5u]    NVARCHAR (60) NULL,
    [kc_perm_zip5]      VARCHAR (5)   NULL,
    [kc_perm_addr5]     VARCHAR (100) NULL,
    [kc_perm_addr5_nt]  VARCHAR (40)  NULL,
    [kc_perm_phone5]    VARCHAR (15)  NULL,
    [kc_perm_phone5_nt] VARCHAR (40)  NULL,
    [kc_curr_zip5]      VARCHAR (5)   NULL,
    [kc_curr_addr5]     VARCHAR (100) NULL,
    [kc_curr_addr5_nt]  VARCHAR (40)  NULL,
    [kc_curr_phone5]    VARCHAR (15)  NULL,
    [kc_curr_phone5_nt] VARCHAR (40)  NULL,
    [kc_comp_namea5]    VARCHAR (60)  NULL,
    [kc_comp_zip5]      VARCHAR (5)   NULL,
    [kc_comp_addr5]     VARCHAR (100) NULL,
    [kc_comp_addr5_nt]  VARCHAR (40)  NULL,
    [kc_comp_phone5]    VARCHAR (20)  NULL,
    [kc_comp_phone5_nt] VARCHAR (40)  NULL,
    [kc_job_title5]     VARCHAR (20)  NULL,
    [kc_house_stat5]    VARCHAR (1)   NULL,
    [kc_rela_code5]     VARCHAR (2)   NULL,
    [kc_barcode_no]     VARCHAR (15)  NULL,
    [kc_audit_user]     VARCHAR (10)  NULL,
    [kc_finsu_fee]      INT           NULL,
    [kc_finsu_type]     VARCHAR (2)   NULL,
    [kc_finsu_date]     SMALLDATETIME NULL,
    [kc_rinsu_fee]      INT           NULL,
    [kc_finsu_perd]     SMALLINT      NULL,
    [kc_gas_amt]        INT           NULL,
    [kc_lock_user]      VARCHAR (20)  NULL,
    [kc_area_code]      VARCHAR (2)   NULL,
    [kc_gas_date]       SMALLDATETIME NULL,
    [kc_updt_user]      VARCHAR (10)  NULL,
    [kc_updt_date]      SMALLDATETIME NULL,
    [kc_line_no]        VARCHAR (20)  NULL,
    [CreatePerson]      VARCHAR (20)  NULL,
    [CreateDate]        DATETIME      NULL,
    CONSTRAINT [PK_kc_customerloan1] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_2]
    ON [kcsd].[kc_customerloan1]([kc_mobil_no5] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_3]
    ON [kcsd].[kc_customerloan1]([kc_perm_phone5] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_4]
    ON [kcsd].[kc_customerloan1]([kc_curr_phone5] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_5]
    ON [kcsd].[kc_customerloan1]([kc_comp_phone5] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_6]
    ON [kcsd].[kc_customerloan1]([kc_cust_name5u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_7]
    ON [kcsd].[kc_customerloan1]([kc_id_no5] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_8]
    ON [kcsd].[kc_customerloan1]([kc_papa_name5u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_9]
    ON [kcsd].[kc_customerloan1]([kc_mama_name5u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan1_10]
    ON [kcsd].[kc_customerloan1]([kc_mate_name5u] ASC);


CREATE TABLE [kcsd].[kc_memberdata] (
    [kc_member_no]          VARCHAR (11)   NOT NULL,
    [kc_member_date]        DATETIME       NULL,
    [kc_member_name]        VARCHAR (50)   NULL,
    [kc_id_no]              VARCHAR (10)   NULL,
    [kc_birth_date]         SMALLDATETIME  NULL,
    [kc_member_stat]        VARCHAR (2)    NULL,
    [kc_pusher_code]        VARCHAR (4)    NULL,
    [kc_push_sort]          VARCHAR (2)    NULL,
    [kc_pusher_date]        SMALLDATETIME  NULL,
    [kc_loc_amount]         INT            NULL,
    [kc_cp_no]              VARCHAR (10)   NULL,
    [kc_introduce_code]     VARCHAR (11)   NULL,
    [kc_papa_nameu]         NVARCHAR (60)  NULL,
    [kc_mama_nameu]         NVARCHAR (60)  NULL,
    [kc_mate_nameu]         NVARCHAR (60)  NULL,
    [kc_issue_date]         NVARCHAR (100) NULL,
    [kc_legal_agent]        NVARCHAR (60)  NULL,
    [kc_exp_year]           TINYINT        NULL,
    [kc_exp_month]          TINYINT        NULL,
    [kc_perm_stat]          VARCHAR (1)    NULL,
    [kc_perm_zip]           VARCHAR (5)    NULL,
    [kc_perm_addr]          VARCHAR (100)  NULL,
    [kc_perm_addr_nt]       VARCHAR (40)   NULL,
    [kc_perm_phone]         VARCHAR (15)   NULL,
    [kc_perm_phone_nt]      VARCHAR (40)   NULL,
    [kc_mobil_no]           VARCHAR (12)   NULL,
    [kc_mobil_no_nt]        VARCHAR (40)   NULL,
    [kc_curr_stat]          VARCHAR (1)    NULL,
    [kc_curr_zip]           VARCHAR (5)    NULL,
    [kc_curr_addr]          VARCHAR (100)  NULL,
    [kc_curr_addr_nt]       VARCHAR (40)   NULL,
    [kc_curr_phone]         VARCHAR (15)   NULL,
    [kc_curr_phone_nt]      VARCHAR (40)   NULL,
    [kc_fax_phone]          VARCHAR (15)   NULL,
    [kc_fax_phone_nt]       VARCHAR (40)   NULL,
    [kc_comp_stat]          VARCHAR (1)    NULL,
    [kc_comp_zip]           VARCHAR (5)    NULL,
    [kc_comp_addr]          VARCHAR (100)  NULL,
    [kc_comp_addr_nt]       VARCHAR (40)   NULL,
    [kc_comp_phone]         VARCHAR (20)   NULL,
    [kc_comp_phone_nt]      VARCHAR (40)   NULL,
    [kc_comp_namea]         VARCHAR (60)   NULL,
    [kc_job_title]          VARCHAR (20)   NULL,
    [kc_CCR_date]           SMALLDATETIME  NULL,
    [kc_line_no]            VARCHAR (20)   NULL,
    [kc_healthID_no]        VARCHAR (12)   NULL,
    [kc_householdID_no]     VARCHAR (20)   NULL,
    [kc_cust_name5u]        NVARCHAR (60)  NULL,
    [kc_id_no5]             VARCHAR (10)   NULL,
    [kc_birth_date5]        DATETIME       NULL,
    [kc_papa_name5u]        NVARCHAR (60)  NULL,
    [kc_mama_name5u]        NVARCHAR (60)  NULL,
    [kc_mate_name5u]        NVARCHAR (60)  NULL,
    [kc_rela_code5]         VARCHAR (2)    NULL,
    [kc_perm_zip5]          VARCHAR (5)    NULL,
    [kc_perm_addr5]         VARCHAR (100)  NULL,
    [kc_perm_addr5_nt]      VARCHAR (40)   NULL,
    [kc_perm_phone5]        VARCHAR (15)   NULL,
    [kc_perm_phone5_nt]     VARCHAR (40)   NULL,
    [kc_mobil_no5]          VARCHAR (12)   NULL,
    [kc_mobil_no5_nt]       VARCHAR (40)   NULL,
    [kc_curr_zip5]          VARCHAR (5)    NULL,
    [kc_curr_addr5]         VARCHAR (100)  NULL,
    [kc_curr_addr5_nt]      VARCHAR (40)   NULL,
    [kc_curr_phone5]        VARCHAR (15)   NULL,
    [kc_curr_phone5_nt]     VARCHAR (40)   NULL,
    [kc_comp_zip5]          VARCHAR (5)    NULL,
    [kc_comp_addr5]         VARCHAR (100)  NULL,
    [kc_comp_addr5_nt]      VARCHAR (40)   NULL,
    [kc_comp_phone5]        VARCHAR (20)   NULL,
    [kc_comp_phone5_nt]     VARCHAR (40)   NULL,
    [kc_comp_namea5]        VARCHAR (60)   NULL,
    [kc_job_title5]         VARCHAR (20)   NULL,
    [kc_cust_name3u]        NVARCHAR (60)  NULL,
    [kc_comp_phone3]        VARCHAR (20)   NULL,
    [kc_curr_phone3]        VARCHAR (15)   NULL,
    [kc_curr_phone3_nt]     VARCHAR (40)   NULL,
    [kc_mobil_no3]          VARCHAR (12)   NULL,
    [kc_mobil_no3_nt]       VARCHAR (40)   NULL,
    [kc_rela_code3]         VARCHAR (2)    NULL,
    [kc_trans_addr]         VARCHAR (100)  NULL,
    [kc_cust_name4u]        NVARCHAR (60)  NULL,
    [kc_comp_phone4]        VARCHAR (20)   NULL,
    [kc_curr_phone4]        VARCHAR (15)   NULL,
    [kc_curr_phone4_nt]     VARCHAR (40)   NULL,
    [kc_mobil_no4]          VARCHAR (12)   NULL,
    [kc_mobil_no4_nt]       VARCHAR (40)   NULL,
    [kc_rela_code4]         VARCHAR (2)    NULL,
    [kc_zip_code]           VARCHAR (5)    NULL,
    [kc_bill_addr]          VARCHAR (100)  NULL,
    [kc_cust_name6u]        NVARCHAR (60)  NULL,
    [kc_comp_phone6]        VARCHAR (20)   NULL,
    [kc_curr_phone6]        VARCHAR (15)   NULL,
    [kc_curr_phone6_nt]     VARCHAR (40)   NULL,
    [kc_mobil_no6]          VARCHAR (12)   NULL,
    [kc_mobil_no6_nt]       VARCHAR (40)   NULL,
    [kc_rela_code6]         VARCHAR (2)    NULL,
    [kc_bankbook_name]      VARCHAR (40)   NULL,
    [kc_bankbook_account]   VARCHAR (40)   NULL,
    [kc_bill_code]          VARCHAR (16)   NULL,
    [kc_bill_no]            VARCHAR (16)   NULL,
    [kc_ATM_codeC]          VARCHAR (16)   NULL,
    [kc_ATM_codeD]          VARCHAR (16)   NULL,
    [kc_bill_item]          INT            NULL,
    [CreatePerson]          VARCHAR (20)   NULL,
    [CreateDate]            DATETIME       NULL,
    [kc_updt_user]          VARCHAR (20)   NULL,
    [kc_updt_date]          DATETIME       NULL,
    [kc_used_amount]        INT            NULL,
    [kc_upgrade_bank_name]  VARCHAR (40)   NULL,
    [kc_upgrade_credit_no]  VARCHAR (40)   NULL,
    [kc_upgrade_loc_amount] INT            NULL,
    [kc_ATM_codeC_item]     INT            NULL,
    [kc_permmember_type]    VARCHAR (20)   NULL,
    [kc_currmember_type]    VARCHAR (20)   NULL,
    [kc_permreside_type]    VARCHAR (2)    NULL,
    [kc_currreside_type]    VARCHAR (2)    NULL,
    [kc_contact_memo]       VARCHAR (20)   NULL,
    [kc_comp_ext]           VARCHAR (10)   NULL,
    [kc_relation_no3]       VARCHAR (2)    NULL,
    [kc_relation_no4]       VARCHAR (2)    NULL,
    [kc_relation_no6]       VARCHAR (2)    NULL,
    [kc_comp_desc]          VARCHAR (50)   NULL,
    [kc_comp_code]          VARCHAR (4)    NULL,
    [kc_data_memo]          VARCHAR (150)  NULL,
    [kc_ret_date]           DATE           NULL,
    [kc_audit_user]         VARCHAR (10)   NULL,
    [kc_boro_date]          DATE           NULL,
    [kc_boro_code]          VARCHAR (6)    NULL,
    [kc_boro_stat]          VARCHAR (1)    NULL,
    [kc_boro_memo]          VARCHAR (100)  NULL,
    [kc_data_flag]          VARCHAR (10)   NULL,
    [kc_barcode_no]         VARCHAR (15)   NULL,
    [kc_rcpt_date]          DATE           NULL,
    [kc_rcpt_user]          VARCHAR (10)   NULL,
    [PrintMark]             VARCHAR (1)    NULL,
    [CarrierType]           VARCHAR (6)    NULL,
    [CarrierId1]            VARCHAR (64)   NULL,
    [kc_ATM_codeB]          VARCHAR (16)   NULL,
    [NPOBAN]                VARCHAR (20)   NULL,
    [CompID]                VARCHAR (20)   NULL,
    [kc_email_no]           VARCHAR (100)  NULL,
    [kc_invoice_address]    VARCHAR (100)  NULL,
    CONSTRAINT [PK_kc_memberdata] PRIMARY KEY CLUSTERED ([kc_member_no] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-資料不全 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_data_memo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-初審日期 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_ret_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-初審人 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_audit_user';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-契約日期 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_boro_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-契約使用 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_boro_code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-契約狀態 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_boro_stat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-契約備註 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_boro_memo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-契約狀態 (契約 : C ; 缺錯 : W; 齊全 : A) (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_data_flag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506300002 - 契約-條碼 (25.07.24 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_memberdata', @level2type = N'COLUMN', @level2name = N'kc_barcode_no';


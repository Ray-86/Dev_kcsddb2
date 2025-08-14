CREATE TABLE [kcsd].[kc_customerloan] (
    [kc_case_no]          VARCHAR (10)  NOT NULL,
    [kc_area_code]        VARCHAR (2)   NOT NULL,
    [kc_cp_no]            VARCHAR (10)  NULL,
    [kc_id_no]            VARCHAR (10)  NOT NULL,
    [kc_birth_date]       DATETIME      NULL,
    [kc_cust_name]        VARCHAR (60)  NULL,
    [kc_cust_nameu]       NVARCHAR (60) NULL,
    [kc_papa_nameu]       NVARCHAR (60) NULL,
    [kc_mama_nameu]       NVARCHAR (60) NULL,
    [kc_mate_nameu]       NVARCHAR (60) NULL,
    [kc_legal_agent]      NVARCHAR (60) NULL,
    [kc_cust_stat]        VARCHAR (1)   NULL,
    [kc_house_stat]       VARCHAR (1)   NULL,
    [kc_mobil_no]         VARCHAR (12)  NULL,
    [kc_mobil_no_nt]      VARCHAR (40)  NULL,
    [kc_fax_phone]        VARCHAR (15)  NULL,
    [kc_fax_phone_nt]     VARCHAR (40)  NULL,
    [kc_perm_zip]         VARCHAR (5)   NULL,
    [kc_perm_stat]        VARCHAR (1)   NULL,
    [kc_perm_addr]        VARCHAR (100) NULL,
    [kc_perm_addr_nt]     VARCHAR (40)  NULL,
    [kc_perm_phone]       VARCHAR (15)  NULL,
    [kc_perm_phone_nt]    VARCHAR (40)  NULL,
    [kc_curr_stat]        VARCHAR (1)   NULL,
    [kc_curr_zip]         VARCHAR (5)   NULL,
    [kc_curr_addr]        VARCHAR (100) NULL,
    [kc_curr_addr_nt]     VARCHAR (40)  NULL,
    [kc_curr_phone]       VARCHAR (15)  NULL,
    [kc_curr_phone_nt]    VARCHAR (40)  NULL,
    [kc_comp_stat]        VARCHAR (1)   NULL,
    [kc_comp_zip]         VARCHAR (5)   NULL,
    [kc_comp_addr]        VARCHAR (100) NULL,
    [kc_comp_addr_nt]     VARCHAR (40)  NULL,
    [kc_comp_phone]       VARCHAR (20)  NULL,
    [kc_comp_phone_nt]    VARCHAR (40)  NULL,
    [kc_comp_namea]       VARCHAR (60)  NULL,
    [kc_job_title]        VARCHAR (20)  NULL,
    [kc_exp_year]         TINYINT       NULL,
    [kc_exp_month]        TINYINT       NULL,
    [kc_id_no1]           VARCHAR (10)  NULL,
    [kc_birth_date1]      DATETIME      NULL,
    [kc_rela_code1]       VARCHAR (2)   NULL,
    [kc_cust_name1u]      NVARCHAR (60) NULL,
    [kc_papa_name1u]      NVARCHAR (60) NULL,
    [kc_mama_name1u]      NVARCHAR (60) NULL,
    [kc_mate_name1u]      NVARCHAR (60) NULL,
    [kc_legal_agent1]     NVARCHAR (60) NULL,
    [kc_cust_stat1]       VARCHAR (1)   NULL,
    [kc_house_stat1]      VARCHAR (1)   NULL,
    [kc_mobil_no1]        VARCHAR (12)  NULL,
    [kc_mobil_no1_nt]     VARCHAR (40)  NULL,
    [kc_mobil_no12]       VARCHAR (12)  NULL,
    [kc_mobil_no12_nt]    VARCHAR (40)  NULL,
    [kc_perm_stat1]       VARCHAR (1)   NULL,
    [kc_perm_zip1]        VARCHAR (5)   NULL,
    [kc_perm_addr1]       VARCHAR (100) NULL,
    [kc_perm_addr1_nt]    VARCHAR (40)  NULL,
    [kc_perm_phone1]      VARCHAR (15)  NULL,
    [kc_perm_phone1_nt]   VARCHAR (40)  NULL,
    [kc_curr_stat1]       VARCHAR (1)   NULL,
    [kc_curr_zip1]        VARCHAR (5)   NULL,
    [kc_curr_addr1]       VARCHAR (100) NULL,
    [kc_curr_addr1_nt]    VARCHAR (40)  NULL,
    [kc_curr_phone1]      VARCHAR (15)  NULL,
    [kc_curr_phone1_nt]   VARCHAR (40)  NULL,
    [kc_comp_stat1]       VARCHAR (1)   NULL,
    [kc_comp_zip1]        VARCHAR (5)   NULL,
    [kc_comp_addr1]       VARCHAR (100) NULL,
    [kc_comp_addr1_nt]    VARCHAR (40)  NULL,
    [kc_comp_phone1]      VARCHAR (20)  NULL,
    [kc_comp_phone1_nt]   VARCHAR (40)  NULL,
    [kc_comp_namea1]      VARCHAR (60)  NULL,
    [kc_job_title1]       VARCHAR (20)  NULL,
    [kc_id_no2]           VARCHAR (10)  NULL,
    [kc_birth_date2]      DATETIME      NULL,
    [kc_rela_code2]       VARCHAR (2)   NULL,
    [kc_cust_name2u]      NVARCHAR (60) NULL,
    [kc_papa_name2u]      NVARCHAR (60) NULL,
    [kc_mama_name2u]      NVARCHAR (60) NULL,
    [kc_mate_name2u]      NVARCHAR (60) NULL,
    [kc_legal_agent2]     NVARCHAR (60) NULL,
    [kc_cust_stat2]       VARCHAR (1)   NULL,
    [kc_house_stat2]      VARCHAR (1)   NULL,
    [kc_mobil_no2]        VARCHAR (12)  NULL,
    [kc_mobil_no2_nt]     VARCHAR (40)  NULL,
    [kc_perm_stat2]       VARCHAR (1)   NULL,
    [kc_perm_zip2]        VARCHAR (5)   NULL,
    [kc_perm_addr2]       VARCHAR (100) NULL,
    [kc_perm_addr2_nt]    VARCHAR (40)  NULL,
    [kc_perm_phone2]      VARCHAR (15)  NULL,
    [kc_perm_phone2_nt]   VARCHAR (40)  NULL,
    [kc_curr_stat2]       VARCHAR (1)   NULL,
    [kc_curr_zip2]        VARCHAR (5)   NULL,
    [kc_curr_addr2]       VARCHAR (100) NULL,
    [kc_curr_addr2_nt]    VARCHAR (40)  NULL,
    [kc_curr_phone2]      VARCHAR (15)  NULL,
    [kc_curr_phone2_nt]   VARCHAR (40)  NULL,
    [kc_comp_stat2]       VARCHAR (1)   NULL,
    [kc_comp_zip2]        VARCHAR (5)   NULL,
    [kc_comp_addr2]       VARCHAR (100) NULL,
    [kc_comp_addr2_nt]    VARCHAR (40)  NULL,
    [kc_comp_phone2]      VARCHAR (20)  NULL,
    [kc_comp_phone2_nt]   VARCHAR (40)  NULL,
    [kc_comp_namea2]      VARCHAR (60)  NULL,
    [kc_job_title2]       VARCHAR (20)  NULL,
    [kc_cust_name3u]      NVARCHAR (60) NULL,
    [kc_rela_code3]       VARCHAR (2)   NULL,
    [kc_mobil_no3]        VARCHAR (12)  NULL,
    [kc_curr_phone3]      VARCHAR (15)  NULL,
    [kc_comp_phone3]      VARCHAR (20)  NULL,
    [kc_cust_name4u]      NVARCHAR (60) NULL,
    [kc_rela_code4]       VARCHAR (2)   NULL,
    [kc_mobil_no4]        VARCHAR (12)  NULL,
    [kc_curr_phone4]      VARCHAR (15)  NULL,
    [kc_comp_phone4]      VARCHAR (20)  NULL,
    [kc_zip_code]         VARCHAR (5)   NULL,
    [kc_bill_addr]        VARCHAR (100) NULL,
    [kc_trans_addr]       VARCHAR (100) NULL,
    [kc_data_sign]        VARCHAR (10)  NULL,
    [kc_data_flag]        VARCHAR (10)  NULL,
    [kc_data_flag1]       VARCHAR (10)  NULL,
    [kc_data_flag2]       VARCHAR (10)  NULL,
    [kc_data_memo]        VARCHAR (150) NULL,
    [kc_ret_date]         DATETIME      NULL,
    [kc_boro_date]        DATETIME      NULL,
    [kc_boro_code]        VARCHAR (6)   NULL,
    [kc_boro_stat]        VARCHAR (1)   NULL,
    [kc_boro_memo]        VARCHAR (100) NULL,
    [kc_pusher_code]      VARCHAR (6)   NULL,
    [kc_pusher_date]      DATETIME      NULL,
    [kc_push_sort]        VARCHAR (4)   NULL,
    [kc_trace_date]       DATETIME      NULL,
    [kc_push_memo]        TEXT          NULL,
    [kc_push_memo2]       VARCHAR (200) NULL,
    [kc_push_memo3]       VARCHAR (300) NULL,
    [kc_loan_stat]        VARCHAR (1)   NULL,
    [kc_push_stat]        VARCHAR (1)   NULL,
    [kc_car_stat]         VARCHAR (1)   NULL,
    [kc_over_count]       TINYINT       NULL,
    [kc_pay_count]        TINYINT       NULL,
    [kc_dday_count]       SMALLINT      NULL,
    [kc_over_amt]         INT           NULL,
    [kc_break_amt]        INT           NULL,
    [kc_break_amt2]       INT           NULL,
    [kc_rema_amt]         INT           NULL,
    [kc_comp_code]        VARCHAR (4)   NULL,
    [kc_sales_code]       VARCHAR (6)   NOT NULL,
    [kc_loan_type]        VARCHAR (3)   NULL,
    [kc_car_brand]        VARCHAR (2)   NULL,
    [kc_car_model]        VARCHAR (30)  NULL,
    [kc_licn_no]          VARCHAR (10)  NULL,
    [kc_eng_no]           VARCHAR (20)  NULL,
    [kc_new_flag]         VARCHAR (1)   NULL,
    [kc_buy_date]         DATETIME      NULL,
    [kc_loan_perd]        TINYINT       NULL,
    [kc_loan_fee]         INT           NULL,
    [kc_perd_fee]         INT           NULL,
    [kc_total_price]      INT           NULL,
    [kc_brok_fee]         INT           NULL,
    [kc_brok_fee2]        INT           NULL,
    [kc_strt_date]        DATETIME      NULL,
    [kc_strt_fee]         INT           NULL,
    [kc_give_type]        VARCHAR (2)   NULL,
    [kc_give_amt]         INT           NULL,
    [kc_coll_amt]         INT           NULL,
    [kc_car_cc]           VARCHAR (5)   NULL,
    [kc_totm_fee]         INT           NULL,
    [kc_insu_flag]        VARCHAR (1)   NULL,
    [kc_rule_fee]         INT           NULL,
    [kc_issu_code]        VARCHAR (6)   NULL,
    [kc_aux_flag]         BIT           NULL,
    [kc_aux_amt]          TINYINT       NULL,
    [kc_pay_type]         VARCHAR (1)   NULL,
    [kc_dday_date]        DATETIME      NULL,
    [kc_licn_date]        DATETIME      NULL,
    [kc_pvall_amt]        INT           NULL,
    [kc_proc_amt]         INT           NULL,
    [kc_chk_no]           VARCHAR (12)  NULL,
    [kc_cap_code]         VARCHAR (2)   NULL,
    [kc_intr_rate]        REAL          NULL,
    [kc_insu_sum]         INT           NULL,
    [kc_fitt1_amt]        SMALLINT      NULL,
    [kc_fitt2_amt]        SMALLINT      NULL,
    [kc_delay_code]       VARCHAR (4)   NULL,
    [kc_cred_chk]         BIT           NULL,
    [kc_cred_fee]         INT           NULL,
    [kc_cred_stat]        VARCHAR (1)   NULL,
    [kc_apply_stat]       VARCHAR (1)   NULL,
    [kc_comp_char2]       VARCHAR (2)   NULL,
    [kc_prod_type]        VARCHAR (4)   NULL,
    [kc_claims_amt]       INT           NULL,
    [kc_value_date]       DATETIME      NULL,
    [kc_oriclaims_amt]    INT           NULL,
    [kc_orivalue_date]    DATETIME      NULL,
    [kc_creditor_name]    VARCHAR (6)   NULL,
    [kc_rate_fee]         VARCHAR (2)   NULL,
    [kc_lawagents_code]   VARCHAR (2)   NULL,
    [kc_stock_date]       DATETIME      NULL,
    [kc_maturity_date]    DATETIME      NULL,
    [kc_idle_type]        VARCHAR (4)   NULL,
    [kc_idle_amt]         INT           NULL,
    [kc_idle_date]        DATETIME      NULL,
    [kc_bank_code]        VARCHAR (7)   NULL,
    [kc_acc_code]         VARCHAR (15)  NULL,
    [kc_crdt_user]        VARCHAR (10)  NULL,
    [kc_updt_user]        VARCHAR (10)  NULL,
    [kc_updt_date]        DATETIME      NULL,
    [PrintMark]           VARCHAR (1)   NULL,
    [CarrierType]         VARCHAR (6)   NULL,
    [CarrierId1]          VARCHAR (64)  NULL,
    [CarrierId2]          VARCHAR (64)  NULL,
    [NPOBAN]              VARCHAR (7)   NULL,
    [kc_insu_amt]         INT           NULL,
    [kc_insu_fee]         INT           NULL,
    [kc_insu_amt1]        INT           NULL,
    [kc_insu_fee1]        INT           NULL,
    [kc_insu_amt2]        INT           NULL,
    [kc_insu_fee2]        INT           NULL,
    [kc_insu_amt3]        INT           NULL,
    [kc_insu_fee3]        INT           NULL,
    [kc_mate_name]        VARCHAR (10)  NULL,
    [kc_papa_name]        VARCHAR (10)  NULL,
    [kc_mama_name]        VARCHAR (10)  NULL,
    [kc_cust_name1]       VARCHAR (10)  NULL,
    [kc_mate_name1]       VARCHAR (10)  NULL,
    [kc_papa_name1]       VARCHAR (10)  NULL,
    [kc_mama_name1]       VARCHAR (10)  NULL,
    [kc_cust_name2]       VARCHAR (10)  NULL,
    [kc_mate_name2]       VARCHAR (10)  NULL,
    [kc_papa_name2]       VARCHAR (10)  NULL,
    [kc_mama_name2]       VARCHAR (10)  NULL,
    [kc_cust_name3]       VARCHAR (10)  NULL,
    [kc_cust_name4]       VARCHAR (10)  NULL,
    [kc_comp_namex]       VARCHAR (60)  NULL,
    [kc_comp_namex1]      VARCHAR (60)  NULL,
    [kc_comp_namex2]      VARCHAR (60)  NULL,
    [kc_comp_name]        VARCHAR (20)  NULL,
    [kc_comp_name1]       VARCHAR (20)  NULL,
    [kc_comp_name2]       VARCHAR (20)  NULL,
    [kc_valid_month]      SMALLINT      NULL,
    [kc_valid_year]       SMALLINT      NULL,
    [kc_card_type]        VARCHAR (2)   NULL,
    [kc_card_no]          VARCHAR (20)  NULL,
    [kc_auth_code]        VARCHAR (10)  NULL,
    [kc_law_date]         DATETIME      NULL,
    [kc_comp_char]        VARCHAR (1)   NULL,
    [kc_link_no]          INT           NULL,
    [kc_accu_flag]        VARCHAR (1)   NULL,
    [kc_ret_code]         VARCHAR (6)   NULL,
    [kc_rewd_type]        VARCHAR (2)   NULL,
    [kc_issu_bank]        VARCHAR (4)   NULL,
    [kc_wire_bank]        VARCHAR (5)   NULL,
    [kc_wire_branch]      VARCHAR (30)  NULL,
    [kc_wire_acc]         VARCHAR (20)  NULL,
    [kc_remit_user]       NVARCHAR (60) NULL,
    [kc_remit_date]       DATETIME      NULL,
    [kc_insuend_date]     DATETIME      NULL,
    [kc_proc_fee]         INT           NULL,
    [kc_collarcar_fee]    INT           NULL,
    [kc_capremain_fee]    INT           NULL,
    [kc_curr_phone3_nt]   VARCHAR (40)  NULL,
    [kc_curr_phone4_nt]   VARCHAR (40)  NULL,
    [kc_mobil_no3_nt]     VARCHAR (40)  NULL,
    [kc_mobil_no4_nt]     VARCHAR (40)  NULL,
    [kc_partner_no]       VARCHAR (10)  NULL,
    [kc_agency_no]        VARCHAR (4)   NULL,
    [kc_partnerbank_no]   VARCHAR (3)   NULL,
    [kc_localagency_no]   VARCHAR (4)   NULL,
    [kc_partnerbill_date] DATETIME      NULL,
    [kc_otheragency_no]   VARCHAR (4)   NULL,
    [kc_regissu_type]     VARCHAR (1)   NULL,
    [kc_insuend_user]     VARCHAR (10)  NULL,
    [kc_push_memo4]       VARCHAR (150) NULL,
    [kc_bill_code]        VARCHAR (3)   NULL,
    [kc_line_no]          VARCHAR (20)  NULL,
    [kc_invo_flag]        VARCHAR (1)   NULL,
    [kc_buyback_user]     VARCHAR (10)  NULL,
    [kc_buyback_date]     SMALLDATETIME NULL,
    [kc_brand_code]       VARCHAR (2)   NULL,
    [kc_draft_addr]       VARCHAR (100) NULL,
    [kc_dect_amt]         INT           NULL,
    [kc_invo_caseno]      VARCHAR (10)  NULL,
    [kc_healthID_no]      VARCHAR (12)  NULL,
    [kc_healthID_no1]     VARCHAR (12)  NULL,
    [kc_healthID_no2]     VARCHAR (12)  NULL,
    [kc_cust_name6u]      NVARCHAR (60) NULL,
    [kc_rela_code6]       VARCHAR (2)   NULL,
    [kc_mobil_no6]        VARCHAR (12)  NULL,
    [kc_curr_phone6]      VARCHAR (15)  NULL,
    [kc_comp_phone6]      VARCHAR (20)  NULL,
    [kc_mobil_no6_nt]     VARCHAR (40)  NULL,
    [kc_curr_phone6_nt]   VARCHAR (40)  NULL,
    [kc_householdID_no]   VARCHAR (20)  NULL,
    [kc_householdID_no1]  VARCHAR (20)  NULL,
    [kc_householdID_no2]  VARCHAR (20)  NULL,
    [kc_citizenship_type] VARCHAR (6)   NULL,
    [kc_batchprint_user]  VARCHAR (10)  NULL,
    [kc_batchprint_date]  SMALLDATETIME NULL,
    [kc_laborlist_stat]   VARCHAR (1)   NULL,
    [kc_laborlist_memo]   VARCHAR (100) NULL,
    [kc_laborlist_date]   SMALLDATETIME NULL,
    [kc_CCR_date]         SMALLDATETIME NULL,
    [kc_CCR_date1]        SMALLDATETIME NULL,
    [kc_CCR_date2]        SMALLDATETIME NULL,
    [kc_member_no]        VARCHAR (20)  NULL,
    [CreatePerson]        VARCHAR (20)  NULL,
    [CreateDate]          DATETIME      NULL,
    [kc_rece_fee]         INT           NULL,
    [kc_renewal_type]     VARCHAR (1)   NULL,
    [CompID]              VARCHAR (20)  NULL,
    [kc_marketer_code]    VARCHAR (10)  NULL,
    [kc_marketing_type]   VARCHAR (2)   NULL,
    [kc_marketing_date]   DATETIME      NULL,
    [kc_ATM_codeB]        VARCHAR (20)  NULL,
    [kc_ATM_codeC]        VARCHAR (20)  NULL,
    [kc_bank_no]          VARCHAR (10)  NULL,
    [kc_bank_nont]        VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_customerloan_1__10] PRIMARY KEY CLUSTERED ([kc_case_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan]
    ON [kcsd].[kc_customerloan]([kc_buy_date] ASC, [kc_case_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_10]
    ON [kcsd].[kc_customerloan]([kc_mobil_no1] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_11]
    ON [kcsd].[kc_customerloan]([kc_mobil_no2] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_12]
    ON [kcsd].[kc_customerloan]([kc_mobil_no3] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_13]
    ON [kcsd].[kc_customerloan]([kc_mobil_no4] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_14]
    ON [kcsd].[kc_customerloan]([kc_fax_phone] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_18]
    ON [kcsd].[kc_customerloan]([kc_cp_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_19]
    ON [kcsd].[kc_customerloan]([kc_cust_nameu] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_2]
    ON [kcsd].[kc_customerloan]([kc_loan_stat] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_20]
    ON [kcsd].[kc_customerloan]([kc_papa_nameu] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_21]
    ON [kcsd].[kc_customerloan]([kc_mama_nameu] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_22]
    ON [kcsd].[kc_customerloan]([kc_mate_nameu] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_23]
    ON [kcsd].[kc_customerloan]([kc_cust_name1u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_24]
    ON [kcsd].[kc_customerloan]([kc_papa_name1u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_25]
    ON [kcsd].[kc_customerloan]([kc_mama_name1u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_26]
    ON [kcsd].[kc_customerloan]([kc_mate_name1u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_27]
    ON [kcsd].[kc_customerloan]([kc_cust_name2u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_28]
    ON [kcsd].[kc_customerloan]([kc_papa_name2u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_29]
    ON [kcsd].[kc_customerloan]([kc_mama_name2u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_3]
    ON [kcsd].[kc_customerloan]([kc_id_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_30]
    ON [kcsd].[kc_customerloan]([kc_mate_name2u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_31]
    ON [kcsd].[kc_customerloan]([kc_case_no] ASC, [kc_loan_stat] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_32]
    ON [kcsd].[kc_customerloan]([kc_case_no] ASC, [kc_loan_stat] ASC, [kc_over_amt] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_4]
    ON [kcsd].[kc_customerloan]([kc_case_no] ASC, [kc_area_code] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_5]
    ON [kcsd].[kc_customerloan]([kc_id_no1] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_7]
    ON [kcsd].[kc_customerloan]([kc_id_no2] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_8]
    ON [kcsd].[kc_customerloan]([kc_case_no] ASC, [kc_comp_char] ASC, [kc_accu_flag] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_9]
    ON [kcsd].[kc_customerloan]([kc_mobil_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_33]
    ON [kcsd].[kc_customerloan]([kc_mobil_no12] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_34]
    ON [kcsd].[kc_customerloan]([kc_cust_name3u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_customerloan_35]
    ON [kcsd].[kc_customerloan]([kc_cust_name4u] ASC);


GO
CREATE NONCLUSTERED INDEX [i_test1]
    ON [kcsd].[kc_customerloan]([kc_area_code] ASC, [kc_prod_type] ASC, [kc_buy_date] ASC, [kc_comp_code] ASC);


GO
CREATE NONCLUSTERED INDEX [i_test2]
    ON [kcsd].[kc_customerloan]([kc_buy_date] ASC);


GO
CREATE NONCLUSTERED INDEX [i_test3]
    ON [kcsd].[kc_customerloan]([kc_case_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_test4]
    ON [kcsd].[kc_customerloan]([kc_loan_stat] ASC);


GO
-- ==========================================================================================
-- 2013-07-05 修正權限、調整刪除邏輯
-- 09/30/2006 KC: also delete kc_push, kc_pushassign when delete case
-- ==========================================================================================
CREATE        TRIGGER [kcsd].[t_kc_customerloan_d] ON kcsd.kc_customerloan 
FOR DELETE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no = kc_case_no
FROM	deleted


--IF exists	(SELECT	'X'
--		FROM	sysusers u, sysusers g, sysmembers m
--		WHERE	u.name = USER
--		AND	( g.name = 'ADMS' )
--		AND	g.uid = m.groupuid
--		AND	u.uid = m.memberuid
--		) or USER = 'dbo'
--BEGIN
	IF	@wk_case_no IS NOT NULL
	BEGIN
		DELETE
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_push
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no		

		DELETE
		FROM	kcsd.kc_customerloan1
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_customers
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_lawstatus
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_carstatus
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_apptschedule
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_pushassign
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_trafficticket
		WHERE	kc_case_no = @wk_case_no
		
		DELETE
		FROM	kcsd.kc_employer
		WHERE	kc_case_no = @wk_case_no

		DELETE
		FROM	kcsd.kc_remittance
		WHERE	kc_case_no = @wk_case_no
				
		update kcsd.kc_insurance_list set kc_case_no = null
		WHERE	kc_case_no = @wk_case_no
/*
		DELETE
		FROM	kcsd.kc_insurance_list_insu
		WHERE	kc_case_no = @wk_case_no
*/
--	END
--END
--ELSE
--BEGIN
--	RAISERROR ('--[KC] Case 禁止刪除 !!!',18,2) WITH SETERROR
--	ROLLBACK TRANSACTION
--	RETURN
END

GO
-- ==========================================================================================
-- 2022-11-04 : 新增利率專案P開頭，特別的繳款資料
-- 2017-06-20 : 支票加入kc_acc_ymd 去除原先kc_check的trigger
-- 2014-11-30 : 新增台中支票
-- 2013-10-14 : 轉支票Table 改為購買日
-- 05/17/09 KC: 支票受票人增加分公司名稱		
-- 05/17/09 KC: 東元機車,支票產生L3		
-- 05/16/09 KC: 在保險資料內(kc_insurance_list) 填入 case_no		
-- 06/07/08 KC: 支票號碼下一個為 kc_checkserial
-- 05/31/08 KC: 支票號碼檢查 kc_check & kc_checkserial, 取大者
-- 07/29/06 KC: 因 ignore dup err msg 影響, 改為insert caselink_queue, 另外 batch 執行
-- 07/26/06 KC: caselink 改由 insert trigger 執行
--	      :	remove unused variables strt_char, stop_char
-- 04/22/06 KC: 本人id, birthdate, 關係1,關係2, 公司名稱 不可空白
-- 09/16/04 KC: 無CP不可存檔
-- 11/04/03 KC: 支票金額=撥款金額 (編號0X需減佣金)
-- 10/18/03 KC: '03' 支票金額扣除佣金
-- 10/18/03 KC: 填入支票號碼
-- ==========================================================================================
CREATE                           TRIGGER [kcsd].[t_kc_customerloan_i]
ON kcsd.kc_customerloan 
FOR INSERT NOT FOR REPLICATION
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_cust_nameu	nvarchar(60),
	@wk_cust_name1u	nvarchar(60),
	@wk_cust_name2u	nvarchar(60),	
	@wk_id_no	char(10),
	@wk_id_no1	char(10),
	@wk_id_no2	char(10),	
	@wk_loan_perd	int,
	@wk_strt_date	datetime,
	@wk_perd_fee	int,
	@wk_perd_no	int,
	@wk_counter	int,
	@wk_loan_fee	int,		/* 貸款金額 */
	@wk_give_amt	int,		/* 撥款金額 */
	@wk_comp_code	varchar(30),	/* 車行 */
	@wk_agent_name	varchar(30),	/* 車行 */
	@wk_brok_fee	int,		/* 佣金 */
	@wk_chk_no		char(7),		--支票用
	@wk_chk_max		char(7),
	@wk_chk_max2	varchar(20),	-- 支票序號
	@wk_buy_date		datetime,
	@wk_rece_name	varchar(100),
	@wk_acc_code		char(2),
	@wk_data_memo	varchar(50),
	--@wk_apply_stat		char(1),			--申請狀況
	@wk_perm_addr	varchar(100),
	@wk_curr_addr	varchar(100),   
	@wk_comp_addr	varchar(100),
	@wk_trans_addr	varchar(100),
	@wk_perm_phone	varchar(100),
	@wk_curr_phone	varchar(100),
	@wk_comp_phone	varchar(100),
	@wk_mobil_no	varchar(100),
	@wk_perm_addr1	varchar(100),
	@wk_curr_addr1	varchar(100),
	@wk_comp_addr1	varchar(100),
	@wk_perm_phone1	varchar(100),
	@wk_curr_phone1	varchar(100),
	@wk_comp_phone1	varchar(100),
	@wk_mobil_no1	varchar(100),
	@wk_perm_addr2	varchar(100),
	@wk_curr_addr2	varchar(100),
	@wk_comp_addr2	varchar(100),
	@wk_perm_phone2	varchar(100),
	@wk_curr_phone2	varchar(100),
	@wk_comp_phone2	varchar(100),
	@wk_mobil_no2	varchar(100),
	@wk_area_code	varchar(2),
	@wk_give_type	varchar(2),
	@wk_cp_no		varchar(20),
	@wk_rela_code1	varchar(4),	-- 檢查不可空白用
	@wk_rela_code2	varchar(4),	-- 檢查不可空白用
	@wk_comp_name	varchar(30),	-- 檢查不可空白用
	@wk_comp_name1	varchar(30),	-- 檢查不可空白用
	@wk_comp_name2	varchar(30),	-- 檢查不可空白用
	@wk_area_desc	varchar(30),	-- 分公司名
	@wk_acc_ymd		varchar(8),
	@wk_crdt_user	varchar(30),
	@wk_issu_code	varchar(2),
	@wk_loan_type	varchar(10),
	@wk_cap_code	varchar(2),
	@wk_ATM_codeB	varchar(20),
	@wk_expt_date	datetime

SELECT	@wk_case_no=NULL, 
	@wk_id_no=NULL,
	@wk_cust_nameu=NULL,@wk_cust_name1u=NULL, @wk_cust_name2u=NULL,	
	@wk_loan_perd=NULL, @wk_strt_date=NULL, @wk_perd_fee=0,
	@wk_perd_no=0, @wk_counter=0, @wk_loan_fee = 0, @wk_give_amt = 0, @wk_comp_code =NULL,
	@wk_agent_name=NULL, @wk_brok_fee = 0, 
	@wk_buy_date = NULL, @wk_rece_name = NULL,
	@wk_data_memo = NULL, 
	@wk_area_code = NULL, @wk_give_type = NULL, @wk_cp_no = NULL,
	@wk_area_desc = NULL ,@wk_loan_type = null,
	@wk_cap_code = NULL,@wk_ATM_codeB = null

SELECT	@wk_case_no = kc_case_no, 
	@wk_id_no = kc_id_no, @wk_id_no1 = kc_id_no1, @wk_id_no2 = kc_id_no2,
	@wk_cust_nameu = kc_cust_nameu,@wk_cust_name1u=kc_cust_name1u, @wk_cust_name2u=kc_cust_name2u,
	@wk_strt_date = kc_strt_date,
	@wk_perd_fee = kc_perd_fee, @wk_loan_perd = kc_loan_perd,
	@wk_loan_fee = kc_loan_fee, @wk_give_amt = kc_give_amt, @wk_comp_code = kc_comp_code,
	@wk_brok_fee = kc_brok_fee,
	@wk_data_memo = kc_data_memo,
	@wk_perm_addr=kc_perm_addr,@wk_perm_addr1=kc_perm_addr1,@wk_perm_addr2=kc_perm_addr2,
	@wk_curr_addr=kc_curr_addr,@wk_curr_addr1=kc_curr_addr1,@wk_curr_addr2=kc_curr_addr2,
	@wk_comp_addr=kc_comp_addr,
	@wk_trans_addr=kc_trans_addr,
	@wk_perm_phone=kc_perm_phone,@wk_perm_phone1=kc_perm_phone1,@wk_perm_phone2=kc_perm_phone2,
	@wk_curr_phone=kc_curr_phone,@wk_curr_phone1=kc_curr_phone1,@wk_curr_phone2=kc_curr_phone2,
	@wk_comp_phone=kc_comp_phone,@wk_comp_phone1=kc_comp_phone1,@wk_comp_phone2=kc_comp_phone2,
	@wk_mobil_no=kc_mobil_no, @wk_mobil_no1=kc_mobil_no1, @wk_mobil_no2=kc_mobil_no2,
	@wk_area_code = kc_area_code, @wk_give_type = kc_give_type, @wk_cp_no = kc_cp_no,
	@wk_rela_code1 = kc_rela_code1, @wk_rela_code2 = kc_rela_code2,
	@wk_comp_name = kc_comp_namea, @wk_comp_name1 = kc_comp_namea1, @wk_comp_name2 = kc_comp_namea2,
	@wk_buy_date = kc_buy_date, @wk_crdt_user = kc_crdt_user,
	@wk_issu_code = kc_issu_code ,@wk_loan_type = kc_loan_type , @wk_cap_code = kc_cap_code
FROM	inserted

--IF	@wk_comp_code IS NULL
--BEGIN
--	RAISERROR ('KC:無車行不可建檔!!!',18,2)
--	ROLLBACK TRANSACTION
--	RETURN
--END

--IF	(@wk_comp_name) IS NULL
--OR	(@wk_cust_name1u IS NOT NULL AND @wk_comp_name1 IS NULL)
--OR	(@wk_cust_name2u IS NOT NULL AND @wk_comp_name2 IS NULL)
--BEGIN
--	RAISERROR ('KC:公司不可空白!!!',18,2)
--	ROLLBACK TRANSACTION
--	RETURN
--END

IF	(@wk_cust_name1u IS NOT NULL AND @wk_rela_code1 IS NULL)
OR	(@wk_cust_name2u IS NOT NULL AND @wk_rela_code2 IS NULL)
BEGIN
	RAISERROR ('KC:關係不可空白!!!',18,2)
	ROLLBACK TRANSACTION
	RETURN
END

--IF	@wk_cp_no IS NULL
--BEGIN
--	RAISERROR ('無CP不可建檔!!!',18,2)
--	ROLLBACK TRANSACTION
--	RETURN
--END

--IF	NOT EXISTS
--	(SELECT	*
--	FROM	kcsd.kc_cpdata
--	WHERE	kc_cp_no = @wk_cp_no
--	AND	kc_apply_stat = 'P')
--BEGIN
--	RAISERROR ('CP不存在 或 未核准!!!',18,2)
--	ROLLBACK TRANSACTION
--	RETURN
--END

UPDATE	kcsd.kc_customerloan
SET	kc_loan_stat = 'N',kc_over_count = 0, kc_pay_count = 0,kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_case_no = @wk_case_no

/* 退件者不處理 */
--IF	@wk_apply_stat = 'R'
--	RETURN

--產生車款電匯資料(測試)
--INSERT INTO kcsd.kc_banktransfer(kc_case_no,kc_tran_stat,kc_insu_fig,kc_close_fig,kc_cancel_fig) VALUES(@wk_case_no,10,0,0,0)


-- 產生分期繳款資料
WHILE	@wk_counter < @wk_loan_perd
BEGIN

	if @wk_cap_code = 'O1'
	BEGIN
		select @wk_expt_date = DATEADD(month,@wk_counter,@wk_strt_date)
		SELECT	 @wk_ATM_codeB = kc_ATM_codeB FROM	kcsd.kc_customerloan
		EXEC [dbo].[p_kc_GetATMCodeB] @wk_ATM_codeB OUTPUT, @wk_perd_fee, @wk_expt_date
	INSERT	kcsd.kc_loanpayment
		(kc_case_no, kc_perd_no, kc_expt_date, kc_expt_fee, kc_area_code,kc_ATM_codeB)
	VALUES	(@wk_case_no,@wk_perd_no+@wk_counter+1,	@wk_expt_date ,@wk_perd_fee, @wk_area_code,@wk_ATM_codeB)

	SELECT	@wk_counter=@wk_counter+1
	END
	ELSE
	BEGIN
	INSERT	kcsd.kc_loanpayment
		(kc_case_no, kc_perd_no, kc_expt_date, kc_expt_fee, kc_area_code)
	VALUES	(@wk_case_no,@wk_perd_no+@wk_counter+1,
		DATEADD(month,@wk_counter,@wk_strt_date),@wk_perd_fee, @wk_area_code)
	SELECT	@wk_counter=@wk_counter+1
	END
END

--產生支票紀錄
IF	@wk_give_type = 'H' AND (@wk_area_code = '01' OR @wk_area_code = '02')
BEGIN
	IF	@wk_area_code = '02'
		SELECT	@wk_acc_code = 'C2'
	ELSE IF @wk_area_code = '01'
		 BEGIN
			IF @wk_issu_code = '01'
				SELECT	@wk_acc_code = 'L1'
			ELSE IF @wk_issu_code = '03'
				SELECT	@wk_acc_code = 'L6'
		 END
		
	SELECT	@wk_chk_max2 = ISNULL(MAX(kc_chk_no),'0000000') FROM kcsd.kc_checkserial WHERE	kc_acc_code = @wk_acc_code
	SELECT	@wk_chk_max = RTRIM(LTRIM(@wk_chk_max2))
	SELECT	@wk_chk_no = RIGHT('0000000'+LTRIM(RTRIM(CONVERT(char,CONVERT(int,@wk_chk_max)+1 ))),7)

	SELECT	@wk_agent_name = substring(kc_agent_name,1,5) FROM kcsd.kc_caragent WHERE kc_agent_code = @wk_comp_code
	--找出分公司名稱
	SELECT	@wk_area_desc = kc_area_desc FROM kcsd.kct_area	WHERE kc_area_code = @wk_area_code
	--撥款金額
	SELECT	@wk_rece_name = @wk_area_desc + @wk_case_no + RTRIM(@wk_agent_name) + '*' + RTRIM(@wk_cust_nameu)
	--支票查詢key
	SELECT	@wk_acc_ymd = @wk_acc_code + CONVERT(char(6), @wk_buy_date,12)

	INSERT	kcsd.kc_check
		(kc_acc_code, kc_chk_no, kc_write_date, kc_pay_date,kc_pay_amt, kc_rece_name, kc_chk_stat, kc_chk_type, kc_chk_memo, kc_case_no, kc_acc_ymd, kc_updt_user, kc_updt_date)
	VALUES	(@wk_acc_code, @wk_chk_no, @wk_buy_date, @wk_buy_date,@wk_give_amt, @wk_rece_name, 'W', 'F1', @wk_data_memo, @wk_case_no, @wk_acc_ymd, @wk_crdt_user, GETDATE())

	UPDATE	kcsd.kc_customerloan SET kc_chk_no = @wk_chk_no	WHERE kc_case_no = @wk_case_no
	-- 更新支票序號
	UPDATE	kcsd.kc_checkserial	SET	kc_chk_no = @wk_chk_no WHERE kc_acc_code = @wk_acc_code
END

-- 在保險資料內(kc_insurance_list) 填入 case_no		
	UPDATE	kcsd.kc_insurance_list SET	kc_case_no = @wk_case_no 
	WHERE	kc_cp_no = @wk_cp_no
	AND	(	kc_case_no IS NULL	OR	kc_case_no <> @wk_cp_no)

	/* 儲存客戶資料 */
	EXECUTE kcsd.p_kc_customer_add @wk_cust_nameu, @wk_id_no, 'C', @wk_area_code
	EXECUTE kcsd.p_kc_customer_add @wk_cust_name1u, @wk_id_no1, 'D', @wk_area_code
	EXECUTE kcsd.p_kc_customer_add @wk_cust_name2u, @wk_id_no2, 'D', @wk_area_code

	/* 產生ID姓名歷史資料 */
	EXECUTE kcsd.p_kc_addcustnamehistory @wk_case_no,0,@wk_id_no,@wk_cust_nameu	--本人
	IF	@wk_id_no1 is not null
	EXECUTE kcsd.p_kc_addcustnamehistory @wk_case_no,1,@wk_id_no1,@wk_cust_name1u	--保1
	IF	@wk_id_no2  is not null
	EXECUTE kcsd.p_kc_addcustnamehistory @wk_case_no,2,@wk_id_no2,@wk_cust_name2u	--保2

	/* 產生地址電話歷史資料 */
	/* 本人 */
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A1', @wk_perm_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A2', @wk_curr_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A3', @wk_comp_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A4', @wk_trans_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P1', @wk_perm_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P2', @wk_curr_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P3', @wk_comp_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P4', @wk_mobil_no
	/* 保人1 */
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A1', @wk_perm_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A2', @wk_curr_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A3', @wk_comp_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P1', @wk_perm_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P2', @wk_curr_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P3', @wk_comp_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P4', @wk_mobil_no1
	/* 保人2 */
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A1', @wk_perm_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A2', @wk_curr_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A3', @wk_comp_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P1', @wk_perm_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P2', @wk_curr_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P3', @wk_comp_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P4', @wk_mobil_no2

GO
/* 
==========================================================================================
2017-09-08 刪除Unicode Name更新、updt更新、舊型保險欄位鎖定
2017-08-14 發票計算後禁止修改特定欄位
2013-08-16 修改契約狀態時轉入催繳紀錄
11/25/2011 KC: fix Q0007人名太長無法修改
09/05/09 KC: 只有DYS01才做insurance_list填入case_no
05/16/09 KC: 在保險資料內(kc_insurance_list) 填入 case_no
09/27/08 處理 Unicode Name
01/16/08 手動轉給非法務, 判斷同一月份是否轉法務, 是的話刪除法務指派 (fixed)
01/15/08 手動指派日改為->只有日期,沒有時間
01/12/08 指派結束日改為->新指派日前1日
01/05/08 手動轉給非法務, 判斷同一月份是否轉法務, 是的話刪除法務指派
03/11/06 KC: 新增計算法務外包指派 逾期金額及違約金 
==========================================================================================
*/
CREATE	TRIGGER [kcsd].[t_kc_customerloan_u]
ON kcsd.kc_customerloan 
FOR UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_loan_perd	int,
	@wk_loan_perd2	int,
	@wk_perd_no	int,
	@wk_expt_date	datetime,
	@wk_expt_fee	int,
	@wk_strt_date	datetime,
	--job assign
	@wk_pusher_code	varchar(6),
	@wk_pusher_date	datetime,
	@wk_boro_code	varchar(6),
	--Area change
	@wk_area_code	varchar(2),
	--
	@wk_push_note	varchar(200),
	@wk_boro_stat	varchar(20),
	@wk_boro_code1	varchar(20),
	@wk_boro_memo	varchar(200),
	@wk_boro_date	datetime,
	@wk_item_no		smallint,
	--INVOICE
	@wk_invo_flag	varchar(1),

	--本人
	@wk_id_no		varchar(10),
	@wk_cust_nameu	nvarchar(60),
	@wk_perm_addr	varchar(100),
	@wk_curr_addr		varchar(100),
	@wk_comp_addr	varchar(100),
	@wk_perm_addr_nt	varchar(100),
	@wk_curr_addr_nt	varchar(100),
	@wk_comp_addr_nt	varchar(100),
	@wk_trans_addr	varchar(100),
	@wk_bill_addr		varchar(100),
	@wk_perm_phone	varchar(20),
	@wk_curr_phone	varchar(20),
	@wk_comp_phone	varchar(20),
	@wk_mobil_no		varchar(12),
	@wk_perm_phone_nt	varchar(100),
	@wk_curr_phone_nt	varchar(100),
	@wk_comp_phone_nt	varchar(100),
	@wk_mobil_no_nt	varchar(100),

	--保1
	@wk_id_no1		varchar(10),
	@wk_cust_name1u	nvarchar(60),
	@wk_perm_addr1	varchar(100),
	@wk_curr_addr1	varchar(100),
	@wk_comp_addr1	varchar(100),
	@wk_perm_addr1_nt	varchar(100),
	@wk_curr_addr1_nt	varchar(100),
	@wk_comp_addr1_nt	varchar(100),
	@wk_perm_phone1	varchar(20),
	@wk_curr_phone1	varchar(20),
	@wk_comp_phone1	varchar(20),
	@wk_mobil_no1		varchar(12),
	@wk_perm_phone1_nt	varchar(100),
	@wk_curr_phone1_nt	varchar(100),
	@wk_comp_phone1_nt	varchar(100),
	@wk_mobil_no1_nt	varchar(100),

	--保2
	@wk_id_no2		varchar(10),
	@wk_cust_name2u	nvarchar(60),
	@wk_perm_addr2	varchar(100),
	@wk_curr_addr2	varchar(100),
	@wk_comp_addr2	varchar(100),
	@wk_perm_addr2_nt	varchar(100),
	@wk_curr_addr2_nt	varchar(100),
	@wk_comp_addr2_nt	varchar(100),
	@wk_perm_phone2	varchar(20),
	@wk_curr_phone2	varchar(20),
	@wk_comp_phone2	varchar(20),
	@wk_mobil_no2		varchar(12),
	@wk_perm_phone2_nt	varchar(100),
	@wk_curr_phone2_nt	varchar(100),
	@wk_comp_phone2_nt	varchar(100),
	@wk_mobil_no2_nt	varchar(100)

SELECT	@wk_case_no = NULL, @wk_loan_perd = 0, @wk_loan_perd2 = 0,
	@wk_cust_nameu = NULL,@wk_cust_name1u = NULL,@wk_cust_name2u = NULL,
	@wk_perd_no = 0, @wk_expt_date = NULL, @wk_expt_fee = 0,
	@wk_pusher_code = NULL, @wk_pusher_date=NULL,
	@wk_boro_code=NULL, @wk_area_code = NULL, @wk_invo_flag = NULL
	
SELECT	@wk_case_no = kc_case_no, @wk_loan_perd2 = kc_loan_perd
FROM	inserted

SELECT	@wk_id_no = kc_id_no, @wk_id_no1 = kc_id_no1, @wk_id_no2 = kc_id_no2,
	@wk_cust_nameu = kc_cust_nameu,@wk_cust_name1u = kc_cust_name1u,@wk_cust_name2u = kc_cust_name2u,
	@wk_perm_addr=kc_perm_addr,@wk_perm_addr1=kc_perm_addr1,@wk_perm_addr2=kc_perm_addr2,
	@wk_curr_addr=kc_curr_addr,@wk_curr_addr1=kc_curr_addr1,@wk_curr_addr2=kc_curr_addr2,
	@wk_comp_addr=kc_comp_addr,
	@wk_perm_addr_nt=kc_perm_addr_nt,@wk_perm_addr1_nt=kc_perm_addr1_nt,@wk_perm_addr2_nt=kc_perm_addr2_nt,
	@wk_curr_addr_nt=kc_curr_addr_nt,@wk_curr_addr1_nt=kc_curr_addr1_nt,@wk_curr_addr2_nt=kc_curr_addr2_nt,
	@wk_comp_addr_nt=kc_comp_addr_nt,

	@wk_trans_addr=kc_trans_addr, @wk_bill_addr=kc_bill_addr,
	@wk_perm_phone=kc_perm_phone,@wk_perm_phone1=kc_perm_phone1,@wk_perm_phone2=kc_perm_phone2,
	@wk_curr_phone=kc_curr_phone,@wk_curr_phone1=kc_curr_phone1,@wk_curr_phone2=kc_curr_phone2,
	@wk_comp_phone=kc_comp_phone,@wk_comp_phone1=kc_comp_phone1,@wk_comp_phone2=kc_comp_phone2,
	@wk_mobil_no=kc_mobil_no, @wk_mobil_no1=kc_mobil_no1, @wk_mobil_no2=kc_mobil_no2,
	@wk_perm_phone_nt=kc_perm_phone_nt,@wk_perm_phone1_nt=kc_perm_phone1_nt,@wk_perm_phone2_nt=kc_perm_phone2_nt,
	@wk_curr_phone_nt=kc_curr_phone_nt,@wk_curr_phone1_nt=kc_curr_phone1_nt,@wk_curr_phone2_nt=kc_curr_phone2_nt,
	@wk_comp_phone_nt=kc_comp_phone_nt,@wk_comp_phone1_nt=kc_comp_phone1_nt,@wk_comp_phone2_nt=kc_comp_phone2_nt,
	@wk_mobil_no_nt=kc_mobil_no_nt, @wk_mobil_no1_nt=kc_mobil_no1_nt, @wk_mobil_no2_nt=kc_mobil_no2_nt,

	@wk_pusher_code=kc_pusher_code, @wk_pusher_date=kc_pusher_date,
	@wk_area_code = kc_area_code,
	@wk_boro_stat = kc_boro_stat,@wk_boro_code1=kc_boro_code,@wk_boro_memo =kc_boro_memo,@wk_boro_date=kc_boro_date
FROM	inserted

-- 取得是否開立過發票 (發票 已經計算過發票 --> 禁止修改)
SELECT @wk_invo_flag = CASE WHEN COUNT(*) > 0 THEN 'Y' ELSE NULL END FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_invo_flag IS NOT NULL

IF (@wk_invo_flag IS NOT NULL)
AND (UPDATE(kc_loan_perd)
OR	UPDATE(kc_perd_fee)
OR	UPDATE(kc_intr_rate)
OR	UPDATE(kc_total_price)
OR	UPDATE(kc_strt_fee)
OR	UPDATE(kc_rule_fee)
OR	UPDATE(kc_cred_fee)
OR	UPDATE(kc_insu_sum))
BEGIN
	RAISERROR ('-- [SYS] 已計算過發票已鎖定, 禁止修改 !!! --',18,2)
	ROLLBACK TRANSACTION
	RETURN
END

-- 產生分期繳款資料
IF	UPDATE(kc_loan_perd)
BEGIN
	/* ¿·?o¡yª│cÛ?ã */
	SELECT	@wk_expt_fee = kc_perd_fee, @wk_strt_date = kc_strt_date
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* ¿·?o¡yª│┤┴╝ã */
	SELECT	@wk_loan_perd = MAX(kc_perd_no)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	SELECT	@wk_perd_no = @wk_loan_perd + 1

	/*SELECT	'UPDATE!!',@wk_case_no,@wk_loan_perd2,@wk_loan_perd, @wk_perd_no */

	IF	@wk_loan_perd2 > @wk_loan_perd
	BEGIN
		WHILE	@wk_perd_no <= @wk_loan_perd2
		BEGIN
			INSERT	kcsd.kc_loanpayment (kc_case_no, kc_perd_no, kc_expt_date, kc_expt_fee, kc_area_code)
			VALUES (@wk_case_no,@wk_perd_no,DATEADD(month,@wk_perd_no-1,@wk_strt_date),@wk_expt_fee, @wk_area_code)
			SELECT	@wk_perd_no = @wk_perd_no + 1
		END		
	END
END

/* 催收指派 */
IF	UPDATE(kc_pusher_code)
AND	( (@wk_pusher_code IS NULL AND @wk_pusher_date IS NOT NULL)
	OR (@wk_pusher_code IS NOT NULL AND @wk_pusher_date IS NULL) )
BEGIN
	RAISERROR ('[SYS] 催收人員/指派日期需同時空白或非空白 !!!',18,2)
	ROLLBACK TRANSACTION
	RETURN
END

/* 改區 */
IF	UPDATE (kc_area_code)
BEGIN
	UPDATE	kcsd.kc_loanpayment
	SET	kc_area_code = @wk_area_code
	WHERE	kc_case_no = @wk_case_no
END

--修改契約狀態時轉入催繳紀錄
IF	UPDATE(kc_boro_stat) AND (@wk_boro_stat IS NOT NULL)
BEGIN
	SELECT @wk_boro_stat = isnull(kc_boro_desc,'') from kcsd.kct_bookstatus where kc_boro_stat = @wk_boro_stat
	SELECT @wk_boro_code1 = isnull(EmpName,'') from kcsd.v_Employee where EmpCode = @wk_boro_code1
	SELECT @wk_item_no = isnull(max(kc_item_no),0)+1 from kcsd.kc_push where kc_case_no = @wk_case_no

	SELECT	@wk_push_note = '[系統]: 契約-' + '<' + @wk_boro_stat  + '> ' + @wk_boro_code1 +'-'+ isnull(@wk_boro_memo,'')
	INSERT	kcsd.kc_push
		(kc_case_no, kc_area_code,kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
	VALUES	(@wk_case_no, @wk_area_code,@wk_boro_date, @wk_push_note, 0,@wk_item_no,USER,GETDATE())
END

--產生ID姓名歷史資料
IF	(UPDATE(kc_cust_nameu) OR  UPDATE(kc_id_no)) and @wk_id_no IS NOT NULL
	EXEC kcsd.p_kc_addcustnamehistory @wk_case_no,0,@wk_id_no,@wk_cust_nameu	--本人
IF	(UPDATE(kc_cust_name1u) OR  UPDATE(kc_id_no1)) and @wk_id_no1 IS NOT NULL
	EXEC kcsd.p_kc_addcustnamehistory @wk_case_no,1,@wk_id_no1,@wk_cust_name1u	--保1
IF	(UPDATE(kc_cust_name2u) OR  UPDATE(kc_id_no2)) and @wk_id_no2  IS NOT NULL
EXEC kcsd.p_kc_addcustnamehistory @wk_case_no,2,@wk_id_no2,@wk_cust_name2u	--保2

--產生地址歷史資料
/* 本人 */
IF	UPDATE(kc_perm_addr) OR UPDATE(kc_perm_addr_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'A1', @wk_perm_addr, @wk_perm_addr_nt
IF	UPDATE(kc_curr_addr) OR UPDATE(kc_curr_addr_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'A2', @wk_curr_addr, @wk_curr_addr_nt
IF	UPDATE(kc_comp_addr) OR UPDATE(kc_comp_addr_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'A3', @wk_comp_addr, @wk_comp_addr_nt
IF	UPDATE(kc_trans_addr)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'A4', @wk_trans_addr
IF	UPDATE(kc_bill_addr)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'A5', @wk_bill_addr
IF	UPDATE(kc_perm_phone) OR UPDATE(kc_perm_phone_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'P1', @wk_perm_phone, @wk_perm_phone_nt
IF	UPDATE(kc_curr_phone) OR UPDATE(kc_curr_phone_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'P2', @wk_curr_phone, @wk_curr_phone_nt
IF	UPDATE(kc_comp_phone) OR UPDATE(kc_comp_phone_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'P3', @wk_comp_phone, @wk_comp_phone_nt
IF	UPDATE(kc_mobil_no) OR UPDATE(kc_mobil_no_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no, 'P4', @wk_mobil_no, @wk_mobil_no_nt

/* 保人1 */
IF	UPDATE(kc_perm_addr1) OR UPDATE(kc_perm_addr1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'A1', @wk_perm_addr1, @wk_perm_addr1_nt
IF	UPDATE(kc_curr_addr1) OR UPDATE(kc_curr_addr1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'A2', @wk_curr_addr1, @wk_curr_addr1_nt
IF	UPDATE(kc_perm_phone1) OR UPDATE(kc_perm_phone1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'P1', @wk_perm_phone1, @wk_perm_phone1_nt
IF	UPDATE(kc_curr_phone1) OR UPDATE(kc_curr_phone1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'P2', @wk_curr_phone1, @wk_curr_phone1_nt
IF	UPDATE(kc_comp_phone1) OR UPDATE(kc_comp_phone1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'P3', @wk_comp_phone1, @wk_comp_phone1_nt
IF	UPDATE(kc_mobil_no1) OR UPDATE(kc_mobil_no1_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no1, 'P4', @wk_mobil_no1, @wk_mobil_no1_nt

/* 保人2 */
IF	UPDATE(kc_perm_addr2) OR UPDATE(kc_perm_addr2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'A1', @wk_perm_addr2, @wk_perm_addr2_nt
IF	UPDATE(kc_curr_addr2) OR UPDATE(kc_curr_addr2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'A2', @wk_curr_addr2, @wk_curr_addr2_nt
IF	UPDATE(kc_perm_phone2) OR UPDATE(kc_perm_phone2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'P1', @wk_perm_phone2, @wk_perm_phone2_nt
IF	UPDATE(kc_curr_phone2) OR UPDATE(kc_curr_phone2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'P2', @wk_curr_phone2, @wk_curr_phone2_nt
IF	UPDATE(kc_comp_phone2) OR UPDATE(kc_comp_phone2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'P3', @wk_comp_phone2, @wk_comp_phone2_nt
IF	UPDATE(kc_mobil_no2) OR UPDATE(kc_mobil_no2_nt)
	EXECUTE	kcsd.p_kc_addrhistory @wk_id_no2, 'P4', @wk_mobil_no2, @wk_mobil_no2_nt

CREATE TABLE [kcsd].[kc_insurance] (
    [kc_insu_no]      VARCHAR (8)   NOT NULL,
    [kc_item_no]      INT           CONSTRAINT [DF_kc_insurance_kc_item_no] DEFAULT ((1)) NOT NULL,
    [kc_insu_src]     VARCHAR (2)   NOT NULL,
    [kc_insu_type]    VARCHAR (2)   NOT NULL,
    [kc_cust_name]    VARCHAR (60)  NOT NULL,
    [kc_cust_nameu]   NVARCHAR (60) NULL,
    [kc_cust_name1]   NVARCHAR (60) NULL,
    [kc_cust_name2]   NVARCHAR (60) NULL,
    [kc_case_no]      VARCHAR (10)  NULL,
    [kc_area_code]    VARCHAR (2)   NULL,
    [kc_issu_code]    VARCHAR (6)   NULL,
    [kc_loan_type]    VARCHAR (2)   NULL,
    [kc_car_brand]    VARCHAR (2)   NULL,
    [kc_car_model]    VARCHAR (50)  NULL,
    [kc_eng_no]       VARCHAR (30)  NULL,
    [kc_licn_no]      VARCHAR (10)  NULL,
    [kc_new_flag]     VARCHAR (1)   NULL,
    [kc_comp_code]    VARCHAR (30)  NULL,
    [kc_licn_date]    SMALLDATETIME NULL,
    [kc_licn_date2]   SMALLDATETIME NULL,
    [kc_fax_date]     SMALLDATETIME NULL,
    [kc_rema_date]    SMALLDATETIME NULL,
    [kc_cont_date]    SMALLDATETIME NULL,
    [kc_dism_date]    SMALLDATETIME NULL,
    [kc_insu_amt]     INT           NULL,
    [kc_insu_amt2]    INT           NULL,
    [kc_insu_fee]     INT           NULL,
    [kc_insu_fee2]    INT           NULL,
    [kc_real_fee]     INT           NULL,
    [kc_sales_code]   VARCHAR (6)   NULL,
    [kc_wtdt_user]    VARCHAR (10)  NULL,
    [kc_wddt_user]    VARCHAR (10)  NULL,
    [kc_id_no]        VARCHAR (10)  NULL,
    [kc_birth_date]   SMALLDATETIME NULL,
    [kc_perm_addr]    VARCHAR (100) NULL,
    [kc_insu_memo]    VARCHAR (255) NULL,
    [kc_updt_user]    VARCHAR (20)  NULL,
    [kc_updt_date]    SMALLDATETIME NULL,
    [kc_rewd_type]    VARCHAR (2)   NULL,
    [kc_rewd_amt]     INT           NULL,
    [kc_rewd_date]    SMALLDATETIME NULL,
    [kc_rewd_datec]   SMALLDATETIME NULL,
    [kc_rewd_amtc]    INT           NULL,
    [kc_info_date]    SMALLDATETIME NULL,
    [kc_info_datec]   SMALLDATETIME NULL,
    [kc_info_datep]   SMALLDATETIME NULL,
    [kc_take_date]    SMALLDATETIME NULL,
    [kc_find_date]    SMALLDATETIME NULL,
    [kc_icard_no]     VARCHAR (9)   NULL,
    [kc_icard_type]   VARCHAR (2)   NULL,
    [kc_other_fee]    INT           NULL,
    [kc_oper_type]    VARCHAR (1)   NULL,
    [kc_oper_code]    VARCHAR (30)  NULL,
    [kc_proc_fee]     INT           NULL,
    [kc_ppay_fee]     INT           NULL,
    [kc_pay_type]     VARCHAR (1)   NULL,
    [kc_pay_date]     SMALLDATETIME NULL,
    [kc_lock_date]    SMALLDATETIME NULL,
    [kc_lock_amt]     TINYINT       NULL,
    [kc_lock_amt2]    TINYINT       NULL,
    [kc_lock_amt3]    TINYINT       NULL,
    [kc_totm_fee]     INT           NULL,
    [kc_totm_tick]    VARCHAR (1)   NULL,
    [kc_totm_date]    SMALLDATETIME NULL,
    [kc_insuend_date] DATETIME      NULL,
    [kc_rewd_no]      VARCHAR (12)  NULL,
    [kc_rewd_officer] NVARCHAR (60) NULL,
    [kc_rewd_name]    VARCHAR (20)  NULL,
    [kc_theft_date]   DATETIME      NULL,
    [kc_theft_addr]   VARCHAR (100) NULL,
    [kc_reprot_date]  DATETIME      NULL,
    [kc_station_area] VARCHAR (10)  NULL,
    [kc_station_name] VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_insurance_1__23] PRIMARY KEY CLUSTERED ([kc_insu_no] ASC, [kc_item_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_insurance]
    ON [kcsd].[kc_insurance]([kc_case_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_insurance_2]
    ON [kcsd].[kc_insurance]([kc_area_code] ASC);


GO
CREATE    TRIGGER [kcsd].[t_kc_insurance_u] ON kcsd.kc_insurance 
FOR UPDATE NOT FOR REPLICATION
AS

/* SUBSTRING('½¦©╔', 1, 2)='½¦©╔'!!!! 1 chinese char is treat as 1 char !!*/
/* 
7/7/2001 KC: src=01 & paytype=L, ÑI┤┌ñÚÀ|┬ÓñJ┬°ñõ¿R▒b
8/4/2001 KC: src=01 & paytype=M, ÑI┤┌ñÚÀ|┬ÓñJ┬°ñõ¿R▒b(ÑÐLº´M)
8/25/2001 KC sadness: ▓z¢▀ñÚ(ñõ) or »Þ┴p▓z¢▀ñÚ(ª¼) À|┬ÓñJ┬°ñõ
12/29/2001 KC unclear: src=06 & paytype=M, ÑI┤┌ñÚÀ|┬ÓñJ┬°ñõ¿R▒b(ÑÐLº´M)
*/
DECLARE	@wk_insu_no	varchar(8)
	
SELECT	@wk_insu_no = kc_insu_no
FROM	inserted

IF	USER <> 'dbo'
	UPDATE	kcsd.kc_insurance
	SET	kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_insu_no = @wk_insu_no

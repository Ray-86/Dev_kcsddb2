CREATE TABLE [kcsd].[kc_caragent] (
    [kc_agent_code]        VARCHAR (30)  NOT NULL,
    [kc_biz_stat]          VARCHAR (10)  NULL,
    [kc_agent_phone]       VARCHAR (30)  NULL,
    [kc_agent_phon2]       VARCHAR (30)  NULL,
    [kc_call_date]         SMALLDATETIME NULL,
    [kc_agent_name]        VARCHAR (30)  NULL,
    [kc_fax_no]            VARCHAR (20)  NULL,
    [kc_agent_addr]        VARCHAR (100) NULL,
    [kc_regn_code]         VARCHAR (5)   NULL,
    [kc_bank_code]         VARCHAR (7)   NULL,
    [kc_acc_code]          VARCHAR (20)  NULL,
    [kc_acc_name]          VARCHAR (40)  NULL,
    [kc_boss_name]         VARCHAR (30)  NULL,
    [kc_build_user]        VARCHAR (6)   NULL,
    [kc_build_date]        SMALLDATETIME NULL,
    [kc_updt_user]         VARCHAR (20)  NULL,
    [kc_updt_date]         SMALLDATETIME NULL,
    [kc_agent_memo]        VARCHAR (200) NULL,
    [kc_town_code]         VARCHAR (10)  NULL,
    [kc_city_name]         VARCHAR (30)  NULL,
    [kc_lock_flag]         VARCHAR (4)   NULL,
    [kc_agent_cfmStat]     VARCHAR (5)   NULL,
    [kc_agent_stat]        VARCHAR (4)   NULL,
    [kc_sales_code]        VARCHAR (6)   NULL,
    [kc_sale_qty]          SMALLINT      NULL,
    [kc_sale_grade]        VARCHAR (10)  NULL,
    [kc_sales_code2]       VARCHAR (10)  NULL,
    [kc_is_foreign]        VARCHAR (1)   CONSTRAINT [DF_kc_caragent_kc_is_foreign] DEFAULT ('N') NULL,
    [kc_is_interDist]      VARCHAR (1)   CONSTRAINT [DF_kc_caragent_kc_is_interDist] DEFAULT ('N') NULL,
    [kc_dev_date]          DATE          NULL,
    [kc_agent_type]        VARCHAR (10)  NULL,
    [kc_area_code]         VARCHAR (2)   NULL,
    [kc_audit_user]        VARCHAR (10)  NULL,
    [kc_audit_date]        DATETIME      NULL,
    [kc_contact_name]      VARCHAR (30)  NULL,
    [kc_taxid_no]          VARCHAR (8)   NULL,
    [kc_comp_name]         VARCHAR (30)  NULL,
    [kc_creditmgr_user]    VARCHAR (6)   NULL,
    [kc_pos_lat]           VARCHAR (20)  NULL,
    [kc_pos_lon]           VARCHAR (20)  NULL,
    [kc_bobosales_code]    VARCHAR (4)   NULL,
    [kc_rate_type]         VARCHAR (2)   NULL,
    [kc_vip_type]          VARCHAR (2)   NULL,
    [kc_give_type]         VARCHAR (2)   NULL,
    [kc_is_dudu]           VARCHAR (1)   NULL,
    [kc_ID0K_type]         VARCHAR (2)   NULL,
    [kc_proc_per]          FLOAT (53)    NULL,
    [kc_proc_type]         VARCHAR (2)   NULL,
    [kc_bobocms_type]      VARCHAR (2)   NULL,
    [kc_fixedurl]          VARCHAR (200) NULL,
    [kc_duducms_type]      VARCHAR (2)   NULL,
    [kc_duduapi_type]      VARCHAR (2)   NULL,
    [kc_duduautogive_type] VARCHAR (2)   NULL,
    [kc_agent_url]         VARCHAR (100) NULL,
    [kc_duduMall_type]     VARCHAR (2)   NULL,
    [kc_LineCreatet_type]  VARCHAR (2)   NULL,
    CONSTRAINT [PK_kc_caragent_1__18] PRIMARY KEY CLUSTERED ([kc_agent_code] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_caragent_2]
    ON [kcsd].[kc_caragent]([kc_area_code] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [i_kc_caragent_1]
    ON [kcsd].[kc_caragent]([kc_agent_code] ASC, [kc_agent_name] ASC);


GO
-- =============================================
-- 06/01/06 KC: 開放 kc_call_date 隨時可改
-- =============================================
CREATE   TRIGGER [kcsd].[t_kc_caragent_u] ON kcsd.kc_caragent
FOR UPDATE NOT FOR REPLICATION
AS
DECLARE	@wk_agent_code	varchar(10),
	@wk_lock_flag	varchar(1),
	@wk_adms_flag	varchar(1),
	@wk_updt_user	varchar(20)

SELECT	@wk_agent_code = NULL,
	@wk_lock_flag = NULL,
	@wk_adms_flag = NULL

SELECT	@wk_agent_code = kc_agent_code
FROM	inserted

SELECT	@wk_lock_flag = kc_lock_flag
FROM	deleted

/*
SELECT	@wk_lock_flag = RTRIM(kc_lock_flag)
FROM	kcsd.kc_caragent
WHERE	kc_agent_code = @wk_agent_code
*/

SELECT	@wk_updt_user = USER
EXECUTE	kcsd.p_kc_getuserinfo_ismember_sub 'ADMS', @wk_updt_user, @wk_adms_flag OUTPUT


IF	USER = 'dbo'  RETURN

--UPDATE	kcsd.kc_caragent
--SET	kc_updt_user = USER, kc_updt_date = GETDATE()
--WHERE	kc_agent_code = @wk_agent_code


--IF	USER = 'ADMS'  RETURN

--IF	@wk_lock_flag = 'Y'
--AND	@wk_adms_flag <> 'Y'
--AND	NOT UPDATE(kc_call_date)	-- 06/01/06
--BEGIN
--	RAISERROR ('---- [KC] 資料已鎖定, 不准修改 !!!',18,2) WITH SETERROR
--	ROLLBACK TRANSACTION
--	RETURN
--END

GO
CREATE  TRIGGER [kcsd].[t_kc_caragent_i] ON kcsd.kc_caragent
FOR INSERT NOT FOR REPLICATION
AS
DECLARE	@wk_agent_code	varchar(10),
	@wk_emp_code	varchar(6)

SELECT	@wk_agent_code = NULL, @wk_emp_code = NULL

SELECT	@wk_agent_code = kc_agent_code
FROM	inserted

/* Get emp code */

--SELECT	@wk_emp_code = kc_emp_code
--FROM	kcsd.kc_employee
--WHERE	kc_user_name = USER

--UPDATE	kcsd.kc_caragent
--SET	kc_build_user = @wk_emp_code , kc_build_date = GETDATE()
--WHERE	kc_agent_code = @wk_agent_code

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 登記現況 [AgentBizStat] ( 25.08.04 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_biz_stat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_agent_phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 審核狀態 [AgentCfmStat] ( 25.08.04 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_agent_cfmStat';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 外籍人士 ( 25.08.04 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_is_foreign';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 跨區開發 ( 25.08.04 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_is_interDist';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'2506200002 - 開發日期 ( 25.08.04 Ray )', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_dev_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DuDu邀請 (25.05.21 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_is_dudu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DUDU權限_API功能 (25.06.02 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_duduapi_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DUDU權限_自動撥款(25.06.02 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_duduautogive_type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DUDU權限_API功能 (25.06.02 Ray)', @level0type = N'SCHEMA', @level0name = N'kcsd', @level1type = N'TABLE', @level1name = N'kc_caragent', @level2type = N'COLUMN', @level2name = N'kc_duduMall_type';


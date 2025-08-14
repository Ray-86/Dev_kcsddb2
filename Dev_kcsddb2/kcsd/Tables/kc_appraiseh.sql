CREATE TABLE [kcsd].[kc_appraiseh] (
    [kc_case_no]          VARCHAR (10)  NOT NULL,
    [kc_area_code]        VARCHAR (2)   NOT NULL,
    [kc_item_no]          SMALLINT      NOT NULL,
    [kc_detain_date]      DATETIME      NULL,
    [kc_detain_addr]      VARCHAR (100) NULL,
    [kc_appraise_stat]    VARCHAR (2)   NULL,
    [kc_licn_date]        DATETIME      NULL,
    [kc_interest_fee]     INT           NULL,
    [kc_proc_fee]         INT           NULL,
    [kc_data_memo]        VARCHAR (150) NULL,
    [kc_updt_user]        VARCHAR (10)  NULL,
    [kc_updt_date]        SMALLDATETIME NULL,
    [kc_auction_addr]     VARCHAR (200) NULL,
    [kc_auction_date]     DATETIME      NULL,
    [kc_bidder_name]      NVARCHAR (60) NULL,
    [kc_bidder_id]        VARCHAR (10)  NULL,
    [kc_evidence_date]    DATETIME      NULL,
    [kc_guild_code]       VARCHAR (2)   NULL,
    [kc_certificate_date] DATETIME      NULL,
    [kc_ticket_date]      DATETIME      NULL,
    [kc_xferapply_date]   DATETIME      NULL,
    [kc_factory_date]     DATETIME      NULL,
    [kc_tick_flag]        VARCHAR (1)   NULL,
    [kc_paint_flag]       VARCHAR (1)   NULL,
    [kc_shell_flag]       VARCHAR (1)   NULL,
    [kc_modiengine_flag]  VARCHAR (1)   NULL,
    [kc_modishell_flag]   VARCHAR (1)   NULL,
    [kc_missingpart_flag] VARCHAR (1)   NULL,
    [kc_badpart_flag]     VARCHAR (1)   NULL,
    [kc_accident_flag]    VARCHAR (1)   NULL,
    [kc_vehiclecard_flag] VARCHAR (1)   NULL,
    [kc_idcard_flag]      VARCHAR (1)   NULL,
    [kc_carkey_flag]      VARCHAR (1)   NULL,
    [kc_check_memo]       VARCHAR (150) NULL,
    [kc_tick_amt]         INT           NULL,
    [kc_insu_date]        DATETIME      NULL,
    [kc_auction_user]     VARCHAR (10)  NULL,
    [kc_auction_date2]    DATETIME      NULL,
    [CreatePerson]        VARCHAR (20)  NULL,
    [CreateDate]          DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_appraiseh_1]
    ON [kcsd].[kc_appraiseh]([kc_case_no] ASC, [kc_area_code] ASC, [kc_item_no] ASC);


GO
-- ==========================================================================================
-- 2015/01/20 自動帶入車況
-- 2016/07/01 移除更新主表車況，改由車況觸發更改主表
-- 2016/12/27 把INSERT跟UPDATE合併
-- ==========================================================================================
CREATE                TRIGGER [kcsd].[t_kc_appraiseh_u] ON [kcsd].[kc_appraiseh] 
FOR UPDATE NOT FOR REPLICATION
AS

DECLARE	
		@wk_case_no			varchar(10),
		@wk_detain_date		DATETIME,
		@wk_licn_date		DATETIME,
		@wk_appraise_stat	varchar(2),
		@wk_item_no			INT,
		@wk_updt_user		varchar(10)

SELECT	@wk_case_no = kc_case_no,
		@wk_appraise_stat = kc_appraise_stat,
		@wk_detain_date = kc_detain_date,
		@wk_licn_date = kc_licn_date,
		@wk_updt_user = kc_updt_user
FROM	inserted

IF USER = 'dbo' RETURN

SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no

IF @wk_appraise_stat = '10'  and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_detain_date AND kc_car_stat = 'C') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_detain_date,'C',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'C' WHERE kc_case_no = @wk_case_no
END

IF @wk_appraise_stat = '40' and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_licn_date AND kc_car_stat = 'N') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_licn_date,'N',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'N' WHERE kc_case_no = @wk_case_no
END

IF @wk_appraise_stat = '50' and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_licn_date AND kc_car_stat = 'D') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_licn_date,'D',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'D' WHERE kc_case_no = @wk_case_no
END

GO
-- ==========================================================================================
-- 2015/01/20 自動帶入車況
-- 2016/07/01 移除更新主表車況，改由車況觸發更改主表
-- 2016/12/27 把INSERT跟UPDATE合併
-- ==========================================================================================
CREATE                TRIGGER [kcsd].[t_kc_appraiseh_i] ON [kcsd].[kc_appraiseh] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	
		@wk_case_no			varchar(10),
		@wk_detain_date		DATETIME,
		@wk_licn_date		DATETIME,
		@wk_appraise_stat	varchar(2),
		@wk_item_no			INT,
		@wk_updt_user		varchar(10)

SELECT	@wk_case_no = kc_case_no,
		@wk_appraise_stat = kc_appraise_stat,
		@wk_detain_date = kc_detain_date,
		@wk_licn_date = kc_licn_date,
		@wk_updt_user = kc_updt_user
FROM	inserted

IF USER = 'dbo' RETURN

SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no

IF @wk_appraise_stat = '10'  and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_detain_date AND kc_car_stat = 'C') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_detain_date,'C',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'C' WHERE kc_case_no = @wk_case_no
END

IF @wk_appraise_stat = '40' and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_licn_date AND kc_car_stat = 'N') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_licn_date,'N',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'N' WHERE kc_case_no = @wk_case_no
END

IF @wk_appraise_stat = '50' and (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_licn_date AND kc_car_stat = 'D') = 0
BEGIN
	--SELECT @wk_item_no = isnull(MAX(kc_item_no),0)+1 FROM kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no
	INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat,kc_updt_user,kc_updt_date,kc_item_no)VALUES(@wk_case_no,@wk_licn_date,'D',@wk_updt_user,getdate(),@wk_item_no)
	--UPDATE kcsd.kc_customerloan set kc_car_stat = 'D' WHERE kc_case_no = @wk_case_no
END


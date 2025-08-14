CREATE TABLE [kcsd].[kc_carstatus] (
    [kc_case_no]     VARCHAR (10) NOT NULL,
    [kc_car_date]    DATETIME     NOT NULL,
    [kc_car_stat]    VARCHAR (1)  NOT NULL,
    [kc_item_no]     SMALLINT     NULL,
    [kc_area_code]   VARCHAR (2)  NULL,
    [kc_tick_amt]    INT          NULL,
    [kc_mfg_date]    DATETIME     NULL,
    [kc_licnov_date] DATETIME     NULL,
    [kc_remark]      VARCHAR (20) NULL,
    [kc_updt_user]   VARCHAR (20) NULL,
    [kc_updt_date]   DATETIME     NULL,
    [CreatePerson]   VARCHAR (20) NULL,
    [CreateDate]     DATETIME     NULL,
    CONSTRAINT [PK_kc_carstatus_1__17] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_car_date] ASC, [kc_car_stat] ASC)
);


GO
-- ==========================================================================================
-- 2016-05-15 更改 更新kc_customerloan車況至後端
-- ==========================================================================================

CREATE  TRIGGER [kcsd].[t_kc_carstatus_d] ON [kcsd].[kc_carstatus] 
FOR DELETE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_car_stat	char(1),
	@wk_cp_no		varchar(10)

SELECT	@wk_case_no = NULL, @wk_car_stat = NULL, @wk_cp_no = NULL

SELECT	@wk_case_no = kc_case_no
FROM	deleted

SELECT  TOP 1 @wk_car_stat = kc_car_stat from kcsd.kc_carstatus where kc_case_no = @wk_case_no order by kc_car_date desc , kc_updt_date desc
UPDATE kcsd.kc_customerloan SET kc_car_stat = @wk_car_stat WHERE kc_case_no = @wk_case_no

SELECT @wk_cp_no = kc_cp_no FROM kcsd.kc_customerloan where kc_case_no = @wk_case_no
IF @wk_car_stat = 'C'
	UPDATE kcsd.kc_movable SET kc_process_type = 'True' WHERE kc_cp_no = @wk_cp_no
GO
-- ==========================================================================================
-- 2012-10-23 增加 自動帶入催繳記錄
-- 2016-05-15 更改 更新kc_customerloan車況至後端
-- ==========================================================================================

CREATE  TRIGGER [kcsd].[t_kc_carstatus_iu] ON [kcsd].[kc_carstatus] 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_car_date	datetime,
	@wk_car_stat	char(1),
	@wk_max_date	datetime,
	@wk_tick_amt	int,
	@wk_licnov_date datetime,
	@wk_mfg_date	datetime,
	@wk_car_cdes	varchar(20),
	@wk_remark		varchar(20),
	@wk_item_no		smallint,
	@wk_push_note	varchar(200),
	@wk_area_code	varchar(2),
	@wk_updt_user	varchar(10),
	@wk_cp_no		varchar(10)

SELECT	@wk_case_no = NULL, @wk_car_stat = NULL, @wk_cp_no = NULL

SELECT	@wk_case_no = kc_case_no, @wk_car_date = kc_car_date, @wk_car_stat = kc_car_stat,
		@wk_remark = kc_remark, @wk_tick_amt = kc_tick_amt, @wk_licnov_date = kc_licnov_date,
		@wk_mfg_date = kc_mfg_date,	@wk_updt_user = kc_updt_user
FROM	inserted

SELECT  TOP 1 @wk_car_stat = kc_car_stat from kcsd.kc_carstatus where kc_case_no = @wk_case_no order by kc_car_date desc , kc_updt_date desc
UPDATE kcsd.kc_customerloan SET kc_car_stat = @wk_car_stat WHERE kc_case_no = @wk_case_no

SELECT @wk_cp_no = kc_cp_no FROM kcsd.kc_customerloan where kc_case_no = @wk_case_no
IF @wk_car_stat = 'C'
	UPDATE kcsd.kc_movable SET kc_process_type = 'True' WHERE kc_cp_no = @wk_cp_no

IF	USER = 'dbo'
	RETURN

	SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where  kc_case_no =@wk_case_no
	SELECT @wk_car_cdes = kc_car_cdes FROM kcsd.kct_carstatuscode WHERE kc_car_stat = @wk_car_stat
	SELECT @wk_item_no = isnull(max(kc_item_no),0)+1 from kcsd.kc_push where kc_case_no = @wk_case_no

	IF 	@wk_car_stat = 'H'
	BEGIN
		SELECT	@wk_push_note = '[系統]車子狀態 ' + @wk_car_cdes +' '+ isnull(left(CONVERT(varchar(12), @wk_mfg_date, 111),7),'')  +' 舊車牌:'+ isnull(@wk_remark,'')
		INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@wk_case_no,@wk_area_code, @wk_car_date, @wk_push_note, 1,@wk_item_no,@wk_updt_user,GETDATE())

	END
	else IF	@wk_tick_amt is null
	BEGIN
		SELECT	@wk_push_note = '[系統]車子狀態 ' + @wk_car_cdes +' '+ isnull(left(CONVERT(varchar(12), @wk_mfg_date, 111),7),'')  +' '+ isnull(@wk_remark,'')
		INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@wk_case_no,@wk_area_code, @wk_car_date, @wk_push_note, 1,@wk_item_no,@wk_updt_user,GETDATE())
	END
	ELSE
	BEGIN
		SELECT	@wk_push_note = '[系統]車子狀態 ' + @wk_car_cdes + ' 罰單' + isnull(CONVERT(varchar(10), @wk_tick_amt),'') +' '+ isnull(left(CONVERT(varchar(12), @wk_mfg_date,111),7),'') +' '+ isnull(@wk_remark,'')
		INSERT	kcsd.kc_push
			(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
		VALUES	(@wk_case_no, @wk_area_code,@wk_car_date, @wk_push_note, 1,@wk_item_no,@wk_updt_user,GETDATE())
	END

--SELECT  TOP 1 @wk_car_stat = kc_car_stat from kcsd.kc_carstatus where kc_case_no = @wk_case_no order by kc_item_no desc , kc_updt_date desc
--UPDATE kcsd.kc_customerloan SET kc_car_stat = @wk_car_stat WHERE kc_case_no = @wk_case_no

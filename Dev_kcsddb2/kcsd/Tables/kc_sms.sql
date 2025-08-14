CREATE TABLE [kcsd].[kc_sms] (
    [kc_case_no]      VARCHAR (10)  NOT NULL,
    [kc_item_no]      SMALLINT      NULL,
    [kc_msg_date]     DATETIME      NOT NULL,
    [kc_mobil_no]     VARCHAR (20)  NOT NULL,
    [kc_msg_body]     VARCHAR (300) NOT NULL,
    [kc_msg_id]       VARCHAR (20)  NULL,
    [kc_resp_stat]    VARCHAR (2)   NULL,
    [kc_resp_date]    DATETIME      NULL,
    [kc_dlv_time]     DATETIME      NULL,
    [kc_dlv_stat]     VARCHAR (100) NULL,
    [kc_dlv_date]     DATETIME      NULL,
    [kc_crdt_user]    VARCHAR (10)  NULL,
    [kc_crdt_date]    DATETIME      NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    [kc_updt_date]    DATETIME      NULL,
    [kc_push_link]    NVARCHAR (10) NULL,
    [kc_smscomp_type] NVARCHAR (2)  CONSTRAINT [DF_kc_sms_kc_smscomp_type] DEFAULT ((1)) NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [i_kc_sms]
    ON [kcsd].[kc_sms]([kc_case_no] ASC, [kc_msg_date] ASC, [kc_item_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_sms_2]
    ON [kcsd].[kc_sms]([kc_msg_id] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_sms_3]
    ON [kcsd].[kc_sms]([kc_updt_user] ASC, [kc_updt_date] ASC);


GO
-- 12/26/09 KC: make case_no+item_no unique
CREATE    TRIGGER [kcsd].[t_kc_sms_iu] ON kcsd.kc_sms
FOR INSERT, UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_msg_date	smalldatetime,
	@wk_item_no	smallint,
	@wk_area_code	varchar(4)


SELECT	@wk_case_no = kc_case_no, @wk_msg_date = kc_msg_date,
	@wk_item_no = kc_item_no
FROM	inserted

IF USER = 'dbo'	RETURN

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
	FROM	kcsd.kc_sms
	WHERE	kc_case_no = @wk_case_no

	/* 避免衝突: 若在HQ輸入非HQ催繳記錄則 no+10 */
	--IF	(@@servername = 'DYS01' or @@servername = 'DYAP01')
	--BEGIN
	--	SELECT	@wk_area_code = kc_area_code
	--	FROM	kcsd.kc_customerloan
	--	WHERE	kc_case_no = @wk_case_no

	--	IF	@wk_area_code <> '01'
	--		SELECT	@wk_item_no = @wk_item_no + 10
	--END
	--UPDATE	kcsd.kc_sms
	--SET	kc_item_no = @wk_item_no,
	--	kc_updt_user = USER, kc_updt_date = GETDATE()
	--WHERE	kc_case_no = @wk_case_no
	--AND	kc_msg_date = @wk_msg_date
	--AND	kc_item_no IS NULL
	UPDATE	kcsd.kc_sms
	SET	kc_item_no = @wk_item_no
	WHERE	kc_case_no = @wk_case_no
	AND	kc_msg_date = @wk_msg_date
	AND	kc_item_no IS NULL
END

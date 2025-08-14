CREATE TABLE [kcsd].[kc_lawstatus] (
    [kc_case_no]          VARCHAR (10)  NOT NULL,
    [kc_item_no]          INT           NOT NULL,
    [kc_area_code]        VARCHAR (2)   NOT NULL,
    [kc_law_date]         DATETIME      NOT NULL,
    [kc_law_code]         VARCHAR (1)   NOT NULL,
    [kc_law_fmt]          VARCHAR (4)   NULL,
    [kc_perm_flag]        VARCHAR (1)   NULL,
    [kc_curr_flag]        VARCHAR (1)   NULL,
    [kc_comp_flag]        VARCHAR (1)   NULL,
    [kc_perm_flag1]       VARCHAR (1)   NULL,
    [kc_curr_flag1]       VARCHAR (1)   NULL,
    [kc_comp_flag1]       VARCHAR (1)   NULL,
    [kc_perm_flag2]       VARCHAR (1)   NULL,
    [kc_curr_flag2]       VARCHAR (1)   NULL,
    [kc_comp_flag2]       VARCHAR (1)   NULL,
    [kc_bill_flag]        VARCHAR (1)   NULL,
    [kc_send_flag]        VARCHAR (2)   NULL,
    [kc_doc_no]           VARCHAR (40)  NULL,
    [kc_doc_date]         DATETIME      NULL,
    [kc_doc_type]         VARCHAR (20)  NULL,
    [kc_court_code]       VARCHAR (10)  NULL,
    [kc_law_amt]          INT           NULL,
    [kc_law_amt1]         INT           NULL,
    [kc_comp_date]        DATETIME      NULL,
    [kc_claims_amt]       INT           NULL,
    [kc_value_date]       DATETIME      NULL,
    [kc_rate_fee]         REAL          NULL,
    [kc_litigation_amt]   INT           NULL,
    [kc_litigation_amt1]  INT           NULL,
    [kc_litigation_amt2]  INT           NULL,
    [kc_crdt_user]        VARCHAR (10)  NULL,
    [kc_crdt_date]        DATETIME      NULL,
    [kc_updt_user]        VARCHAR (10)  NULL,
    [kc_updt_date]        DATETIME      NULL,
    [kc_comp_user]        VARCHAR (10)  NULL,
    [kc_finish_user]      VARCHAR (10)  NULL,
    [kc_finish_date]      DATETIME      NULL,
    [kc_remind_user]      NCHAR (10)    NULL,
    [CreatePerson]        VARCHAR (20)  NULL,
    [CreateDate]          DATETIME      NULL,
    [kc_legalperiod_user] VARCHAR (10)  NULL,
    [kc_legalperiod_stat] VARCHAR (2)   NULL,
    [kc_court_type]       VARCHAR (2)   NULL,
    [kc_remark]           VARCHAR (100) NULL,
    CONSTRAINT [PK_kc_lawstatus] PRIMARY KEY NONCLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [i_kc_lawstatus]
    ON [kcsd].[kc_lawstatus]([kc_case_no] ASC, [kc_law_date] ASC, [kc_law_code] ASC, [kc_law_fmt] ASC, [kc_item_no] ASC);


GO
-- ==========================================================================================
-- 2017-11-14 改寫新法務計算
-- 2017/03/01 註解已經沒再使用催告
-- 2016/08/04 更新kc_customerloan催告狀態至改至觸發程序
-- 2014/02/13 增加選擇J後取消自動帶入車況N
-- 2014/02/10 增加U註銷自動帶入車況
-- 2013/12/27 增加選擇J自動帶入車況
-- 2013-06-05 增加C/C8 計算
-- 2012-02-17 增加item欄位
-- 01/06/07 KC: 新增 C6債證增加案號及法院 (send @wk_doc_no, @wk_court_code)
-- 12/09/06 KC: 新增處理代碼H% 戶籍謄本 (send @wk_doc_date)
-- 10/01/06 KC: 新增處理代碼F
-- 12/22/05 KC: 新增許多催告代碼自動轉催繳記錄
-- ==========================================================================================
CREATE                TRIGGER [kcsd].[t_kc_lawstatus_iu] ON kcsd.kc_lawstatus 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	VARCHAR(10),
	@wk_law_date	DATETIME,
	@wk_law_code	VARCHAR(1),
	@wk_law_code2	VARCHAR(1),
	@wk_law_fmt		VARCHAR(4),
	@wk_last_date	DATETIME,
	@wk_last_code	VARCHAR(1),
	@wk_curr_code	VARCHAR(1),
	@wk_curr_date	DATETIME,
	@wk_updt_user	VARCHAR(10),

	@wk_loan_stat	VARCHAR(2),	/* 檢查是否結清 */
	@wk_perm_flag	VARCHAR(2),	/* 記錄郵寄錯誤 */
	@wk_curr_flag	VARCHAR(2),
	@wk_comp_flag	VARCHAR(2),
	@wk_perm_flag1	VARCHAR(2),
	@wk_curr_flag1	VARCHAR(2),
	@wk_comp_flag1	VARCHAR(2),
	@wk_perm_flag2	VARCHAR(2),
	@wk_curr_flag2	VARCHAR(2),
	@wk_comp_flag2	VARCHAR(2),
	@wk_bill_flag	VARCHAR(2),
	@wk_send_flag	VARCHAR(2),	/* 郵件已寄 */
	@wk_doc_date	DATETIME,	/* 公文日 */
	@wk_doc_no		VARCHAR(40),
	@wk_court_code	VARCHAR(10),
	@wk_item_no		INT,
	@wk_item_no2	INT,
	@wk_law_amt		INT,
	@wk_comp_namea	VARCHAR(10),
	@wk_comp_namea1	VARCHAR(10),
	@wk_comp_namea2	VARCHAR(10),
	@wk_rema_amt	INT,
	@wk_area_code	VARCHAR(2),
	@wk_claims_amt	INT,
	@wk_value_date	DATETIME,
	@wk_rate_fee	REAL,
	@wk_litigation_amt INT,
	@wk_litigation_amt1 INT

SELECT	@wk_last_date = NULL, @wk_last_code = NULL,
	@wk_curr_code = NULL, @wk_curr_date = NULL,
	@wk_loan_stat = NULL, @wk_doc_date = NULL

SELECT	@wk_case_no = kc_case_no, @wk_law_date = kc_law_date,
	@wk_law_code = kc_law_code, @wk_law_fmt = kc_law_fmt,
	@wk_perm_flag=kc_perm_flag, @wk_curr_flag=kc_curr_flag, @wk_comp_flag=kc_comp_flag,
	@wk_perm_flag1=kc_perm_flag1, @wk_curr_flag1=kc_curr_flag1, @wk_comp_flag1=kc_comp_flag1,
	@wk_perm_flag2=kc_perm_flag2, @wk_curr_flag2=kc_curr_flag2, @wk_comp_flag2=kc_comp_flag2,
	@wk_bill_flag = kc_bill_flag, @wk_send_flag = kc_send_flag,
	@wk_doc_date = kc_doc_date,
	@wk_doc_no = kc_doc_no, @wk_court_code = kc_court_code,
	@wk_item_no = kc_item_no, @wk_updt_user = kc_updt_user,
	@wk_law_amt = kc_law_amt, @wk_claims_amt = kc_claims_amt,
	@wk_value_date = kc_value_date, @wk_rate_fee = kc_rate_fee,
	@wk_litigation_amt = kc_litigation_amt, @wk_litigation_amt1 = kc_litigation_amt1
FROM	inserted

SELECT  TOP 1 @wk_law_code2 = kc_law_code from kcsd.kc_lawstatus where kc_case_no = @wk_case_no order by kc_law_date DESC,kc_item_no DESC,kc_updt_date DESC
UPDATE kcsd.kc_customerloan SET kc_push_stat = @wk_law_code2 WHERE kc_case_no = @wk_case_no

-- no trigger for kcsd
IF	USER = 'dbo'
	RETURN

/* 勾選成功轉入催繳記錄 */
IF	UPDATE(kc_send_flag) AND @wk_send_flag IS NOT NULL AND @wk_send_flag <> '0'
BEGIN
	IF	@wk_law_code = 'B'
	OR	@wk_law_code = 'D'	/* 12/22/05 New */
	OR	@wk_law_code = 'F'	-- 10/01/06 New
	OR	@wk_law_code = 'L'
	OR	@wk_law_code = 'O'	/* 律師函123*/
	OR	@wk_law_code = 'R'	/* 律師函123*/
	OR	@wk_law_code = 'U'
	OR	@wk_law_code = '4'	/* 律師函4  */
	OR	@wk_law_code = '5'	/* 12/22/05 New */
	OR	@wk_law_code = 'P'
	--OR	@wk_law_code = 'C' and @wk_law_fmt <> 'C8'
	OR	@wk_law_code = 'E'
	OR	@wk_law_code = 'H'
	OR	@wk_law_code = 'K'
	OR	@wk_law_code = 'W'
	OR	@wk_law_code = 'A'
	OR	@wk_law_code = 'X'
    OR	@wk_law_code = '7'
	--OR	@wk_law_code = 'C'
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, NULL, NULL, NULL, NULL, NULL,@wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL

	IF	@wk_law_code = 'Q' OR @wk_law_code = 'T'
	BEGIN
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '本人戶地', @wk_perm_flag, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '本人聯地', @wk_curr_flag, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '本人公地', @wk_comp_flag, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '本人帳地', @wk_bill_flag, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人1戶地', @wk_perm_flag1, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人1聯地', @wk_curr_flag1, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人1公地', @wk_comp_flag1, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人2戶地', @wk_perm_flag2, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人2聯地', @wk_curr_flag2, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, '保人2公地', @wk_comp_flag2, NULL, NULL, NULL, @wk_law_amt, NULL, @wk_updt_user, NULL, NULL, NULL, NULL, NULL
	END

	IF	(@wk_law_code = 'C' OR @wk_law_code = 'E' OR @wk_law_code = 'H' OR @wk_law_code = 'K') AND @wk_law_fmt <> 'C8'
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, NULL, NULL, NULL, NULL, NULL,@wk_law_amt, NULL, @wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, NULL, NULL

	IF	@wk_law_code = 'C' AND @wk_law_fmt = 'C8'
	BEGIN
		SELECT @wk_comp_namea =kc_comp_namea,@wk_comp_namea1=kc_comp_namea1,@wk_comp_namea2=kc_comp_namea2 FROM kcsd.kc_customerloan where kc_case_no = @wk_case_no

		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea, @wk_perm_flag, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea, @wk_curr_flag, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea, @wk_comp_flag, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea, @wk_bill_flag, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea1, @wk_perm_flag1, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea1, @wk_curr_flag1, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea1, @wk_comp_flag1, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea2, @wk_perm_flag2, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea2, @wk_curr_flag2, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
		EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, @wk_comp_namea2, @wk_comp_flag2, NULL, NULL, NULL,@wk_law_amt,@wk_law_date,@wk_updt_user, @wk_claims_amt, @wk_value_date, @wk_rate_fee, @wk_litigation_amt, @wk_litigation_amt1
	END
END

--新增公文日
IF	UPDATE(kc_doc_date) AND	@wk_doc_date IS NOT NULL
BEGIN
	EXECUTE kcsd.p_kc_mailsend_sub @wk_case_no, @wk_law_code, @wk_law_fmt, NULL, NULL, @wk_doc_date, @wk_doc_no, @wk_court_code,@wk_law_amt,NULL,@wk_updt_user, NULL, NULL, NULL, NULL, NULL
END


--點選完成 U 帶入車況
IF @wk_send_flag = -1 and @wk_law_code = 'U' and @wk_doc_date IS NOT NULL
BEGIN
	SELECT @wk_rema_amt = isnull(kc_rema_amt,0) FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	SELECT	@wk_area_code = kc_area_code FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	SELECT @wk_item_no2 = isnull(max(kc_item_no),0)+1 from kcsd.kc_carstatus where kc_case_no = @wk_case_no

	IF @wk_rema_amt >0 AND (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_law_date AND kc_car_stat = 'F') = 0
	BEGIN
		INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat, kc_updt_user, kc_updt_date, kc_area_code, kc_item_no)VALUES( @wk_case_no, @wk_doc_date,'F', @wk_updt_user, getdate(), @wk_area_code, @wk_item_no2)
	END
	ELSE IF @wk_rema_amt = 0  AND (SELECT COUNT(*) from kcsd.kc_carstatus WHERE kc_case_no = @wk_case_no and kc_car_date = @wk_law_date AND kc_car_stat = 'E') = 0
	BEGIN
		INSERT INTO kcsd.kc_carstatus ( kc_case_no, kc_car_date, kc_car_stat, kc_updt_user, kc_updt_date, kc_area_code, kc_item_no)VALUES( @wk_case_no, @wk_doc_date,'E', @wk_updt_user, getdate(), @wk_area_code, @wk_item_no2)
	END
END

GO
-- ==========================================================================================
-- 2016-08-04 更新kc_customerloan催告狀態至改至觸發程序
-- ==========================================================================================

CREATE  TRIGGER [kcsd].[t_kc_lawstatus_d] ON kcsd.kc_lawstatus 
FOR DELETE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_law_code	char(1)

SELECT	@wk_case_no = NULL, @wk_law_code = NULL

SELECT	@wk_case_no = kc_case_no
FROM	deleted

SELECT  TOP 1 @wk_law_code = kc_law_code from kcsd.kc_lawstatus where kc_case_no = @wk_case_no order by kc_law_date DESC,kc_item_no DESC,kc_updt_date DESC
UPDATE kcsd.kc_customerloan SET kc_push_stat = @wk_law_code WHERE kc_case_no = @wk_case_no

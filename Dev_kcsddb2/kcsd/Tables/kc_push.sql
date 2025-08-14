CREATE TABLE [kcsd].[kc_push] (
    [kc_case_no]        VARCHAR (10)  NOT NULL,
    [kc_item_no]        SMALLINT      NULL,
    [kc_area_code]      VARCHAR (2)   NULL,
    [kc_push_date]      SMALLDATETIME NOT NULL,
    [kc_push_note]      VARCHAR (300) NOT NULL,
    [kc_updt_user]      VARCHAR (10)  NULL,
    [kc_updt_date]      SMALLDATETIME NULL,
    [kc_sms_no]         INT           NULL,
    [kc_notice_no]      INT           NULL,
    [kc_push_link]      NVARCHAR (10) NULL,
    [kc_notice_link]    NVARCHAR (10) NULL,
    [kc_appt_date]      SMALLDATETIME NULL,
    [kc_effe_flag]      BIT           NULL,
    [kc_sms_flag]       VARCHAR (1)   NULL,
    [CreatePerson]      VARCHAR (20)  NULL,
    [CreateDate]        DATETIME      NULL,
    [kc_pushdata_stasA] VARCHAR (4)   NULL,
    [kc_pushdata_stasB] VARCHAR (4)   NULL,
    [kc_pushdata_stasC] VARCHAR (4)   NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_push]
    ON [kcsd].[kc_push]([kc_case_no] ASC, [kc_push_date] ASC, [kc_item_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_push_2]
    ON [kcsd].[kc_push]([kc_case_no] ASC, [kc_area_code] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_push_3]
    ON [kcsd].[kc_push]([kc_case_no] ASC, [kc_push_date] ASC, [kc_push_note] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_push_4]
    ON [kcsd].[kc_push]([kc_push_date] ASC);


GO
-- =============================================
-- 06/10/06 KC: Add Escape Char \ to solve '[系統]%'
-- =============================================
CREATE           TRIGGER [kcsd].[t_kc_push_iu] ON kcsd.kc_push 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_push_date	datetime,
	@wk_push_note	varchar(150),
	@wk_effe_flag	bit,
	@wk_appt_date	datetime,
	@wk_right_flag	bit,
	@wk_item_no	int,
	@wk_area_code	varchar(4)

SELECT	@wk_case_no = kc_case_no, @wk_push_date = kc_push_date, @wk_push_note = kc_push_note,
	@wk_effe_flag = kc_effe_flag, @wk_appt_date = kc_appt_date, @wk_item_no = kc_item_no
FROM	inserted

if USER = 'dbo' return

IF	NOT (DATEDIFF(day,@wk_push_date, GETDATE()) BETWEEN -15 AND 15)
-- AND	@wk_push_note NOT LIKE '約收%'
-- AND	@wk_push_note NOT LIKE '改約日期%'
-- AND	@wk_push_note NOT LIKE '尋人%'
AND	@wk_push_note NOT LIKE '\[系統]%' ESCAPE '\'
AND	USER <> 'dbo'
BEGIN
	RAISERROR ('--[KC]催繳記錄只能新增15天以內的資料!!!',18,2)
	ROLLBACK TRANSACTION
	RETURN	
END

--IF	@wk_item_no IS NULL
--BEGIN
--	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
--	FROM	kcsd.kc_push
--	WHERE	kc_case_no = @wk_case_no
--	AND	kc_push_date = @wk_push_date

--	/* 避免衝突: 若在HQ輸入非HQ催繳記錄則 no+10 */
--	IF	(@@servername = 'DYS01' or @@servername = 'DYAP01' or @@servername = 'DYS01D')
--	BEGIN
--		SELECT	@wk_area_code = kc_area_code
--		FROM	kcsd.kc_customerloan
--		WHERE	kc_case_no = @wk_case_no

--		IF	@wk_area_code <> '01'
--			SELECT	@wk_item_no = @wk_item_no + 10
--	END

--	UPDATE	kcsd.kc_push
--	SET	kc_item_no = @wk_item_no
--	WHERE	kc_case_no = @wk_case_no
--	AND	kc_push_date = @wk_push_date
--	AND	kc_item_no IS NULL
--END

IF	@wk_appt_date IS NULL
	SELECT	@wk_right_flag = 0
ELSE
BEGIN
	SELECT	@wk_right_flag = 1

	/* ¿·?°Â╩┤┌┬ÓñJ¼¨ª¼
	IF	UPDATE(kc_appt_date)
		INSERT	kcsd.kc_apptschedule
			(kc_case_no, kc_appt_date, kc_book_flag)
		VALUES	(@wk_case_no, @wk_appt_date, 0)
	*/
END

IF	@wk_effe_flag <> @wk_right_flag
BEGIN
	UPDATE	kcsd.kc_push
	SET	kc_effe_flag = @wk_right_flag
	WHERE	kc_case_no = @wk_case_no
	AND	kc_push_date = @wk_push_date
	AND	kc_item_no = @wk_item_no
END

/* ¼¨®wñÚ┤┴┬ÓñJªμ¿ã￥õ */
/*
IF	UPDATE(kc_appt_date)
AND	@wk_right_flag <> 0
BEGIN
	IF NOT EXISTS
	(SELECT	*
	FROM	kcsd.kc_calendar
	WHERE	kc_case_no = @wk_case_no
	AND	kc_cale_date = @wk_appt_date)
		INSERT	kcsd.kc_calendar
			(kc_case_no, kc_cale_date, kc_cale_note)
		VALUES	(@wk_case_no, @wk_appt_date, @wk_push_note)
END
*/
if USER NOT IN ('dbo','kcsd')
begin 
UPDATE	kcsd.kc_push
SET	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_case_no = @wk_case_no
AND	kc_push_date = @wk_push_date
AND	kc_item_no = @wk_item_no
end

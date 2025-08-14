CREATE TABLE [kcsd].[kc_apptschedule] (
    [kc_case_no]           VARCHAR (10)  NOT NULL,
    [kc_appt_date]         SMALLDATETIME NOT NULL,
    [kc_item_no]           SMALLINT      NOT NULL,
    [kc_sales_code]        VARCHAR (6)   NULL,
    [kc_appt_amt]          INT           NULL,
    [kc_book_flag]         BIT           NOT NULL,
    [kc_appt_stat]         VARCHAR (1)   NULL,
    [kc_next_date]         SMALLDATETIME NULL,
    [kc_updt_user]         VARCHAR (10)  NULL,
    [kc_updt_date]         SMALLDATETIME NULL,
    [kc_pay_type]          VARCHAR (1)   NULL,
    [kc_pusher_code]       VARCHAR (6)   NULL,
    [kc_addr_type]         VARCHAR (4)   NULL,
    [kc_appt_type]         VARCHAR (4)   NULL,
    [kc_rela_name]         VARCHAR (20)  NULL,
    [kc_visit_date]        SMALLDATETIME NULL,
    [kc_visit_outc]        VARCHAR (200) NULL,
    [kc_visit_memo]        VARCHAR (200) NULL,
    [kc_pay_amt]           INT           NULL,
    [kc_pay_breakamt]      INT           NULL,
    [kc_receipt_no]        VARCHAR (10)  NULL,
    [kc_break_amt]         INT           NULL,
    [kc_remark]            VARCHAR (200) NULL,
    [kc_area_code]         VARCHAR (2)   NULL,
    [kc_apptschedule_type] VARCHAR (2)   NULL,
    [CreatePerson]         VARCHAR (20)  NULL,
    [CreateDate]           DATETIME      NULL,
    CONSTRAINT [PK_kc_apptschedule_1__13] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_appt_date] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_apptschedule_1]
    ON [kcsd].[kc_apptschedule]([kc_case_no] ASC, [kc_item_no] ASC);


GO
-- =============================================
-- 06/05/06 KC: 約收類別轉入kc_push
-- 16/09/21 KC: 寫入updt_user改到前端
-- =============================================
CREATE       TRIGGER [kcsd].[t_kc_apptschedule_i] ON kcsd.kc_apptschedule 
FOR INSERT NOT FOR REPLICATION
AS
DECLARE	
	@wk_case_no		varchar(10),
	@wk_appt_date		datetime,
	@wk_appt_amt		int,
	@wk_break_amt		int,
	@wk_appt_type		varchar(4),
	@wk_appt_desc	varchar(20),
	@wk_addr_type		varchar(4),
	@wk_push_note	varchar(200),
	@wk_area_code	varchar(2),
	@wk_item_no		smallint,
	@wk_updt_user	varchar(10)

SELECT	@wk_case_no = NULL, @wk_appt_date = NULL, @wk_appt_amt = 0, @wk_break_amt = 0,
	@wk_appt_type = NULL, @wk_appt_desc = NULL, @wk_addr_type = NULL,
	@wk_push_note = NULL,@wk_updt_user = NULL

SELECT	@wk_case_no = kc_case_no, @wk_appt_date = kc_appt_date, @wk_appt_amt = kc_appt_amt, @wk_break_amt = kc_break_amt,
	@wk_appt_type = kc_appt_type, @wk_addr_type = kc_addr_type, @wk_updt_user = kc_updt_user
FROM	inserted

IF	@wk_appt_type IS NOT NULL
	SELECT	@wk_appt_desc = kc_appt_desc
	FROM	kcsd.kct_appttype
	WHERE	kc_appt_type = @wk_appt_type

SELECT	@wk_push_note = '[系統] ' + CONVERT(varchar(8), @wk_appt_date, 1) + ' ' + @wk_appt_desc + ' 地址' + @wk_addr_type
			+ ' 金額' + CONVERT(varchar(10),@wk_appt_amt) +'元 違約金' + CONVERT(varchar(10),@wk_break_amt) + '元'

SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where kc_case_no =@wk_case_no
SELECT @wk_item_no = isnull(max(kc_item_no),0)+1 from kcsd.kc_push where kc_case_no = @wk_case_no

INSERT	kcsd.kc_push
		(kc_case_no, kc_area_code,kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date)
VALUES	(@wk_case_no, @wk_area_code,@wk_appt_date, @wk_push_note, 1,@wk_item_no,@wk_updt_user,GETDATE())


--UPDATE	kcsd.kc_apptschedule
--SET	kc_updt_user = USER, kc_updt_date = GETDATE()
--WHERE	kc_case_no = @wk_case_no
--AND	kc_appt_date = @wk_appt_date

GO
-- =============================================
--20121017 更新不紀錄修改人與日期
-- 06/05/06 KC: 增加查訪後轉入kc_push
-- =============================================
CREATE         TRIGGER [kcsd].[t_kc_apptschedule_u] ON [kcsd].[kc_apptschedule] 
FOR UPDATE NOT FOR REPLICATION
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_appt_date	datetime,
	@wk_next_date	datetime,
	@wk_appt_stat	char(1),
	@wk_push_date	datetime,
	@wk_appt_desc	varchar(20),
	@wk_appt_amt	int,
	@wk_book_flag	bit,
	@wk_sales_code	varchar(6),
	@wk_visit_date	datetime,
	@wk_visit_outc	varchar(100),
	@wk_pay_amt			int,
	@wk_pay_breakamt	int,
	@wk_sentence	varchar(200),
	@wk_area_code	varchar(2),
	@wk_item_no		smallint,
	@wk_updt_user	varchar(10),
	@wk_visit_memo	varchar(100)

SELECT	@wk_appt_date = NULL, @wk_next_date = NULL, @wk_appt_stat = NULL,
	@wk_push_date = NULL, 
	@wk_appt_amt = 0, @wk_book_flag = 0, @wk_sales_code = NULL,
	@wk_visit_date = NULL, @wk_visit_outc = NULL, @wk_pay_amt = 0, @wk_sentence = NULL, 
	@wk_updt_user = NULL, @wk_pay_breakamt = 0,@wk_visit_memo = null

SELECT	@wk_case_no = kc_case_no, @wk_appt_date = kc_appt_date, @wk_next_date = kc_next_date,
	@wk_appt_stat = kc_appt_stat, @wk_sales_code=kc_sales_code, @wk_book_flag = kc_book_flag,
	@wk_appt_amt = kc_appt_amt,
	@wk_visit_date = kc_visit_date, @wk_visit_outc = kc_visit_outc, @wk_pay_amt = kc_pay_amt,
	@wk_updt_user = kc_updt_user, @wk_pay_breakamt = kc_pay_breakamt,@wk_visit_memo = kc_visit_memo
FROM	inserted

IF	@wk_appt_stat = 'R'
AND	@wk_next_date IS NULL
BEGIN
	RAISERROR ('--[KC] 改約必須有改約日期 !!!',18,2)
	ROLLBACK TRANSACTION
	RETURN
END

IF	UPDATE (kc_visit_date)
AND	@wk_visit_date IS NOT NULL
BEGIN
	SELECT @wk_appt_desc = CASE WHEN @wk_appt_stat = '1' THEN '有' WHEN @wk_appt_stat = '0' THEN '無' WHEN @wk_appt_stat = 'X' THEN '取消' ELSE '' END
	SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where kc_case_no =@wk_case_no
	SELECT @wk_item_no = isnull(max(kc_item_no),0)+1 from kcsd.kc_push where kc_case_no = @wk_case_no
	SELECT @wk_sentence = '[系統] ' + CONVERT(varchar(8), @wk_visit_date, 1) + ' ' + ISNULL(@wk_appt_desc,'*') + ' '
			+ ISNULL(@wk_visit_outc, '*') + ' 金額' + CONVERT(varchar(10),ISNULL(@wk_pay_amt,0)) + '元 違約金' + CONVERT(varchar(10),ISNULL(@wk_pay_breakamt,0)) + '元 查訪備註:' + ISNULL(@wk_visit_memo,'無')

	INSERT	kcsd.kc_push
		(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag, kc_item_no, kc_updt_user, kc_updt_date)
	VALUES	(@wk_case_no, @wk_area_code, @wk_visit_date, @wk_sentence, 1, @wk_item_no, @wk_updt_user, GETDATE())
END

CREATE TABLE [kcsd].[kc_loanpayment] (
    [kc_case_no]         VARCHAR (10)  NOT NULL,
    [kc_perd_no]         SMALLINT      NOT NULL,
    [kc_expt_date]       DATETIME      NOT NULL,
    [kc_expt_fee]        INT           NOT NULL,
    [kc_pay_date]        DATETIME      NULL,
    [kc_pay_fee]         INT           CONSTRAINT [DF_kc_loanpay_kc_pay_fee_5__10] DEFAULT ((0)) NULL,
    [kc_rema_fee]        INT           NULL,
    [kc_pay_type]        VARCHAR (1)   NULL,
    [kc_trans_no]        VARCHAR (10)  NULL,
    [kc_break_fee]       INT           CONSTRAINT [DF_kc_loanpay_kc_break_fe2__10] DEFAULT ((0)) NULL,
    [kc_intr_fee]        INT           CONSTRAINT [DF_kc_loanpay_kc_intr_fee3__10] DEFAULT ((0)) NULL,
    [kc_rece_code]       VARCHAR (6)   NULL,
    [kc_oper_code]       VARCHAR (6)   NULL,
    [kc_memo]            VARCHAR (50)  NULL,
    [kc_updt_user]       VARCHAR (10)  NULL,
    [kc_updt_date]       SMALLDATETIME NULL,
    [kc_proc_fee]        INT           CONSTRAINT [DF_kc_loanpay_kc_proc_fee1__20] DEFAULT ((0)) NULL,
    [kc_area_code]       VARCHAR (2)   NULL,
    [kc_pv_amt]          INT           NULL,
    [kc_invo_amt]        INT           NULL,
    [kc_pvpay_amt]       INT           NULL,
    [kc_invo_rema]       INT           NULL,
    [kc_pv_amt2]         INT           NULL,
    [kc_invo_amt2]       INT           NULL,
    [kc_pvpay_amt2]      INT           NULL,
    [kc_invo_rema2]      INT           NULL,
    [kc_proc_amt2]       INT           NULL,
    [kc_proc_rema2]      INT           NULL,
    [kc_oinvo_amt]       INT           NULL,
    [kc_invo_date]       SMALLDATETIME NULL,
    [kc_invo_flag]       VARCHAR (1)   NULL,
    [kc_dudupoint_fee]   INT           NULL,
    [kc_interest_fee]    INT           NULL,
    [kc_latepayment_fee] INT           NULL,
    [kc_ATM_codeB]       VARCHAR (20)  NULL,
    CONSTRAINT [PK_kc_loanpayment_1__10] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_perd_no] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_1]
    ON [kcsd].[kc_loanpayment]([kc_case_no] ASC, [kc_expt_date] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_2]
    ON [kcsd].[kc_loanpayment]([kc_expt_date] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_3]
    ON [kcsd].[kc_loanpayment]([kc_pay_date] ASC, [kc_pay_type] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_4]
    ON [kcsd].[kc_loanpayment]([kc_area_code] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_5]
    ON [kcsd].[kc_loanpayment]([kc_case_no] ASC, [kc_pay_date] ASC, [kc_expt_date] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_6]
    ON [kcsd].[kc_loanpayment]([kc_pay_date] ASC, [kc_pay_fee] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_loanpayment_7]
    ON [kcsd].[kc_loanpayment]([kc_updt_date] ASC, [kc_case_no] ASC);


GO

-- ==========================================================================================
-- 2018-06-07 實繳與違約都為0不檢查也不延申
-- 2017-06-28 去除 業務收款已改
-- 2017-06-20 新系統轉檔入帳
-- 2012/07/23 帳管關帳日統一改為7號
-- 2012/07/23 修正日期BUG
-- 02/17/2011 KC: fix 發票關帳無法修改
-- 10/08/10 KC: 增加發票關帳日, 之前會計關帳會影響發票計算
-- 07/07/07 KC: 關帳日由10日改為7日
-- 09/05/06 KC:	use ismember_sub to check group
-- ==========================================================================================
CREATE                  TRIGGER [kcsd].[t_kc_loanpayment_u] ON [kcsd].[kc_loanpayment] 
FOR UPDATE NOT FOR REPLICATION
AS

/* 07/07/2001 KC: 新增有未清之零頭分期(>50期者), 必須先結清零清期 */
DECLARE	@wk_case_no varchar(10),
	@wk_perd_no int,
	@wk_expt_date datetime,
	@wk_expt_fee int,
	@wk_pay_date datetime,
	@wk_pay_fee int,
	@wk_pay_odate datetime,
	@wk_lock_date	datetime,
	@wk_lock_date2	datetime,	-- 發票關帳日
	@wk_lock_date2v	varchar(10),	-- 發票關帳日(文字)
	@wk_min_date	datetime,		-- 最小繳款日: 當月1日或上月1日
	@wk_perd_strt	datetime,		--當月1日
	@wk_rema_perd int,
	@wk_group_name char(10),
	@wk_break_fee	int,
	@wk_intr_fee	int,

	@wk_appt_date	datetime,		/* 約收日 */
	@wk_appt_amt	int,
	@wk_appt_stat	varchar(1),
	@wk_astrt_date	datetime,		/* 約收開始日 (T-5) */
	@wk_astop_date	datetime,		/* 約收結束日 (T+5) */

	@wk_area_code	varchar(2),		/* for replication */
	@wk_pv_amt	int,			/* for PV */
	@wk_invo_amt	int,
	@wk_pvpay_amt	int,

	@wk_invo_rema	int,			/* invo overflow use */
	@wk_proc_amt	int,			/* invo overflow use */
	@wk_proc_rema	int,			/* invo overflow use */
	@wk_oinvo_amt	int,			/* invo overflow use */
	@wk_adms_flag	varchar(1),		/* group use */

	@wk_item_no	int		

SELECT	@wk_pay_date = NULL, @wk_pay_odate = NULL, @wk_lock_date=NULL,
	@wk_expt_date = NULL,
	@wk_expt_fee = 0, @wk_pay_fee = 0,
	@wk_rema_perd = 0,
	@wk_group_name = NULL,
	@wk_break_fee = 0, @wk_intr_fee = 0,
	@wk_appt_date = NULL, @wk_appt_amt = 0, @wk_astrt_date = NULL, @wk_astop_date = NULL,
	@wk_area_code = NULL,
	@wk_pv_amt = 0, @wk_invo_amt = 0, @wk_pvpay_amt = 0, @wk_adms_flag = 'N',@wk_item_no = -1
	
SELECT	@wk_case_no = kc_case_no,
	@wk_perd_no = kc_perd_no,
	@wk_expt_date = kc_expt_date,
	@wk_expt_fee = kc_expt_fee,
	@wk_pay_date = kc_pay_date,
	@wk_pay_fee = kc_pay_fee,
	@wk_break_fee = kc_break_fee,
	@wk_intr_fee = kc_intr_fee,
	@wk_area_code = kc_area_code
FROM	inserted

/* Don't care kcsd modify */

IF	USER = 'dbo'
	RETURN

EXECUTE	kcsd.p_kc_getgroup @wk_group_name OUTPUT
EXECUTE kcsd.p_kc_getuserinfo_ismember_sub 'ADMS', NULL, @wk_adms_flag OUTPUT

IF	@wk_adms_flag = 'Y'
	SELECT	@wk_group_name = 'ADMS'

-- 02/17/2011 KC: fix 發票關帳無法修改
--IF	UPDATE(kc_pay_date)
--	SELECT	@wk_pay_odate = kc_pay_date
--	FROM	deleted
--ELSE
--	SELECT	@wk_pay_odate = kc_pay_date
--	FROM	kcsd.kc_loanpayment
--	WHERE	kc_case_no = @wk_case_no
--	AND	kc_perd_no = @wk_perd_no

---- 關帳: 超過修改期限, 且非ADMS者 --> 禁止修改
--SELECT @wk_perd_strt = DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)
--SELECT @wk_lock_date = DATEADD(mm,1,DATEADD(mm,DATEDIFF(mm,0,@wk_pay_odate),6))

--/* 本月第一天獲上月第一天*/
--IF	DATEPART(day, GETDATE()) > 10
--	SELECT	@wk_min_date = @wk_perd_strt
--ELSE
--	SELECT	@wk_min_date = DATEADD(month, -1, @wk_perd_strt)

--IF	UPDATE(kc_case_no)
---- AND	USER <> 'yelin'		-- 人工修改
--BEGIN
--	RAISERROR ('---- [KC] CaseNo 不准修改 !!!',18,2) WITH SETERROR
--	ROLLBACK TRANSACTION
--	RETURN
--END

--IF	( UPDATE(kc_expt_date) OR UPDATE(kc_perd_no) )
--	AND (@wk_group_name<>'ADMS')
--BEGIN
--	RAISERROR ('--[KC] 期數 & 應繳日期禁止修改!!!!',18,2)
--	ROLLBACK TRANSACTION
--	RETURN
--END

/* temply don't log kcsd */
--IF	USER = 'kcsd'
--	RETURN

/*IF	@wk_group_name <> 'ADMS'*/
IF	UPDATE(kc_pay_date)
AND	NOT (DATEDIFF(day,@wk_pay_date, GETDATE()) BETWEEN 0 AND 30)
AND	@wk_case_no NOT IN
		(SELECT	kc_case_no
		FROM	kcsd.kc_customeredit
		WHERE	kc_case_no = @wk_case_no
		AND	DATEDIFF (day, kc_edit_date, GETDATE())=0
		)
BEGIN
	RAISERROR ('--[KC] 繳款日期有問題!!!,只能新增30天內的單據',18,2)
	ROLLBACK TRANSACTION
	RETURN	
END



-- 關帳
-- 1. 發票關帳 較鬆, 所以放前面, (必須ADMIN, ADMIN由一般關帳處理)
-- 2. 發票關帳為 奇數月15
IF	@wk_group_name = 'ADMS'
AND	@wk_pay_odate IS NOT NULL
AND	(	UPDATE(kc_pv_amt2)
	OR	UPDATE(kc_invo_amt2)
	OR	UPDATE(kc_pvpay_amt2)
	OR	UPDATE(kc_invo_rema2)
	OR	UPDATE(kc_proc_amt2)
	OR	UPDATE(kc_proc_rema2)
	OR	UPDATE(kc_oinvo_amt)
	OR	UPDATE(kc_proc_amt2)
	)
BEGIN
	-- 計算發票關帳日
	IF	DATEPART(month, @wk_pay_odate) % 2 = 1
	BEGIN
                           SELECT @wk_lock_date2 = DATEADD(mm,2,DATEADD(mm,DATEDIFF(mm,0,@wk_pay_odate),19))
	END
	ELSE
	BEGIN
                           SELECT @wk_lock_date2 = DATEADD(mm,1,DATEADD(mm,DATEDIFF(mm,0,@wk_pay_odate),19))
	END

	-- 02/17/2011 KC: 臨時多1個月發票改帳用
	SELECT	@wk_lock_date2 = DATEADD(month, 1, @wk_lock_date2)

	IF	GETDATE() > @wk_lock_date2
	BEGIN
		SET @wk_lock_date2v = CONVERT(varchar(10), @wk_lock_date2, 23)
		--RAISERROR ('--[KC] 發票已於 %s 關帳禁止修改 !!!',18,2,@wk_lock_date2v)
		--ROLLBACK TRANSACTION
		--RETURN
	END
END
ELSE IF	((	@wk_pay_odate IS NOT NULL
		AND	GETDATE() > @wk_lock_date )
	OR	@wk_pay_date < @wk_min_date
	)
AND	(@wk_group_name <> 'ADMS' OR
	@wk_case_no NOT IN
		(SELECT	kc_case_no
		FROM	kcsd.kc_customeredit
		WHERE	kc_case_no = @wk_case_no
		AND	DATEDIFF (day, kc_edit_date, GETDATE())=0
		)
	)
BEGIN
	/*
	IF	(  UPDATE(kc_pay_date)
		OR UPDATE(kc_expt_fee)
		OR UPDATE(kc_break_fee)
		OR UPDATE(kc_intr_fee) ) */
	/* BEGIN */
		RAISERROR ('--[KC] 已關帳, 禁止修改 !!!',18,2)		
		ROLLBACK TRANSACTION
		RETURN
	/* END */
END

/* 檢查是否有零款 */
IF	EXISTS(	SELECT	'X'
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	((kc_pay_fee = 0 OR kc_pay_fee IS NULL) AND (kc_break_fee = 0 OR kc_break_fee IS NULL))
	AND	kc_perd_no >= 50
	AND	@wk_perd_no < 50
	--AND	USER <> 'kcsd'
	)
AND	UPDATE(kc_pay_fee)
BEGIN

select @wk_item_no = kc_item_no FROM kcsd.kc_loanperd50whitelist where kc_case_no = @wk_case_no and kc_list_flag = 'Y' and kc_apply_user is not null

if(@wk_item_no > 0)
BEGIN
update  kcsd.kc_loanperd50whitelist set kc_list_flag = 'N' where kc_case_no = @wk_case_no  and kc_item_no = @wk_item_no
END
ELSE
BEGIN
	RAISERROR ('--[KC] 還有[正常期數]沒繳清的零款, 請先繳清零款 !!!',18,2)
	ROLLBACK TRANSACTION
	RETURN	
END

END

IF	@wk_pay_fee > @wk_expt_fee
--AND	USER <> 'kcsd'
BEGIN
	RAISERROR ('--[KC] 實繳金額不得大於應繳金額...!!!',18,2)
	ROLLBACK TRANSACTION
	RETURN	
END
ELSE IF	@wk_pay_fee < @wk_expt_fee
AND	UPDATE(kc_pay_fee)
AND	NOT ((@wk_pay_fee = 0 AND @wk_break_fee = 0) OR @wk_pay_fee IS NULL)
BEGIN
	IF	EXISTS(	SELECT	'X'
			FROM	kcsd.kc_loanpayment
			WHERE	kc_case_no = @wk_case_no
			AND	kc_perd_no <> @wk_perd_no
			/* AND	kc_pay_fee IS NOT NULL */
			AND	((kc_pay_fee = 0 OR kc_pay_fee IS NULL) AND (kc_break_fee = 0 OR kc_break_fee IS NULL))
			AND	kc_perd_no >= 50
		)
	BEGIN
		RAISERROR ('--[KC] 還有[延伸欄位]沒繳清的零款, 請先繳清零款 !!!',18,2)
		ROLLBACK TRANSACTION
		RETURN	
	END

	SELECT	@wk_rema_perd = MAX(kc_perd_no) + 1
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	IF	@wk_rema_perd < 50
		SELECT	@wk_rema_perd = 50

	INSERT	kcsd.kc_loanpayment
		(kc_case_no, kc_perd_no, kc_expt_date, kc_expt_fee,
		kc_area_code)
	VALUES
		(@wk_case_no,@wk_rema_perd, @wk_expt_date, @wk_expt_fee-@wk_pay_fee,
		@wk_area_code)
END

/* 發票計算改為每月執行 */
/*
IF	UPDATE (kc_pay_fee)
BEGIN
	EXECUTE	kcsd.p_kc_pvperiod @wk_case_no, @wk_perd_no,
		@wk_pv_amt OUTPUT, @wk_invo_amt OUTPUT, @wk_pvpay_amt OUTPUT, @wk_invo_rema OUTPUT,
		@wk_proc_amt OUTPUT, @wk_proc_rema OUTPUT, @wk_oinvo_amt OUTPUT

	UPDATE	kcsd.kc_loanpayment
	SET	kc_pv_amt2 = @wk_pv_amt, kc_invo_amt2 = @wk_invo_amt,
		kc_pvpay_amt2 = @wk_pvpay_amt, kc_invo_rema2 = @wk_invo_rema,
		kc_proc_amt2 = @wk_proc_amt, kc_proc_rema2 = @wk_proc_rema,
		kc_oinvo_amt = @wk_oinvo_amt,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no
END
ELSE
*/

/* 更新約定收款 */
SELECT	@wk_astrt_date = DATEADD(day, -5, @wk_pay_date),
	@wk_astop_date = DATEADD(day,  5, @wk_pay_date)

SELECT	@wk_appt_amt = ISNULL(kc_appt_amt, 0), @wk_appt_date = kc_appt_date
FROM	kcsd.kc_apptschedule
WHERE	kc_case_no = @wk_case_no
AND	kc_appt_date BETWEEN @wk_astrt_date AND @wk_astop_date
AND	kc_appt_stat IS NULL

/* 是否符合條件 */
/* KC: 02/17/2002 暫時關閉入帳自動更改狀態 */

/* 2017-06-28 去除 業務收款已改 */
--IF	@wk_appt_amt > 0
--AND	@wk_pay_fee > 0
--BEGIN
--	/* 預設為部分收回 */
--	SELECT	@wk_appt_stat = 'D'

--	/* 繳款足夠, 則約收收回*/
--	IF	( @wk_pay_fee + @wk_break_fee - @wk_intr_fee ) >= @wk_appt_amt
--		SELECT	@wk_appt_stat = 'C'
	
--	UPDATE	kcsd.kc_apptschedule
--	SET	kc_appt_stat = @wk_appt_stat
--	WHERE	kc_case_no = @wk_case_no
--	AND	kc_appt_date = @wk_appt_date
--END

--計算狀態
exec kcsd.p_kc_updateloanstatus @wk_case_no

IF USER <> 'kcsd'
BEGIN
	UPDATE	kcsd.kc_loanpayment
	SET	kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no
END

GO
-- ==========================================================================================
-- 2012/07/23 帳管關帳日統一改為7號
-- 2012/07/23 修正日期BUG
-- ==========================================================================================

CREATE  TRIGGER [kcsd].[t_kc_loanpayment_d] ON [kcsd].[kc_loanpayment] 
FOR DELETE NOT FOR REPLICATION
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_pay_odate	datetime,
	@wk_lock_date	datetime		/* 關帳日 */

IF	USER = 'dbo'  RETURN

SELECT	@wk_case_no = NULL, @wk_pay_odate = NULL, @wk_lock_date = NULL

SELECT	@wk_case_no = kc_case_no, @wk_pay_odate = kc_pay_date
FROM	deleted

SELECT	@wk_lock_date = dateadd(mm,1,DATEADD(mm,DATEDIFF(mm,0,@wk_pay_odate),6))
/* 關帳 */
IF	@wk_pay_odate IS NOT NULL
AND	GETDATE() > @wk_lock_date
AND	@wk_case_no NOT IN
		(SELECT	kc_case_no
		FROM	kcsd.kc_customeredit
		WHERE	kc_case_no = @wk_case_no
		AND	DATEDIFF (day, kc_edit_date, GETDATE())=0
		)
BEGIN
	RAISERROR ('--[KC] 已關帳, 禁止刪除 !!!',18,2)		
	ROLLBACK TRANSACTION
	RETURN
END











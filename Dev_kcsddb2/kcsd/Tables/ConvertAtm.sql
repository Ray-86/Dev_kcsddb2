CREATE TABLE [kcsd].[ConvertAtm] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [ConvertDate]      VARCHAR (30)  NOT NULL,
    [ConvertData]      VARCHAR (30)  NOT NULL,
    [ConvertExp]       VARCHAR (30)  NOT NULL,
    [ConvertAmt]       INT           NOT NULL,
    [kc_case_no]       VARCHAR (10)  NULL,
    [kc_pay_date]      SMALLDATETIME NULL,
    [kc_pay_fee]       INT           NULL,
    [kc_break_fee]     INT           NULL,
    [kc_memo]          VARCHAR (50)  NULL,
    [kc_updt_user]     VARCHAR (20)  NULL,
    [kc_updt_date]     SMALLDATETIME NULL,
    [kc_recorded_user] VARCHAR (20)  NULL,
    [kc_recorded_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_ConvertAtm] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [i_ConvertAtm_1]
    ON [kcsd].[ConvertAtm]([kc_recorded_user] ASC);


GO

-- =============================================
-- 2017-08-14 已經入帳不可更改調帳
-- =============================================
CREATE	TRIGGER [kcsd].[t_ConvertAtm_u] ON [kcsd].[ConvertAtm] 
FOR UPDATE NOT FOR REPLICATION
AS 
DECLARE
	@id int,
	@convertDate	varchar(30),
	@convertData	varchar(30),
	@convertExp		varchar(30),
	@convertAmt		int,
	@wk_case_no		varchar(10),
	@wk_pay_date	smalldatetime,
	@wk_pay_fee		int,
	@wk_break_fee	int,
	@wk_memo		varchar(50),
	@wk_recorded_user	varchar(20),
	@wk_recorded_date	smalldatetime

SELECT	@id = ID,
	@convertDate = ConvertDate,
	@convertData = ConvertData,
	@convertExp = ConvertExp,
	@convertAmt = ConvertAmt,
	@wk_recorded_date = kc_recorded_date,
	@wk_recorded_user = kc_recorded_user
FROM	inserted

IF USER = 'dbo' RETURN

IF	(UPDATE(kc_pay_fee) OR UPDATE(kc_break_fee) OR UPDATE(kc_case_no) OR UPDATE(kc_pay_date))
AND	(@wk_recorded_date IS NOT NULL OR @wk_recorded_user IS NOT NULL)
BEGIN
	RAISERROR ('[KC] 已經入帳禁止修改調整帳款 !!!',18,2)
	ROLLBACK TRANSACTION
	RETURN
END

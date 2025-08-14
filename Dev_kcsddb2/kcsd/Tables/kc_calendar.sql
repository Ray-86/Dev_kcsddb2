CREATE TABLE [kcsd].[kc_calendar] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_cale_date] SMALLDATETIME NOT NULL,
    [kc_fini_flag] BIT           CONSTRAINT [DF_kc_calenda_kc_fini_fla1__14] DEFAULT ((0)) NOT NULL,
    [kc_cale_note] VARCHAR (150) NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_calendar_2__14] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_cale_date] ASC)
);


GO


CREATE  TRIGGER [kcsd].[t_kc_calendar_u] ON [kcsd].[kc_calendar]
FOR UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_cale_date	datetime,
	@wk_updt_user	char(10)

SELECT	@wk_case_no = kc_case_no, @wk_cale_date = kc_cale_date,
	@wk_updt_user = kc_updt_user
FROM	inserted

/*
IF	(@wk_updt_user <> 'kcsd') AND (USER <> 'kcsd')
	AND (USER <> @wk_updt_user)
BEGIN
	RAISERROR ('--[KC] Ñu»Ó¡Îº´ª█ñv¬║ªµ¿ã¥õ!!!',18,2) WITH SETERROR
	ROLLBACK TRANSACTION
	RETURN
END
*/

UPDATE	kcsd.kc_calendar
SET	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_case_no = @wk_case_no
AND	kc_cale_date = @wk_cale_date



GO


CREATE  TRIGGER [kcsd].[t_kc_calendar_i] ON [kcsd].[kc_calendar]
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_cale_date	datetime

SELECT	@wk_case_no = kc_case_no, @wk_cale_date = kc_cale_date
FROM	inserted

UPDATE	kcsd.kc_calendar
SET	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_case_no = @wk_case_no
AND	kc_cale_date = @wk_cale_date






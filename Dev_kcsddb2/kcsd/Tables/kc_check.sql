CREATE TABLE [kcsd].[kc_check] (
    [kc_acc_code]   VARCHAR (2)   NOT NULL,
    [kc_chk_no]     VARCHAR (7)   NOT NULL,
    [kc_write_date] SMALLDATETIME NOT NULL,
    [kc_pay_date]   SMALLDATETIME NOT NULL,
    [kc_pay_amt]    INT           NOT NULL,
    [kc_rece_name]  VARCHAR (30)  NOT NULL,
    [kc_chk_type]   VARCHAR (2)   NOT NULL,
    [kc_chk_memo]   VARCHAR (50)  NULL,
    [kc_chk_stat]   VARCHAR (1)   NOT NULL,
    [kc_wdrw_date]  SMALLDATETIME NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_acc_ymd]    VARCHAR (8)   NULL,
    [kc_case_no]    VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_check_1__19] PRIMARY KEY CLUSTERED ([kc_acc_code] ASC, [kc_chk_no] ASC)
);


GO



CREATE   TRIGGER [kcsd].[t_kc_check_iu] ON [kcsd].[kc_check] 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_acc_code	char(2),
	@wk_write_date	datetime,
	@wk_chk_no	char(7),
	@wk_acc_ymd	char(8)

SELECT	@wk_acc_code = kc_acc_code, @wk_write_date = kc_write_date,
	@wk_chk_no = kc_chk_no
FROM	inserted

/* Don't trigger/log anything for kcsd */
IF	USER = 'kcsd'
	RETURN

SELECT	@wk_acc_ymd = CONVERT(char(6), @wk_write_date,12)
SELECT	@wk_acc_ymd = @wk_acc_code + @wk_acc_ymd

UPDATE	kcsd.kc_check
SET	kc_acc_ymd = @wk_acc_ymd,
	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_acc_code = @wk_acc_code
AND	kc_chk_no = @wk_chk_no




GO
DISABLE TRIGGER [kcsd].[t_kc_check_iu]
    ON [kcsd].[kc_check];


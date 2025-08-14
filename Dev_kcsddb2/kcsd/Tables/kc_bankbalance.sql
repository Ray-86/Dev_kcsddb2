CREATE TABLE [kcsd].[kc_bankbalance] (
    [kc_acc_code]  VARCHAR (2)   NOT NULL,
    [kc_bank_date] SMALLDATETIME NOT NULL,
    [kc_depo_amt]  INT           NOT NULL,
    [kc_wdrw_amt]  INT           NOT NULL,
    [kc_rema_amt]  INT           NOT NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL,
    CONSTRAINT [PK_kc_bankbalance_1__16] PRIMARY KEY CLUSTERED ([kc_acc_code] ASC, [kc_bank_date] ASC)
);


GO


CREATE  TRIGGER [kcsd].[t_kc_bankbalance_iu] ON [kcsd].[kc_bankbalance] 
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_acc_code	char(2),
	@wk_bank_date	smalldatetime

SELECT	@wk_acc_code = kc_acc_code, @wk_bank_date = kc_bank_date
FROM	inserted

UPDATE	kcsd.kc_bankbalance
SET	kc_updt_user = USER, kc_updt_date = GETDATE()
WHERE	kc_acc_code = @wk_acc_code
AND	kc_bank_date = @wk_bank_date



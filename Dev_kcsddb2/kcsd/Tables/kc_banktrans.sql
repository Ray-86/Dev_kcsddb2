CREATE TABLE [kcsd].[kc_banktrans] (
    [kc_acc_code]   VARCHAR (2)   NOT NULL,
    [kc_bank_date]  SMALLDATETIME NOT NULL,
    [kc_seq_no]     SMALLINT      NULL,
    [kc_bank_yymm]  VARCHAR (4)   NULL,
    [kc_depo_amt]   INT           NOT NULL,
    [kc_wdrw_amt]   INT           NOT NULL,
    [kc_trans_memo] VARCHAR (50)  NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [i_kc_banktrans]
    ON [kcsd].[kc_banktrans]([kc_acc_code] ASC, [kc_bank_date] ASC, [kc_seq_no] ASC);


GO




CREATE    TRIGGER [kcsd].[t_kc_banktrans_i]
ON [kcsd].[kc_banktrans] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_acc_code	char(2),
	@wk_bank_date	datetime,
	@wk_seq_no	int,
	@wk_bank_yymm	char(4)

SELECT	@wk_acc_code = NULL, @wk_bank_date = NULL,
	@wk_seq_no = NULL, @wk_bank_yymm = NULL

SELECT	@wk_acc_code = kc_acc_code, @wk_bank_date = kc_bank_date, @wk_seq_no = kc_seq_no
FROM	inserted


SELECT	@wk_bank_yymm = RIGHT(CONVERT(char(4),DATEPART(YEAR,@wk_bank_date)),2) +
		RIGHT('00'+LTRIM(RTRIM(CONVERT(char(2),DATEPART(MONTH,@wk_bank_date)))),2)

IF	@wk_seq_no IS NULL
BEGIN
	SELECT	@wk_seq_no = ISNULL(MAX(kc_seq_no),0)+1
	FROM	kcsd.kc_banktrans
	WHERE	kc_acc_code = @wk_acc_code
	AND	kc_bank_date = @wk_bank_date

	UPDATE	kcsd.kc_banktrans
	SET	kc_seq_no = @wk_seq_no, kc_bank_yymm = @wk_bank_yymm,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_acc_code = @wk_acc_code
	AND	kc_bank_date = @wk_bank_date
	AND	kc_seq_no IS NULL
END





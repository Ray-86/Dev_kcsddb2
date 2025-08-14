CREATE TABLE [kcsd].[kc_paymentcenter] (
    [kc_case_no]   VARCHAR (10)  NOT NULL,
    [kc_pay_date]  DATETIME      NOT NULL,
    [kc_item_no]   SMALLINT      NULL,
    [kc_pay_fee]   INT           NOT NULL,
    [kc_pay_type]  VARCHAR (1)   NOT NULL,
    [kc_trans_no]  VARCHAR (10)  NULL,
    [kc_rece_code] VARCHAR (6)   NULL,
    [kc_oper_code] VARCHAR (6)   NULL,
    [kc_memo]      VARCHAR (50)  NULL,
    [kc_fail_flag] VARCHAR (2)   NULL,
    [kc_updt_user] VARCHAR (10)  NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_paymentcenter]
    ON [kcsd].[kc_paymentcenter]([kc_case_no] ASC, [kc_pay_date] ASC, [kc_item_no] ASC);


GO
-- =============================================
-- 2014/01/14 東元車業件手續費維持15元
-- 2012/12/03 相同帳單編號多筆繳款記錄，只新增手續費至第一筆資料
-- 2012/11/06 板信手續費改14元
-- 2012/11/01 板信手續費改14元
-- 2012/09/01 聯邦手續費改14元,東元機車件維持15元
-- 2012/05/04 合庫手續費14元,其他15元
-- 2005/07/09 KC: proc fee change from 16 to 15 since 07/01/2005
-- 2004/10/26 KC: proc fee change from 18 to 16 since 09/30/2004
-- =============================================

CREATE          TRIGGER [kcsd].[t_kc_paymentcenter_i] ON [kcsd].[kc_paymentcenter] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_perd_no	int,
	@wk_pay_date	datetime,
	@wk_item_no	int,
	@wk_expt_fee	int,
	@wk_pay_fee	int,		/* real pay */
	@wk_pay_fee2	int,		/* tmp use */
	@wk_pay_rema	int,
	@wk_pay_type	varchar(1),
	@wk_trans_no	varchar(10),
	@wk_fail_flag	varchar(2),
	@wk_rece_code	varchar(6),
	@wk_oper_code	varchar(6),
	@wk_proc_fee	int,
	@wk_temp	int		

SELECT	@wk_case_no = NULL, @wk_perd_no = 0, @wk_pay_date = NULL,
	@wk_item_no = 0, @wk_expt_fee = 0, @wk_pay_fee = 0, @wk_pay_rema = 0,
	@wk_pay_fee2 = 0, @wk_pay_type = NULL, @wk_trans_no = NULL,
	@wk_fail_flag = NULL, @wk_rece_code = NULL, @wk_oper_code = 'XXXX',
	@wk_temp = 1

SELECT	@wk_case_no = kc_case_no, @wk_pay_date = kc_pay_date,
	@wk_item_no = kc_item_no, @wk_pay_type = kc_pay_type,
	@wk_trans_no = kc_trans_no, @wk_pay_fee = kc_pay_fee,	@wk_rece_code = kc_rece_code, @wk_oper_code = kc_oper_code
FROM	inserted

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
	FROM	kcsd.kc_paymentcenter
	WHERE	kc_case_no = @wk_case_no

	UPDATE	kcsd.kc_paymentcenter
	SET	kc_item_no = @wk_item_no,
		kc_updt_date = GETDATE(),
		kc_updt_user = USER
	WHERE	kc_case_no = @wk_case_no
	AND	kc_pay_date = @wk_pay_date
	AND	kc_item_no IS NULL
END

	SELECT	@wk_pay_rema = @wk_pay_fee

WHILE	( @wk_pay_rema>0 AND @wk_fail_flag=NULL )
BEGIN
	SELECT	@wk_perd_no = ISNULL(MAX(kc_perd_no), 0)
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_expt_fee > 0
	AND	(kc_pay_fee IS NULL OR kc_pay_fee=0)
	AND	kc_perd_no >= 50

	IF	@wk_perd_no = 0
	BEGIN
		SELECT	@wk_perd_no = ISNULL(MIN(kc_perd_no), 0)
		FROM	kcsd.kc_loanpayment
		WHERE	kc_case_no = @wk_case_no
		AND	kc_expt_fee > 0
		AND	(kc_pay_fee IS NULL OR kc_pay_fee=0)
	END

	SELECT	@wk_expt_fee = kc_expt_fee
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no

	IF	@wk_pay_rema > @wk_expt_fee
		SELECT	@wk_pay_fee2 = @wk_expt_fee
	ELSE
		SELECT	@wk_pay_fee2 = @wk_pay_rema

	IF	@wk_pay_fee2 <= 0
	BEGIN
		RAISERROR ('[KC] [PA001])  無法轉入每期付款!!',18,2) WITH SETERROR
		ROLLBACK TRANSACTION
		RETURN
	END

	IF	@wk_temp = 1  

	BEGIN
		SELECT @wk_temp = 0

		IF	@wk_rece_code = 'TWP' 
			SELECT	@wk_proc_fee = 15
		ELSE
			SELECT	@wk_proc_fee = 14
		END

	ELSE	SELECT	@wk_proc_fee = 0


	SELECT	@wk_pay_rema = @wk_pay_rema - @wk_pay_fee2 

	SELECT	@wk_oper_code = EmpCode
	FROM	kcsd.v_Employee
	WHERE	UserCode = USER_NAME()

	UPDATE	kcsd.kc_loanpayment
	SET	kc_pay_date = @wk_pay_date,
		kc_pay_fee = @wk_pay_fee2,
		kc_pay_type = @wk_pay_type,
		kc_trans_no = @wk_trans_no,
		kc_oper_code = @wk_oper_code,
		kc_rece_code = @wk_rece_code,	/* Convient Store*/
		kc_proc_fee = @wk_proc_fee
	WHERE	kc_case_no = @wk_case_no
	AND	kc_perd_no = @wk_perd_no

END





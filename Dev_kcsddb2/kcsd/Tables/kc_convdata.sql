CREATE TABLE [kcsd].[kc_convdata] (
    [kc_conv_date]  SMALLDATETIME NOT NULL,
    [kc_case_no]    VARCHAR (10)  NOT NULL,
    [kc_conv_no]    INT           NULL,
    [kc_conv_code1] VARCHAR (30)  NULL,
    [kc_conv_code2] VARCHAR (30)  NULL,
    [kc_conv_code3] VARCHAR (30)  NULL,
    [kc_conv_amt]   INT           NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_perd_no]    SMALLINT      NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_convdata]
    ON [kcsd].[kc_convdata]([kc_case_no] ASC, [kc_perd_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_convdata_2]
    ON [kcsd].[kc_convdata]([kc_conv_code3] ASC);


GO
-- ==========================================================================================
-- 2010-02-27 KC: 郵局劃撥轉帳 paytype為X
-- 2009-11-21 KC: 新增rece_code CTC 合庫
-- 2009-10-18 KC: 新增rece_code CTW台銀, UPDATE 改用 @wk_rece_code
-- ==========================================================================================
CREATE        TRIGGER [kcsd].[t_kc_convdata_i] ON [kcsd].[kc_convdata] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE	@wk_conv_date	datetime,
	@wk_conv_amt	int,
	@wk_case_no	varchar(10),
	@wk_conv_no	int,
	@wk_pay_type	varchar(1),
	@wk_conv_code2	varchar(10),
	@wk_conv_code3	varchar(10),
	@wk_oper_code	varchar(10),
	@wk_rece_code	varchar(10)

SELECT	@wk_conv_date = NULL, @wk_conv_amt = 0, @wk_case_no = NULL,
	@wk_conv_no = NULL, @wk_pay_type = NULL, @wk_conv_code3 = NULL,
	@wk_oper_code = NULL, @wk_rece_code = NULL

SELECT	@wk_conv_date = kc_conv_date, @wk_conv_amt = kc_conv_amt, @wk_case_no = kc_case_no,
	@wk_conv_no = kc_conv_no, @wk_conv_code2 = kc_conv_code2,
	@wk_conv_code3 = kc_conv_code3
FROM	inserted

SELECT	@wk_pay_type = '7'

IF	@wk_conv_no IS NULL
BEGIN
	SELECT	@wk_conv_no = ISNULL(MAX(kc_conv_no), 0) + 1
	FROM	kcsd.kc_convdata

	UPDATE	kcsd.kc_convdata
	SET	kc_conv_no = @wk_conv_no,
		kc_updt_user = USER, kc_updt_date = GETDATE()
	WHERE	kc_conv_date = @wk_conv_date
	AND	kc_case_no = @wk_case_no
	AND	kc_conv_no IS NULL
END

/* get oper_code */
SELECT	@wk_oper_code = EmpCode
FROM	kcsd.v_Employee
WHERE	UserCode = USER_NAME()

-- rece_code
IF	@wk_conv_code2 = 'CTW'
	SELECT	@wk_rece_code = 'CTW'
ELSE
--BEGIN
	IF	@wk_conv_code2 = 'CTC'
		SELECT	@wk_rece_code = 'CTC'
	ELSE 	IF	@wk_conv_code2 = 'TWP'
			SELECT	@wk_rece_code = 'TWP', @wk_pay_type = 'X'
		ELSE
			SELECT	@wk_rece_code = 'CS'+SUBSTRING(@wk_conv_code2, 7, 2)
--END

/* into Payment Center */
INSERT	kcsd.kc_paymentcenter
	(kc_case_no, kc_pay_date, kc_pay_fee, kc_pay_type,
	kc_trans_no, kc_rece_code,
	kc_oper_code)
VALUES	(@wk_case_no, @wk_conv_date, @wk_conv_amt, @wk_pay_type,
--	LEFT(@wk_conv_code3, 9), 'CS'+SUBSTRING(@wk_conv_code2, 7, 2),
	LEFT(@wk_conv_code3, 9), @wk_rece_code,
	@wk_oper_code)









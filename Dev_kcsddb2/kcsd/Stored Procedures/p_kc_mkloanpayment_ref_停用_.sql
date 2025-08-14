CREATE PROCEDURE [kcsd].[p_kc_mkloanpayment_ref(停用)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_loan_perd	int,
	@wk_perd_fee	int,
	@wk_counter	int

SELECT	@wk_case_no = NULL

DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan2
	WHERE	kc_loan_type = 'D'

	AND	kc_loan_stat = 'P'

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN	
	SELECT	@wk_case_no

	SELECT	@wk_loan_perd = kc_loan_perd, @wk_perd_fee = kc_perd_fee
	FROM	kcsd.kc_customerloan2
	WHERE	kc_case_no = @wk_case_no

	/* insert new item */
	SELECT	@wk_counter = 0
	WHILE	@wk_counter < @wk_loan_perd
	BEGIN
		INSERT	kcsd.kc_loanpayment2_ref
			(kc_case_no, kc_perd_no, kc_expt_fee)
		VALUES
			(@wk_case_no, @wk_counter+1, @wk_perd_fee)
		SELECT	@wk_counter=@wk_counter+1

	END

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

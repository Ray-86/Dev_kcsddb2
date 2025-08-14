CREATE   PROCEDURE [kcsd].[p_kc_updateloanstatus_recheck(停用)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_over_amt	int,			/* 逾期金額 */
	@wk_arec_amt	int,			/* 未繳金額 = over_amt + under_amt */
	@wk_dday_date	datetime,		/* dummy for p_kc_getoveramt */

	@wk_today	datetime

SELECT	@wk_case_no=NULL, @wk_today = GETDATE()

DECLARE	cursor_caseclose	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat = 'C'
	OR	kc_loan_stat = 'E'

OPEN cursor_caseclose
FETCH NEXT FROM cursor_caseclose INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	EXECUTE	kcsd.p_kc_getoveramt @wk_case_no, @wk_today, @wk_over_amt OUTPUT, @wk_arec_amt OUTPUT, @wk_dday_date OUTPUT
	
	IF	@wk_over_amt > 0
	OR	@wk_arec_amt > 0
	BEGIN
		UPDATE	kcsd.kc_customerloan
		SET	kc_loan_stat = 'D'
		WHERE	kc_case_no = @wk_case_no
	END

	FETCH NEXT FROM cursor_caseclose INTO @wk_case_no
END

DEALLOCATE	cursor_caseclose

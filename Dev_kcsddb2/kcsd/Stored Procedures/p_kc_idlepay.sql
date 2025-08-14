CREATE  PROCEDURE [kcsd].[p_kc_idlepay]	@pm_strt_date DATETIME=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_case_no	varchar(10)

SELECT	@wk_case_no=NULL

DECLARE	cursor_idle_case	CURSOR
FOR	SELECT	DISTINCT c.kc_case_no
	FROM	kcsd.kc_customerloan c, kcsd.kc_loanpayment p
	WHERE	c.kc_idle_date IS NOT NULL
	AND	c.kc_idle_amt IS NOT NULL
	AND	c.kc_case_no = p.kc_case_no
	AND	p.kc_pay_date BETWEEN @pm_strt_date AND @pm_stop_date
	ORDER BY c.kc_case_no

OPEN cursor_idle_case
FETCH NEXT FROM cursor_idle_case INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	
	SELECT	@wk_case_no

	FETCH NEXT FROM cursor_idle_case INTO @wk_case_no
END

DEALLOCATE	cursor_idle_case

/* 10/11/05 KC: P1 monthly 誤轉為舊式pusher故 undo
		共720筆, updt_date 10/10/05 18:00~18:01, updt_user dbo
*/
CREATE    PROCEDURE [kcsd].[p_kc_pushassign_undoloop]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_count	int

SELECT	@wk_case_no=NULL, @wk_count = 0

DECLARE	cursor_case_no	CURSOR
FOR	/* 10/11/05 KC */
	SELECT	kc_case_no
	FROM	kc_customerloan
	WHERE	kc_area_code = '01'
	AND	kc_pusher_code NOT LIKE 'Z%'
	AND	kc_pusher_code NOT LIKE 'L%'
	AND	kc_pusher_code NOT LIKE 'P%'
	AND	kc_pusher_code <> '1101'
	AND	kc_pusher_code <> '1111'

/*	SELECT	p.kc_case_no
	FROM	kcsd.kc_pushassign p, kc_customerloan c
	WHERE	p.kc_case_no = c.kc_case_no
	AND	p.kc_strt_date BETWEEN '11/27/2003' AND '11/27/2003 23:59:59'
	AND	c.kc_loan_stat = 'D'
	AND	c.kc_sales_code = '1211'
	AND	( c.kc_pusher_code = '1105' OR c.kc_pusher_code = '1116' ) */

/* Case 1:
	AND	p.kc_strt_date BETWEEN '11/27/2003' AND '11/27/2003 23:59:59'
	AND	c.kc_loan_stat = 'D'
	AND	( c.kc_pusher_code = '1106' OR c.kc_pusher_code = '1132' )
*/
/*	GROUP BY p.kc_case_no */

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no


WHILE (@@FETCH_STATUS = 0)
BEGIN

	SELECT	@wk_count = @wk_count + 1	
	SELECT	@wk_case_no

	/* EXECUTE	kcsd.p_kc_pushassign_undo @wk_case_no */
	EXECUTE	kcsd.p_kc_pushassign_undo_pusherpx @wk_case_no	/* 10/11/05 KC */

	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

SELECT	@wk_count

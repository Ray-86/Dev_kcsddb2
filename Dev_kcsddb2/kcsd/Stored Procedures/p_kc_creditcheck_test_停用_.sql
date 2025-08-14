CREATE PROCEDURE [kcsd].[p_kc_creditcheck_test(停用)] @pm_query_input char(20)
AS
/*
B: Â┬ªW│µ
C: ½╚ñß, C2:ºC╣sºQ, C3:┬┬½╚ñß
D: ½OñH, D2:ºC╣sºQ, D3:┬┬½OñH
T: ¿õÑL¿«ªµ
R: ┐╦─¦, R2:ºC╣sºQ
*/
/* Â┬ªW│µ */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'Â┬ªW│µ' as wk_cust_type, 'B' as wk_link_type, kc_id_no as wk_link_info,
	'Â┬ªW│µ' as wk_loan_stat
FROM	kcsd.kc_blacklist
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ½╚ñß -- C */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½╚ñß' as wk_cust_type, 'C' as wk_link_type, kc_case_no as wk_link_info,
	s.kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	c.kc_cust_name = @pm_query_input
OR	c.kc_id_no = @pm_query_input
UNION ALL

/* ºC╣sºQ½╚ñß -- C2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ½╚ñß' as wk_cust_type, 'C2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat	
FROM	kcsd.kc_customerloan2 c LEFT JOIN kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ½OñH1 -- D */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½OñH' as wk_cust_type, 'D' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
UNION ALL

/* ½OñH2 -- D */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½OñH' as wk_cust_type, 'D' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name2 = @pm_query_input
OR	kc_id_no2 = @pm_query_input
UNION ALL

/* ºC╣sºQ½OñH -- D2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ½OñH' as wk_cust_type, 'D2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan2 c LEFT JOIN kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_cust_name2 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
OR	kc_id_no2 = @pm_query_input
UNION ALL


/* ¿õÑL¿«ªµ -- T */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'¿õÑL¿«ªµ' as wk_cust_type, 'T' as wk_link_type, kc_id_no as wk_link_info,
	'¿õÑL¿«ªµ' as wk_loan_stat
FROM	kcsd.kc_othercase
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ┬┬½╚ñß -- C3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½╚ñß' as wk_cust_type, 'C3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsd.kc_customerold c
WHERE	c.kc_cust_name = @pm_query_input
OR	c.kc_id_no = @pm_query_input
UNION ALL

/* ┬┬½OñH1 -- D3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½OñH' as wk_cust_type, 'D3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsd.kc_customerold c
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
UNION ALL


/* ┬┬½OñH2 -- D3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½OñH' as wk_cust_type, 'D3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsd.kc_customerold c
WHERE	kc_cust_name2 = @pm_query_input
OR	kc_id_no2 = @pm_query_input

UNION ALL

/* ┐╦─¦ -- R */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┐╦─¦' as wk_cust_type, 'R' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan c LEFT JOIN kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_mate_name = @pm_query_input
OR	kc_papa_name = @pm_query_input
OR	kc_mama_name = @pm_query_input
OR	kc_mate_name1 = @pm_query_input
OR	kc_papa_name1 = @pm_query_input
OR	kc_mama_name1 = @pm_query_input
OR	kc_mate_name2 = @pm_query_input
OR	kc_papa_name2 = @pm_query_input
OR	kc_mama_name2 = @pm_query_input

UNION ALL

/* ºC╣sºQ┐╦─¦ -- R2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ┐╦─¦' as wk_cust_type, 'R2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsd.kc_customerloan2 c LEFT JOIN kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_mate_name = @pm_query_input
OR	kc_papa_name = @pm_query_input
OR	kc_mama_name = @pm_query_input
OR	kc_mate_name1 = @pm_query_input
OR	kc_papa_name1 = @pm_query_input
OR	kc_mama_name1 = @pm_query_input
OR	kc_mate_name2 = @pm_query_input
OR	kc_papa_name2 = @pm_query_input
OR	kc_mama_name2 = @pm_query_input

UNION ALL

/* ------------------------------------------------- */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'Â┬ªW│µ' as wk_cust_type, 'B' as wk_link_type, kc_id_no as wk_link_info,
	'Â┬ªW│µ' as wk_loan_stat
FROM	kcsddb.kcsd.kc_blacklist
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ½╚ñß -- C */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½╚ñß' as wk_cust_type, 'C' as wk_link_type, kc_case_no as wk_link_info,
	s.kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan c LEFT JOIN kcsddb.kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	c.kc_cust_name = @pm_query_input
OR	c.kc_id_no = @pm_query_input
UNION ALL

/* ºC╣sºQ½╚ñß -- C2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ½╚ñß' as wk_cust_type, 'C2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat	
FROM	kcsddb.kcsd.dy1kc_customerloan2 c LEFT JOIN kcsddb.kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ½OñH1 -- D */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½OñH' as wk_cust_type, 'D' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan c LEFT JOIN kcsddb.kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
UNION ALL

/* ½OñH2 -- D */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'½OñH' as wk_cust_type, 'D' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan c LEFT JOIN kcsddb.kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name2 = @pm_query_input
OR	kc_id_no2 = @pm_query_input
UNION ALL

/* ºC╣sºQ½OñH -- D2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ½OñH' as wk_cust_type, 'D2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan2 c LEFT JOIN kcsddb.kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_cust_name2 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
OR	kc_id_no2 = @pm_query_input
UNION ALL


/* ¿õÑL¿«ªµ -- T */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'¿õÑL¿«ªµ' as wk_cust_type, 'T' as wk_link_type, kc_id_no as wk_link_info,
	'¿õÑL¿«ªµ' as wk_loan_stat
FROM	kcsddb.kcsd.kc_othercase
WHERE	kc_cust_name = @pm_query_input
OR	kc_id_no = @pm_query_input
UNION ALL

/* ┬┬½╚ñß -- C3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½╚ñß' as wk_cust_type, 'C3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsddb.kcsd.kc_customerold c
WHERE	c.kc_cust_name = @pm_query_input
OR	c.kc_id_no = @pm_query_input
UNION ALL

/* ┬┬½OñH1 -- D3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½OñH' as wk_cust_type, 'D3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsddb.kcsd.kc_customerold c
WHERE	kc_cust_name1 = @pm_query_input
OR	kc_id_no1 = @pm_query_input
UNION ALL


/* ┬┬½OñH2 -- D3 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┬┬½OñH' as wk_cust_type, 'D3' as wk_link_type, kc_case_no as wk_link_info,
	'' as wk_loan_stat
FROM	kcsddb.kcsd.kc_customerold c
WHERE	kc_cust_name2 = @pm_query_input
OR	kc_id_no2 = @pm_query_input

UNION ALL

/* ┐╦─¦ -- R */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'┐╦─¦' as wk_cust_type, 'R' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan c LEFT JOIN kcsddb.kcsd.kc_loanstatus s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_mate_name = @pm_query_input
OR	kc_papa_name = @pm_query_input
OR	kc_mama_name = @pm_query_input
OR	kc_mate_name1 = @pm_query_input
OR	kc_papa_name1 = @pm_query_input
OR	kc_mama_name1 = @pm_query_input
OR	kc_mate_name2 = @pm_query_input
OR	kc_papa_name2 = @pm_query_input
OR	kc_mama_name2 = @pm_query_input

UNION ALL

/* ºC╣sºQ┐╦─¦ -- R2 */
SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
	'ºC╣sºQ┐╦─¦' as wk_cust_type, 'R2' as wk_link_type, kc_case_no as wk_link_info,
	kc_loan_desc as wk_loan_stat
FROM	kcsddb.kcsd.dy1kc_customerloan2 c LEFT JOIN kcsddb.kcsd.kc_loanstatus2 s ON c.kc_loan_stat = s.kc_loan_stat
WHERE	kc_mate_name = @pm_query_input
OR	kc_papa_name = @pm_query_input
OR	kc_mama_name = @pm_query_input
OR	kc_mate_name1 = @pm_query_input
OR	kc_papa_name1 = @pm_query_input
OR	kc_mama_name1 = @pm_query_input
OR	kc_mate_name2 = @pm_query_input
OR	kc_papa_name2 = @pm_query_input
OR	kc_mama_name2 = @pm_query_input

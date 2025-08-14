CREATE PROCEDURE [kcsd].[p_kc_getcleanup_cand]
AS
SELECT	kc_id_no
FROM	kcsd.kc_customerloan
WHERE	kc_id_no NOT IN
(SELECT DISTINCT kc_id_no
FROM	kcsd.kc_customerloan
WHERE	kc_loan_stat <> 'C'
AND	kc_loan_stat <> 'E'
UNION
SELECT DISTINCT kc_id_no1
FROM	kcsd.kc_customerloan
WHERE	kc_loan_stat <> 'C'
AND	kc_loan_stat <> 'E'
AND	kc_id_no1 IS NOT NULL
UNION
SELECT DISTINCT kc_id_no2
FROM	kcsd.kc_customerloan
WHERE	kc_loan_stat <> 'C'
AND	kc_loan_stat <> 'E'
AND	kc_id_no2 IS NOT NULL)

-- 09/05/2009 KC: Fix 某些黑名單不會出現--> 當有other_case時, 黑名單會被刪除(因case_no為相同id)
-- 11/08/2008: 刪除CP結果為自己這個CP

CREATE       PROCEDURE [kcsd].[p_kc_cpdupclear]
@pm_cp_no varchar(10)=NULL
AS

DECLARE	@wk_case_no	varchar(10),
	@wk_count	int,
	@wk_rowcount	int,
	@wk_cust_type	varchar(10)

SELECT	@wk_case_no=NULL

DECLARE	cursor_case_no_cpdup	CURSOR
FOR	SELECT	DISTINCT kc_case_no, kc_cust_type
	FROM	kcsd.kc_cpresult
	WHERE	kc_cp_no = @pm_cp_no
	AND	kc_cp_no IS NOT NULL
	--AND	kc_cp_no IS NOT NULL
	ORDER BY kc_case_no, kc_cust_type

OPEN cursor_case_no_cpdup
FETCH NEXT FROM cursor_case_no_cpdup INTO @wk_case_no, @wk_cust_type


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_count = 0, @wk_rowcount = 0

	SELECT	@wk_count = COUNT(kc_cp_no)
	FROM	kcsd.kc_cpresult
	WHERE	kc_cp_no = @pm_cp_no
	AND	kc_case_no = @wk_case_no
	AND	kc_cust_type = @wk_cust_type

	IF	@wk_count > 1
	BEGIN
		SELECT	@wk_rowcount = @wk_count - 1

		SET ROWCOUNT @wk_rowcount

		DELETE
		FROM	kcsd.kc_cpresult
		WHERE	kc_cp_no = @pm_cp_no
		AND	kc_case_no = @wk_case_no
		AND	kc_cust_type = @wk_cust_type

		SET ROWCOUNT 0
	END

	FETCH NEXT FROM cursor_case_no_cpdup INTO @wk_case_no, @wk_cust_type
END

DEALLOCATE	cursor_case_no_cpdup

IF	EXISTS
	(SELECT	*
	FROM	kcsd.kc_cpdata p, kcsd.kc_customerloan c, kcsd.kc_cpresult r
	WHERE	c.kc_cp_no = p.kc_cp_no
	AND	p.kc_apply_stat = 'P'
	AND	c.kc_cp_no = r.kc_case_no
	AND	r.kc_cp_no = @pm_cp_no)
	DELETE
	FROM	kcsd.kc_cpresult
	WHERE	kc_cp_no = @pm_cp_no
	AND	kc_cust_type = 'CP'
	AND	kc_case_no IN
		(
		SELECT	c.kc_cp_no
		FROM	kcsd.kc_cpdata p, kcsd.kc_customerloan c, kcsd.kc_cpresult r
		WHERE	c.kc_cp_no = p.kc_cp_no
		AND	p.kc_apply_stat = 'P'
		AND	c.kc_cp_no = r.kc_case_no
		AND	r.kc_cp_no = @pm_cp_no)

-- 刪除CP結果為自己這個CP
DELETE
FROM	kcsd.kc_cpresult
WHERE	kc_cp_no = @pm_cp_no
AND	kc_case_no = @pm_cp_no
AND	kc_cust_type = 'CP'

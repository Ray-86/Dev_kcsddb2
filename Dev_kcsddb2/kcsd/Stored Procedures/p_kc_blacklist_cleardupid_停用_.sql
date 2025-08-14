-- ==========================================================================================
-- 03/01/09 Blacklist changed to master/detail, so have to clear dup rows at blacklist
-- ==========================================================================================
CREATE  PROCEDURE [kcsd].[p_kc_blacklist_cleardupid(停用)] @pm_run_code varchar(20)=NULL
AS
DECLARE	@wk_id_no	varchar(10)

CREATE TABLE #tmp_blacklist
(kc_id_no	varchar(10)
)

SELECT	@wk_id_no=NULL

DECLARE	cursor_case_no_black	CURSOR
FOR	SELECT	kc_id_no
	FROM	kcsd.kc_blacklist
	--WHERE	kc_id_no LIKE 'A100%'
	GROUP BY kc_id_no
	HAVING COUNT(kc_id_no) > 1
	ORDER BY kc_id_no

OPEN cursor_case_no_black
FETCH NEXT FROM cursor_case_no_black INTO @wk_id_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	INSERT	#tmp_blacklist
		(kc_id_no)
	VALUES	(@wk_id_no)

	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		SET ROWCOUNT 1

		DELETE
		FROM	kcsd.kc_blacklist
		WHERE	kc_id_no = @wk_id_no

		SET ROWCOUNT 0
	END
	
	FETCH NEXT FROM cursor_case_no_black INTO @wk_id_no
END

DEALLOCATE	cursor_case_no_black

SELECT	count(*)
FROM	#tmp_blacklist

SELECT	*
FROM	#tmp_blacklist

DROP TABLE #tmp_blacklist

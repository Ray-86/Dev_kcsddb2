-- ==========================================================================================
-- 11/29/08 KC: rebuild kc_caselink, 並改用 p_kc_caselink_sub_connect 來連接 case
-- 07/29/06 KC: batch to build caselink for new case, to avoid insert trigger err message
-- ==========================================================================================
CREATE    PROCEDURE [kcsd].[p_kc_caselink_queue(停用)]
AS
DECLARE	@wk_case_no	varchar(10),
	@wk_cp_no	varchar(10)

SELECT	@wk_case_no=NULL, @wk_cp_no=NULL

DECLARE	cursor_caselinkq_case_no	CURSOR
FOR	SELECT	kc_case_no, kc_cp_no
	FROM	kcsd.kc_caselink_queue
	--WHERE	kc_case_no = '0825115'
	ORDER BY kc_case_no

OPEN cursor_caselinkq_case_no
FETCH NEXT FROM cursor_caselinkq_case_no INTO @wk_case_no, @wk_cp_no


WHILE (@@FETCH_STATUS = 0)
BEGIN
	-- 執行 caselink
	EXECUTE kcsd.p_kc_caselink @wk_case_no, @wk_cp_no

	DELETE
	FROM	kcsd.kc_caselink_queue
	WHERE	kc_case_no = @wk_case_no

	FETCH NEXT FROM cursor_caselinkq_case_no INTO @wk_case_no, @wk_cp_no
END

DEALLOCATE	cursor_caselinkq_case_no

-- ==========================================================================================
-- 11/29/08 KC: rebuild kc_caselink, 並改用 p_kc_caselink_sub_connect 來連接 case
-- 11/17/06 KC: fix a bug for MAX cp number (忘記 SELECT MAX, 故產生莫名其妙連結)
-- 11/17/06 KC: add drop #tmp tables, try to solve unrelated links (too many members!)
-- 07/17/06 KC: fix insert kc_caselink with column names failed because of new column added
-- 07/08/06 KC:	Fix 同一天CP不會連結, 漏網之魚 (改用 EXEC SUB)
-- 07/08/06 KC: TODO, use p_kc_caselink_sub_connect to link case !!!
-- 07/01/06 KC:	Fix 同一天CP不會連結, 漏網之魚
-- ==========================================================================================
CREATE	PROCEDURE [kcsd].[p_kc_caselink] @pm_case_no varchar(10)=NULL
AS
DECLARE
	@wk_link_no	int,
	@wk_cp_no	varchar(10),
	@wk_case_count	int,
	@wk_link_count	int,
	@wk_link_max	int,
	@wk_case_no	varchar(10)

CREATE TABLE #tmp_caselink_recheck_case
(
kc_case_no	varchar(10),
kc_link_id varchar(10),
kc_link_type varchar(10)
)

EXECUTE kcsd.p_kc_caselink_recheck @pm_case_no

/*
-- MenuCode,ParentCode


	DECLARE	cursor_caselink_caseno CURSOR
	FOR	SELECT	kc_case_no
		FROM	#tmp_caselink_recheck_case
		ORDER BY kc_case_no
	OPEN cursor_caselink_caseno
	FETCH NEXT FROM cursor_caselink_caseno INTO @wk_case_no
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	print @wk_case_no
		EXECUTE kcsd.p_kc_caselink_recheck @wk_case_no,'1'
		INSERT	#tmp_caselink_caseno SELECT	DISTINCT * FROM #tmp_caselink_recheck_case where kc_case_no <> @wk_case_no
	FETCH NEXT FROM cursor_caselink_caseno INTO @wk_case_no
	END
	DEALLOCATE	cursor_caselink_caseno
	*/

SELECT	DISTINCT A.*,c.kc_area_code +' '+ d.kc_area_desc as kc_area_desc,c.kc_cust_nameu,c.kc_cust_name1u,c.kc_cust_name2u,c.kc_pusher_code,c.kc_push_sort,c.kc_over_count,c.kc_dday_count,c.kc_over_amt,c.kc_loan_stat+' '+ s.Text as kc_loan_desc,c.kc_push_memo3
FROM	#tmp_caselink_recheck_case A left join kcsd.kc_customerloan c on A.kc_case_no = c.kc_case_no
									 left join kcsd.kct_area d on d.kc_area_code = c.kc_area_code
									 left join (select * from [Zephyr.Sys].dbo.sys_code where CodeType ='LoanCode') s on c.kc_loan_stat = s.Value

DROP TABLE #tmp_caselink_recheck_case
-- ==========================================================================================
-- 2021-08-23 新增CP特約COUNT
-- 2021-02-25 增加勞保查詢數 @wk_furuser1_count
-- 2012-11-09 增加欄位
-- ==========================================================================================

CREATE    PROCEDURE [kcsd].[p_kc_stat_ad]
	@pm_strt_date datetime=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_user_name	varchar(20),
	@dummy		varchar(20),
	@wk_area_code 	varchar(2),
	@wk_emp_name	nvarchar(10),
	@wk_emp_code	varchar(4),
	@wk_cp_count	int,
	@wk_contractcheck_count	int,
	@wk_contractaccept_count	int,
	@wk_case_count	int,
	@wk_movablecrdt_count	int,
	@wk_movableupdt_count	int,
	@wk_furuser1_count		int,
	@wk_bobocp_count		int,
	@wk_boroI_count			int,
	@wk_boroD_count			int,
	@wk_post_count			int,
	@wk_bill_count			int,
	@wk_cancel_count		int

SELECT	@wk_user_name=NULL
SELECT	@wk_cp_count = 0
SELECT	@wk_contractaccept_count = 0
SELECT	@wk_contractcheck_count = 0
SELECT	@wk_case_count = 0
SELECT	@wk_movablecrdt_count = 0
SELECT	@wk_movableupdt_count = 0
SELECT	@wk_furuser1_count = 0
SELECT	@wk_bobocp_count = 0
SELECT  @wk_boroI_count = 0
SELECT  @wk_boroD_count = 0
SELECT  @wk_post_count = 0
SELECT  @wk_bill_count = 0
SELECT  @wk_cancel_count = 0

CREATE TABLE #tmp_stat_pushcall
(
kc_user_name	varchar(20),
kc_emp_name		nvarchar(10),
kc_area_code 	varchar(2),
kc_cp_count	int,
kc_contractaccept_count	INT,
kc_contractcheck_count	int,
kc_case_count	int,
kc_movablecrdt_count	int,
kc_movableupdt_count	int,
kc_furuser1_count		int,
kc_bobocp_count			int,
kc_boroI_count			int,
kc_boroD_count			int,
kc_post_count			int,
kc_bill_count			int,
kc_cancel_count			int
)

DECLARE	cursor_pusher	CURSOR
FOR	SELECT	DISTINCT e.UserCode
	FROM	kcsd.v_Employee e
	WHERE	e.JobType = 'B'
	AND e.AreaCode = '00'
	AND IsEnable = 1

OPEN cursor_pusher
FETCH NEXT FROM cursor_pusher INTO @wk_user_name

WHILE (@@FETCH_STATUS = 0)
BEGIN

	/* CP數 */
	SELECT	@wk_cp_count = count(c.kc_cp_no)
	FROM	kcsd.kc_cplog c
	WHERE	kc_type = 'FurtherSalesCpNo'
	AND		convert(varchar, c.CreateDate, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND		c.CreatePerson = @wk_user_name

	/*CP特約數*/
	SELECT	@wk_bobocp_count = count(c.kc_cp_no)
	FROM	kcsd.kc_cplog c
	WHERE	kc_type = 'FurtherCpNo3'
	AND		convert(varchar, c.CreateDate, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND		c.CreatePerson = @wk_user_name
	
	/* 點收契約數 */
	SELECT	@wk_contractaccept_count = count(c.kc_rcpt_user)
	FROM	kcsd.kc_customerloan1 c
	WHERE	c.kc_rcpt_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND c.kc_rcpt_user = @wk_user_name
	
	/* 審核契約數 */
	SELECT	@wk_contractcheck_count = count(c.kc_audit_user)
	FROM	kcsd.kc_customerloan1 c, kcsd.kc_customerloan cm
	WHERE	cm.kc_case_no = c.kc_case_no
	AND	cm.kc_ret_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND c.kc_audit_user = @wk_user_name
	
	/* 客戶數 */
--	SELECT	@dummy = p.kc_updt_user
--	FROM	kcsd.kc_push p
--	WHERE	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
--	AND	p.kc_updt_user = @wk_user_name
--	AND	p.kc_push_note NOT LIKE '%系統%'
--	GROUP BY p.kc_updt_user, p.kc_case_no, DATEDIFF(day, '1/1/2000', kc_push_date)

--	SELECT	@wk_case_count = @@rowcount
--	SELECT	@wk_case_count = 0
	SELECT @wk_case_count = count(t.kc_updt_user)
	FROM
	(SELECT p.kc_updt_user
	FROM kcsd.kc_push p
	WHERE	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	p.kc_updt_user = @wk_user_name
	AND	p.kc_push_note NOT LIKE '%系統%'
	GROUP BY p.kc_updt_user, p.kc_case_no, DATEDIFF(day, '1/1/2000', kc_push_date)
	) as t

	/* 動保設定建檔 */
	SELECT	@wk_movablecrdt_count = COUNT(*)
	FROM	kcsd.kc_movable m
	WHERE	m.kc_movable_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	m.kc_movable_user = @wk_user_name

	/* 動保設定上傳 */
	SELECT	@wk_movableupdt_count = COUNT(*)
	FROM	kcsd.kc_movable m
	WHERE	m.kc_update_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	m.kc_update_user = @wk_user_name

	/*勞保查詢數*/
	SELECT	@wk_furuser1_count = count(c.kc_cp_no)
	FROM	kcsd.kc_cpdata c
	WHERE	convert(varchar, c.kc_further_date1, 23) BETWEEN @pm_strt_date AND @pm_stop_date 
	AND c.kc_further_user1 = @wk_user_name
	
	/* 其他資料 */
	SELECT @wk_area_code = AreaCode, @wk_emp_name = EmpName, @wk_emp_code = EmpCode FROM kcsd.v_Employee e WHERE UserCode = @wk_user_name

	/*契約在館*/
	SELECT @wk_boroI_count = COUNT(c.kc_case_no)
	FROM   kcsd.kc_customerloan c
	WHERE  convert(varchar, c.kc_boro_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND c.kc_boro_stat = 'I'
	AND c.kc_boro_code = @wk_emp_code

	/*契約銷毀*/
	SELECT @wk_boroD_count = COUNT(c.kc_case_no)
	FROM   kcsd.kc_customerloan c
	WHERE  convert(varchar, c.kc_boro_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND c.kc_boro_stat in ('B', 'D')
	AND c.kc_boro_code = @wk_emp_code

	/*郵簡*/
	SELECT @wk_post_count = COUNT(l.kc_updt_user)
	FROM   kcsd.kc_lawstatus l
	WHERE  convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND (l.kc_law_code in ('4', '5', 'B', 'L', 'O', 'R') OR (l.kc_law_code = 'F' AND l.kc_law_fmt in ('F1', 'F2', 'F3', 'F4', 'F5')))

	/*帳單*/
	SELECT @wk_bill_count = COUNT(l.kc_updt_user)
	FROM   kcsd.kc_lawstatus l
	WHERE  convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code in ('T', 'Q')

	/*塗銷*/
	SELECT @wk_cancel_count = COUNT(m.kc_cancel_user)
	FROM   kcsd.kc_movable m
	WHERE  convert(varchar, kc_cancel_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND    kc_cancel_user = @wk_user_name

	INSERT	#tmp_stat_pushcall
	VALUES (@wk_user_name ,@wk_emp_name ,@wk_area_code ,@wk_cp_count, @wk_contractaccept_count, @wk_contractcheck_count, @wk_case_count, 
		@wk_movablecrdt_count, @wk_movableupdt_count, @wk_furuser1_count, @wk_bobocp_count, @wk_boroI_count, @wk_boroD_count,
		@wk_post_count, @wk_bill_count, @wk_cancel_count)	

	FETCH NEXT FROM cursor_pusher INTO @wk_user_name
END

DEALLOCATE	cursor_pusher

SELECT	*
FROM	#tmp_stat_pushcall

DROP TABLE #tmp_stat_pushcall

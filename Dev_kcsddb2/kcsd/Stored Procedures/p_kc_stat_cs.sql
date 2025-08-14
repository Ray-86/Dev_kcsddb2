-- =============================================
-- 客服工作統計
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_stat_cs]	@pm_strt_date datetime=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_user_name	varchar(20),
	@wk_area_code 	varchar(2),
	@wk_emp_name	nvarchar(10),
	@wk_cp_count	int,			/* CP數 */
	@wk_case_count	int,			/* 客戶數 */
	@wk_furuser1_count	int,		/*勞保查詢數*/
	@wk_furuser4_count	int,		/*徵審受理*/
	@wk_cfmuser_count	int,		/*徵審確認*/
	@wk_furuser7_count	int,		/*待辦客服*/
	@wk_noticecfm_count int			/*通知徵審*/


SELECT	@wk_user_name=NULL
SELECT	@wk_cp_count = 0
SELECT	@wk_case_count = 0
SELECT	@wk_furuser1_count = 0
--取一日的最後一秒
select  @pm_stop_date = DATEADD(s,-1,DATEADD(Day,1,@pm_stop_date))

CREATE TABLE #tmp_stat_pushcall
(
kc_user_name	varchar(20),
kc_emp_name		nvarchar(10),
kc_area_code 	varchar(2),
kc_cp_count		int,
kc_case_count	int,
kc_furuser1_count	int,
kc_furuser4_count	int,
kc_cfmuser_count	int,
kc_furuser7_count	int,
kc_noticecfm_count	int
)

DECLARE	cursor_pusher	CURSOR
FOR	SELECT	DISTINCT top 1 e.UserCode
	FROM	kcsd.v_Employee e
	WHERE	e.JobType = 'B'
	AND		IsEnable = 1

OPEN cursor_pusher
FETCH NEXT FROM cursor_pusher INTO @wk_user_name

WHILE (@@FETCH_STATUS = 0)
BEGIN

	/* CP數 */
	SELECT	@wk_cp_count = count(c.kc_cp_no)
	FROM	kcsd.kc_cpdata c
	WHERE	(c.kc_further_user = @wk_user_name AND c.kc_further_date BETWEEN @pm_strt_date AND @pm_stop_date)
		OR (c.kc_further_user3 = @wk_user_name AND c.kc_further_date3 BETWEEN @pm_strt_date AND @pm_stop_date)
		OR (c.kc_further_user5 = @wk_user_name AND c.kc_further_date5 BETWEEN @pm_strt_date AND @pm_stop_date)
	
	/* 客戶數 */
	SELECT @wk_case_count = count(t.kc_updt_user)
	FROM
		(SELECT p.kc_updt_user
		FROM kcsd.kc_push p
		WHERE	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
		AND	p.kc_updt_user = @wk_user_name
		AND	p.kc_push_note NOT LIKE '%系統%'
		GROUP BY p.kc_updt_user, p.kc_case_no, DATEDIFF(day, '1/1/2000', kc_push_date)
		) as t

	/*勞保查詢數*/
	SELECT	@wk_furuser1_count = count(c.kc_cp_no)
	FROM	kcsd.kc_cpdata c
	WHERE	c.kc_further_date1 BETWEEN @pm_strt_date AND @pm_stop_date 
	AND c.kc_further_user1 = @wk_user_name

	/*徵審受理*/
	SELECT @wk_furuser4_count = count(kc_further_user4)
	FROM kcsd.kc_cpdata
	WHERE CONVERT(varchar, kc_further_date4, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND kc_further_user4 = @wk_user_name

	/*徵審確認*/
	SELECT @wk_cfmuser_count = count(CreatePerson)
	FROM kcsd.kc_cplog 
	WHERE kc_type = 'CfmStat' 
	AND CONVERT(varchar, CreateDate, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND CreatePerson = @wk_user_name

	/*待辦客服*/
	SELECT @wk_furuser7_count = count(CreatePerson)
	FROM kcsd.kc_cplog 
	WHERE kc_type = 'FurtherCpNo7' 
	AND CONVERT(varchar, CreateDate, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND CreatePerson = @wk_user_name

	/*通知徵審*/
	SELECT @wk_noticecfm_count = count(CreatePerson)
	FROM kcsd.kc_cplog 
	WHERE kc_type = 'NoticeCfm' 
	AND CONVERT(varchar, CreateDate, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND CreatePerson = @wk_user_name
		
	/* 其他資料 */
	SELECT @wk_area_code = AreaCode, @wk_emp_name = EmpName FROM kcsd.v_Employee e WHERE UserCode = @wk_user_name

	INSERT	#tmp_stat_pushcall
	VALUES (@wk_user_name ,@wk_emp_name ,@wk_area_code ,@wk_cp_count, @wk_case_count, @wk_furuser1_count, @wk_furuser4_count
			, @wk_cfmuser_count, @wk_furuser7_count, @wk_noticecfm_count)	

	FETCH NEXT FROM cursor_pusher INTO @wk_user_name
END

DEALLOCATE	cursor_pusher

SELECT	*
FROM	#tmp_stat_pushcall

DROP TABLE #tmp_stat_pushcall

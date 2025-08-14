-- ==========================================================================================
-- 2021-07-12 新增單獨的分公司篩選
-- 20121109 增加欄位
-- 20160624 增加欄位,增加區域條件
-- 20170413 客戶數不計算簡訊
-- 20210325 增加約收查訪計算
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_stat_pushcall]
	@pm_strt_date datetime=NULL, @pm_stop_date DATETIME=NULL,@pm_area_code varchar(100)=NULL, @pm_job_type varchar(2)=NULL,@wk_area_code2 varchar(2) =NULL
AS
DECLARE	@wk_pusher_code	varchar(6),
	@wk_area_code 	varchar(2),
	@wk_emp_name varchar(10),
	@wk_case_count	int,
	@wk_sms_count	int,
	@wk_codB_count	int,
	@wk_codL_count	int,
	@wk_codP_count	int,
	@wk_codO_count	int,
	@wk_apptA_count	int,
	@wk_apptB_count	int

--取資料權限
CREATE table #tmp_userperm
(kc_user_area VARCHAR(150))
DECLARE @SQL nvarchar(300);
SELECT @SQL = 'Insert into #tmp_userperm (kc_user_area) SELECT kc_area_code FROM kcsd.kct_area '
IF @wk_area_code2 = ''
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ')'
end
else
begin
IF @pm_area_code is not NULL
	SELECT @SQL = @SQL + 'WHERE (kc_area_code in ' + @pm_area_code + ' and kc_area_code = '+ @wk_area_code2 +')'
end
EXEC sp_executesql @SQL

SELECT	@wk_pusher_code = NULL
SELECT	@wk_codB_count = 0
SELECT	@wk_codL_count = 0
SELECT	@wk_codP_count = 0
SELECT	@wk_codO_count = 0
SELECT	@wk_apptA_count = 0
SELECT	@wk_apptB_count = 0

CREATE TABLE #tmp_stat_pushcall
(
kc_emp_code	varchar(6),
kc_area_code 	varchar(2),
kc_emp_name varchar(10),
kc_case_count	int,
kc_sms_count	int,
kc_codB_count	int,
kc_codL_count	int,
kc_codP_count	int,
kc_codO_count	int,
kc_apptA_count	int,
kc_apptB_count	int
)
DECLARE	cursor_pusher	CURSOR
FOR	SELECT	DISTINCT e.EmpCode
	FROM	kcsd.v_Employee e
	WHERE	((e.JobType = 'P' AND @pm_job_type IS NULL) OR (e.JobType IN ('C','D') AND @pm_job_type = 'C'))
	AND e.IsEnable = 1
	AND e.AreaCode IN ( select kc_user_area from #tmp_userperm)
	ORDER BY  e.EmpCode

OPEN cursor_pusher
FETCH NEXT FROM cursor_pusher INTO @wk_pusher_code

WHILE (@@FETCH_STATUS = 0)
BEGIN
	--客戶數
	SELECT @wk_case_count = COUNT(S.kc_case_no)
	FROM
	(SELECT	p.kc_case_no
	FROM	kcsd.kc_push p, kcsd.v_Employee e
	WHERE	e.EmpCode = @wk_pusher_code
	AND	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	p.kc_updt_user = e.UserCode
	AND	p.kc_push_note NOT LIKE '[系統]%'	
	AND Not EXISTS (
		SELECT 'x'
		FROM kcsd.kc_sms s
		WHERE 
		s.kc_case_no = p.kc_case_no AND
		s.kc_msg_date = p.kc_push_date AND
		s.kc_msg_body = p.kc_push_note)
	GROUP BY p.kc_case_no, kc_push_date
	) AS S 
	
	--簡訊數
	SELECT	@wk_sms_count = isnull(count(s.kc_msg_id),0)
	FROM	kcsd.kc_sms s, kcsd.v_Employee e--, kcsd.kc_push p
	WHERE	e.EmpCode = @wk_pusher_code
	AND	s.kc_msg_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND s.kc_updt_user = e.UserCode
	/*AND	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND	p.kc_updt_user = e.UserCode
	AND s.kc_push_link = p.kc_push_link
	AND s.kc_case_no = p.kc_case_no*/
	
	--LAW_CODE數(20121216更新計算方式)
	SELECT 	@wk_codB_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='B'  THEN isnull(slaw.cnt,0) ELSE 0 END),0),	
			@wk_codL_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='L'  THEN isnull(slaw.cnt,0) ELSE 0 END),0),
			@wk_codO_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='O'  THEN isnull(slaw.cnt,0) ELSE 0 END),0),
			@wk_codP_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='P'  THEN isnull(slaw.cnt,0) ELSE 0 END),0)
	FROM 
	(
		SELECT kc_law_code,
		sum(CASE WHEN kc_curr_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_bill_flag = 'Y' THEN 1 ELSE 0 END )+
		sum(CASE WHEN kc_curr_flag1 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag1 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag1= 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_curr_flag2 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag2 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag2 = 'Y' THEN 1 ELSE 0 END) AS cnt
		FROM 
			(
			SELECT	l.kc_law_code, l.kc_curr_flag, l.kc_perm_flag, l.kc_comp_flag, l.kc_bill_flag, 
					l.kc_curr_flag1, l.kc_perm_flag1, l.kc_comp_flag1, l.kc_curr_flag2, l.kc_perm_flag2, l.kc_comp_flag2
				FROM	kcsd.v_Employee as e , kcsd.kc_lawstatus as l
				WHERE	e.EmpCode = @wk_pusher_code
				AND e.UserCode = l.kc_crdt_user  
				AND l.kc_law_date BETWEEN @pm_strt_date AND @pm_stop_date
			) AS law
		GROUP BY kc_law_code
	)AS slaw
	
	--約收 派訪人數
	SELECT @wk_apptA_count = isnull(sum(CASE WHEN kc_appt_type = 'A' THEN 1 ELSE 0 END), 0),
		   @wk_apptB_count = isnull(sum(CASE WHEN kc_appt_type = 'B' THEN 1 ELSE 0 END), 0)
	FROM kcsd.kc_apptschedule
	WHERE kc_appt_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND kc_pusher_code = @wk_pusher_code

	SELECT @wk_area_code = AreaCode,@wk_emp_name = e.EmpName FROM kcsd.v_Employee e WHERE EmpCode = @wk_pusher_code
	INSERT	#tmp_stat_pushcall
		VALUES (@wk_pusher_code,@wk_area_code,@wk_emp_name,@wk_case_count, @wk_sms_count ,@wk_codB_count,@wk_codL_count,@wk_codP_count,@wk_codO_count,@wk_apptA_count,@wk_apptB_count)	
	FETCH NEXT FROM cursor_pusher INTO @wk_pusher_code
END

DEALLOCATE	cursor_pusher

SELECT	*
FROM	#tmp_stat_pushcall
ORDER BY kc_area_code,kc_emp_code

DROP TABLE #tmp_stat_pushcall

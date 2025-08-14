-- ==========================================================================================
-- 20170315 變更欄位
-- 20121109 增加欄位
-- 20160624 增加欄位,增加區域條件
-- 20170413 客戶數不計算簡訊
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_stat_lawcall]
	@pm_strt_date datetime=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_pusher_code	varchar(6),
	@wk_area_code 	varchar(2),
	@wk_emp_name varchar(10),
	@dummy		varchar(6),
	@wk_case_count	INT,
	@wk_sms_count	INT,
	@wk_codA_count	INT,
	@wk_codB_count	INT,
	@wk_codC_count	INT,
	@wk_appt_count	INT,
    @wk_apptA_count	int,
	@wk_apptB_count	int


SELECT	@wk_pusher_code = NULL
SELECT	@wk_codA_count = 0
SELECT	@wk_codB_count = 0
SELECT	@wk_codC_count = 0
SELECT	@wk_appt_count = 0
SELECT	@wk_apptA_count = 0
SELECT	@wk_apptB_count = 0

CREATE TABLE #tmp_stat_pushcall
(
kc_emp_code	varchar(6),
kc_area_code 	varchar(2),
kc_emp_name varchar(10),
kc_case_count	int,
kc_sms_count	int,
kc_codA_count	int,
kc_codB_count	int,
kc_codC_count	int,
kc_appt_count	int,
kc_apptA_count	int,
kc_apptB_count	int
)
DECLARE	cursor_pusher	CURSOR
FOR	SELECT	DISTINCT e.EmpCode
	FROM	kcsd.v_Employee e
	WHERE	e.JobType = 'L'
	AND e.IsEnable = 1
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
	AND	p.kc_updt_user = e.UserCode
	AND	p.kc_push_note NOT LIKE '[系統]%'
	AND	p.kc_push_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND Not EXISTS (SELECT 'x'
		FROM kcsd.kc_sms s
		WHERE 
		s.kc_case_no = p.kc_case_no AND
		s.kc_msg_date = p.kc_push_date AND
		s.kc_msg_body = p.kc_push_note)
	GROUP BY p.kc_case_no, kc_push_date
	) AS S 

	--簡訊數
	SELECT	@wk_sms_count = isnull(count(s.kc_msg_id),0)
	FROM	kcsd.kc_sms s, kcsd.v_Employee e, kcsd.kc_push p
	WHERE	e.EmpCode = @wk_pusher_code
	AND	p.kc_updt_user = e.UserCode
	AND s.kc_push_link = p.kc_push_link
	AND s.kc_case_no = p.kc_case_no
	AND	s.kc_msg_date BETWEEN @pm_strt_date AND @pm_stop_date

	--約收數
	SELECT	@wk_appt_count = isnull(count(a.kc_case_no),0)
	FROM	kcsd.kc_apptschedule a, kcsd.v_Employee e
	WHERE	e.EmpCode = @wk_pusher_code
	AND	a.kc_updt_user = e.UserCode
	AND	a.kc_appt_date BETWEEN @pm_strt_date AND @pm_stop_date

	--LAW_CODE數
	SELECT 	@wk_codA_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='F'  THEN isnull(slaw.cnt,0) ELSE 0 END),0),	
			@wk_codB_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='C' and (kc_law_fmt='CA' or kc_law_fmt='CC' or kc_law_fmt='CJ' or kc_law_fmt='CI' or kc_law_fmt='CL') THEN isnull(slaw.cnt,0) ELSE 0 END),0),
			@wk_codC_count = isnull(sum(CASE WHEN  slaw.kc_law_code ='C' and kc_law_fmt='C8' THEN isnull(slaw.cnt,0) ELSE 0 END),0)
	FROM 
	(
		SELECT kc_law_code,kc_law_fmt,
		sum(CASE WHEN kc_curr_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_bill_flag = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_curr_flag1 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag1 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag1 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_curr_flag2 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_perm_flag2 = 'Y' THEN 1 ELSE 0 END)+
		sum(CASE WHEN kc_comp_flag2 = 'Y' THEN 1 ELSE 0 END) AS cnt
		FROM 
			(
				SELECT l.*
				FROM kcsd.kc_lawstatus l
				INNER JOIN kcsd.kc_pushassign p ON l.kc_case_no = p.kc_case_no
				INNER JOIN kcsd.Delegate d ON d.DelegateCode = p.kc_pusher_code
				WHERE l.kc_law_date BETWEEN @pm_strt_date and @pm_stop_date
				AND ((l.kc_law_date >= p.kc_strt_date AND l.kc_law_date <= ISNULL(p.kc_stop_date,GETDATE())) OR (l.kc_law_date BETWEEN p.kc_strt_date AND p.kc_stop_date))
				AND d.DelegateUser =  @wk_pusher_code
			) AS law
		GROUP BY kc_law_code,kc_law_fmt
	)AS slaw

    --約收 派訪人數
	SELECT @wk_apptA_count = isnull(sum(CASE WHEN kc_appt_type = 'A' THEN 1 ELSE 0 END), 0),
		   @wk_apptB_count = isnull(sum(CASE WHEN kc_appt_type = 'B' THEN 1 ELSE 0 END), 0)
	FROM kcsd.kc_apptschedule
	WHERE kc_appt_date BETWEEN @pm_strt_date AND @pm_stop_date
	AND kc_pusher_code = @wk_pusher_code
	
	SELECT @wk_area_code = AreaCode,@wk_emp_name = e.EmpName FROM kcsd.v_Employee e WHERE EmpCode = @wk_pusher_code
	INSERT	#tmp_stat_pushcall
		VALUES (@wk_pusher_code,@wk_area_code,@wk_emp_name,@wk_case_count, @wk_sms_count ,@wk_codA_count,@wk_codB_count,@wk_codC_count,@wk_appt_count,@wk_apptA_count,@wk_apptB_count)	
	FETCH NEXT FROM cursor_pusher INTO @wk_pusher_code
END

DEALLOCATE	cursor_pusher

SELECT	*
FROM	#tmp_stat_pushcall
ORDER BY kc_area_code,kc_emp_code

DROP TABLE #tmp_stat_pushcall
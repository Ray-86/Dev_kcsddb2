-- ==========================================================================================
-- 
-- ==========================================================================================

CREATE    PROCEDURE [kcsd].[p_kc_stat_court]
	@pm_strt_date datetime=NULL, @pm_stop_date DATETIME=NULL
AS
DECLARE	@wk_user_name	varchar(20),
	@wk_emp_name	nvarchar(10),
	@wk_cc0_count	int,
	@wk_cx2_count	int,
	@wk_cc4_count	int,
	@wk_exe_count	int,
	@wk_ga7_count	int,
	@wk_cc8_count	int,
	@wk_tra_count	int,
	@wk_rec_count	int,
	@wk_deb_count	int

SELECT	@wk_user_name = NULL
SELECT  @wk_cc0_count = 0
SELECT  @wk_cx2_count = 0
SELECT  @wk_cc4_count = 0
SELECT  @wk_exe_count = 0
SELECT  @wk_ga7_count = 0
SELECT  @wk_cc8_count = 0
SELECT  @wk_tra_count = 0
SELECT  @wk_rec_count = 0
SELECT  @wk_deb_count = 0

CREATE TABLE #tmp_stat_pushcall
(
kc_user_name	varchar(20),
kc_emp_name		nvarchar(10),
kc_cc0_count	int,
kc_cx2_count	int,
kc_cc4_count	int,
kc_exe_count	int,
kc_ga7_count	int,
kc_cc8_count	int,
kc_tra_count	int,
kc_rec_count	int,
kc_deb_count	int
)

DECLARE	cursor_pusher	CURSOR
FOR	SELECT	DISTINCT e.UserCode
	FROM	kcsd.v_Employee e
	WHERE	e.JobType = 'B'
	AND IsEnable = 1

OPEN cursor_pusher
FETCH NEXT FROM cursor_pusher INTO @wk_user_name

WHILE (@@FETCH_STATUS = 0)
BEGIN

	/* 本裁CC0 */
	SELECT	@wk_cc0_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'C' AND l.kc_law_fmt = 'C0'

	/* 裁定CX2 */
	SELECT	@wk_cx2_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'C' AND l.kc_law_fmt = 'X2'

	/* 確證CC4 */
	SELECT	@wk_cc4_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'C' AND l.kc_law_fmt = 'C4'

	/* 執行 */
	SELECT	@wk_exe_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'C' AND l.kc_law_fmt in ('C5', 'CA', 'CB', 'CC', 'CD', 'CE', 'CJ', 'CL', 'CP', 'CN', 'CQ', 'CR', 'CS', 'CT', 'CV')

	/* 所清GA7 */
	SELECT	@wk_ga7_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'G' AND l.kc_law_fmt = 'A7'

	/* 法扣CC8 */
	SELECT	@wk_cc8_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'C' AND l.kc_law_fmt = 'C8'

	/* 戶謄 */
	SELECT	@wk_tra_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND ((l.kc_law_code = 'E' AND l.kc_law_fmt in ('A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A9', 'A0')) OR l.kc_law_code = 'H')

	/* 收文 */
	SELECT	@wk_rec_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND l.kc_law_code = 'A'

	/* 債證 */
	SELECT	@wk_deb_count = count(l.kc_updt_user)
	FROM	kcsd.kc_lawstatus l
	WHERE	convert(varchar, l.kc_updt_date, 23) BETWEEN @pm_strt_date AND @pm_stop_date
	AND l.kc_updt_user = @wk_user_name
	AND ((l.kc_law_code = 'X' AND l.kc_law_fmt in ('XA', 'C6')) OR (l.kc_law_code = 'C' AND l.kc_law_fmt in ('XA', 'C6')))

	/* 其他資料 */
	SELECT @wk_emp_name = EmpName FROM kcsd.v_Employee e WHERE UserCode = @wk_user_name

	INSERT	#tmp_stat_pushcall
	VALUES (@wk_user_name, @wk_emp_name, @wk_cc0_count, @wk_cx2_count, @wk_cc4_count, @wk_exe_count, @wk_ga7_count, @wk_cc8_count,
			@wk_tra_count, @wk_rec_count, @wk_deb_count)	

	FETCH NEXT FROM cursor_pusher INTO @wk_user_name
END

DEALLOCATE	cursor_pusher

SELECT	*
FROM	#tmp_stat_pushcall

DROP TABLE #tmp_stat_pushcall

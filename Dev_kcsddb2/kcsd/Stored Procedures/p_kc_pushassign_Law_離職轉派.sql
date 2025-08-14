
-- ==========================================================================================
-- 2018-04-10 ('C1','C2','C3')派一次、('B3')派一次、剩下的派一次
-- ==========================================================================================

CREATE                PROCEDURE [kcsd].[p_kc_pushassign_Law_離職轉派] @pm_run_code VARCHAR(20) = NULL, @pm_age_date DATETIME = NULL
AS
DECLARE	
	@wk_case_no			VARCHAR(10),
	@wk_lawyer_code		VARCHAR(6),		-- 新催款人
	@wk_pusher_code		VARCHAR(6),		-- 原催款人
	@wk_circle_count	INT,			-- 目前輪到人員
	@wk_circle_limit	INT,			-- 共多少法務輪流
	@wk_area_code		VARCHAR(2),		-- 公司別
	@wk_strt_date		DATETIME,		-- 委派日
	@wk_stop_date		DATETIME,		-- 回收日
	@wk_over_amt		INT,			/* 逾期金額 */
	@wk_arec_amt		INT,			/* 未繳金額 */
	@wk_break_amt		INT 			/* 違約金 */

CREATE TABLE #tmp_pushassign_LtoL
(
	kc_case_no			VARCHAR(10),
	kc_pusher_code		VARCHAR(6),		-- 原催款人
	kc_lawyer_code		VARCHAR(6),		-- 新催款人
	kc_stop_date		DATETIME,
	kc_strt_date		DATETIME,
	kc_pusher_type		VARCHAR(10)
)

-- 預設為LA
SELECT	@wk_case_no=NULL, @wk_lawyer_code = 'LA',@wk_circle_count = 1
-- 本月第一天
SELECT	@wk_strt_date = '2020-05-01'
-- 執行前一天
SELECT	@wk_stop_date = '2020-04-30'
--取得總共委派個數
SELECT @wk_circle_limit = COUNT(*) FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 
 
DECLARE	cursor_case_no_LtoL CURSOR LOCAL STATIC FORWARD_ONLY STATIC
FOR	

SELECT kc_case_no
		FROM kcsd.kc_customerloan
		WHERE kc_pusher_code = 'L01'
		--and kc_push_sort in ('C1','C2','C3')
		--WHERE kc_pusher_code = 'L04' and kc_push_sort in ('B3')
		--WHERE kc_pusher_code = 'L04'
		ORDER By NEWID() DESC

OPEN cursor_case_no_LtoL
FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_over_amt = 0, @wk_arec_amt = 0,	@wk_pusher_code = NULL, @wk_break_amt = 0

	--取得基本資料
	SELECT	@wk_pusher_code = kc_pusher_code , @wk_area_code = kc_area_code
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no
	
	--取得委派人員
	SELECT @wk_lawyer_code = DelegateCode FROM ( 
		SELECT ROW_NUMBER() OVER (ORDER BY DelegateCode) AS RowId, * FROM kcsd.Delegate WHERE DelegateCode LIKE 'L%' AND IsEnable = 1 
	) AS A WHERE A.RowId = @wk_circle_count
	SELECT @wk_circle_count = @wk_circle_count + 1

	IF @wk_circle_count > @wk_circle_limit
	BEGIN
		SELECT @wk_circle_count = 1
	END

	INSERT	#tmp_pushassign_LtoL
		(kc_case_no, kc_pusher_code, kc_lawyer_code, kc_stop_date ,kc_strt_date,kc_pusher_type)
	VALUES	
		(@wk_case_no,@wk_pusher_code, @wk_lawyer_code, @wk_stop_date, @wk_strt_date,'轉法務')

	IF	@pm_run_code = 'EXECUTE'
	BEGIN
		-- 結束原來指派
		UPDATE	kcsd.kc_pushassign
		SET	kc_stop_date = @wk_stop_date
		WHERE	kc_case_no = @wk_case_no
		AND	kc_stop_date IS NULL

		--新增法務指派
		INSERT	kcsd.kc_pushassign
			(kc_case_no, kc_strt_date, kc_pusher_code, kc_delay_code,kc_pusher_amt, kc_break_amt, kc_updt_user, kc_updt_date, kc_area_code)
		VALUES	
			(@wk_case_no, @wk_strt_date, @wk_lawyer_code, 'MX',@wk_over_amt, @wk_break_amt, USER, @wk_strt_date, @wk_area_code)

		UPDATE	kcsd.kc_customerloan
		SET	kc_pusher_code = @wk_lawyer_code, kc_pusher_date = @wk_strt_date, kc_delay_code = 'MX'
		WHERE	kc_case_no = @wk_case_no
	END
		
	FETCH NEXT FROM cursor_case_no_LtoL INTO @wk_case_no
END
CLOSE cursor_case_no_LtoL
DEALLOCATE cursor_case_no_LtoL

SELECT * FROM #tmp_pushassign_LtoL
DROP TABLE #tmp_pushassign_LtoL

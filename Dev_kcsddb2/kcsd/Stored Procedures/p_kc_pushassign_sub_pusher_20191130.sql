-- ==========================================================================================
--2018-08-01 改派件寫法(可依公司別分比例派件)
--2018-08-01 新竹2/3件給台北
--2018		 屏東1/3件給台南
--2017-11-21 增加特殊委派條件第三方公司助催(該分公司得到其中一份 例如:原公司催收2人則分成3等分，原分公司得到2/3。該分公司得到1/3的案件。)
--2014/02/26 新增宜蘭派件
--02/09/2012 新竹高雄雲林屏東彰化 都改為平均
--01/20/2012 彰化全部指派 PA1
--07/10/2010 桃園也改為平均 P71, P72
--08/29/2009 桃園07派給P71
--08/23/2009 台南05東元機車件派給P55
--09/01/2008 高屏06改為全指派給P61
--01/05/2008 取消特殊處理1101
--01/05/2008 高屏06由台北催
--03/18/2006 KC: 台中也改為 P21, P22, P23
--11/26/2005 KC: 高屏也改為 P61, P62
--	指派優先順序:
--	順序1: 若曾指派給法務, 則優先指派到法務
--	順序2: 若有業務換區, 依業務業務換區的M0/M1處理
--	順序3: 依業務的M0/M1處理 */
-- ==========================================================================================
create PROCEDURE [kcsd].[p_kc_pushassign_sub_pusher_20191130] 
	@pm_pusher_code varchar(10) OUTPUT,
	@pm_case_no		varchar(10) = NULL,
	@pm_delay_code	varchar(4) = NULL,
	@pm_row_count	int = 0 OUTPUT,			--行數1
	@pm_row_count2	int = 0 OUTPUT,			--行數2
	@pm_row_cnt		int	= 0	OUTPUT			--總行數	
AS
DECLARE	
	@wk_area_code	varchar(4),
	@wk_row_count	int,
	@wk_row_count2	int,
	@wk_row_limit	int,
	@wk_row_limit2	int

CREATE TABLE #tmp_pusher
(
DelegateCode	varchar(10)
)
CREATE TABLE #tmp_pusher2
(
DelegateCode	varchar(10)
)

SELECT	@pm_pusher_code = NULL, @wk_area_code = NULL

IF	@pm_case_no IS NULL
OR	@pm_delay_code IS NULL
	RETURN

/* 取得基本資料 */
SELECT	@wk_area_code = kc_area_code
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

IF	@wk_area_code = '01'
BEGIN
		-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '01'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END
ELSE
IF	@wk_area_code = '02'	/* 台中 */
BEGIN
		/* 取得催收人員 */
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '02'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END
ELSE
IF	@wk_area_code = '03'	--新竹
BEGIN

	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '01'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0

	--IF (@pm_row_cnt%3) = 1 --1/3給新竹
	----IF (@pm_row_cnt%3) = 1 OR (@pm_row_cnt%3) = 2 --2/3給新竹
	--BEGIN
	--	/* 取得催收人員 */
	--	INSERT	#tmp_pusher
	--	SELECT	DelegateCode
	--	FROM	kcsd.Delegate
	--	WHERE	DelegateCode LIKE 'P%'
	--	AND	AreaCode = '03'
	--	AND	IsEnable = 1
	--	ORDER BY DelegateCode

	--	SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
	--	SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
	--	SELECT	@pm_row_count = @pm_row_count + 1

	--	SET ROWCOUNT @wk_row_count
	--	SELECT	@pm_pusher_code = DelegateCode
	--	FROM	#tmp_pusher
	--	ORDER BY DelegateCode
	--	SET ROWCOUNT 0
	--END
	--ELSE					--2/3給台北
	--BEGIN
	--	/* 取得催收人員 */
	--	INSERT	#tmp_pusher2
	--	SELECT	DelegateCode
	--	FROM	kcsd.Delegate
	--	WHERE	DelegateCode LIKE 'P%'
	--	AND	AreaCode = '01'
	--	AND	IsEnable = 1
	--	ORDER BY DelegateCode

	--	SELECT	@wk_row_limit2 = COUNT(*) FROM	#tmp_pusher2
	--	SELECT	@wk_row_count2 = (@pm_row_count2 % @wk_row_limit2)+ 1
	--	SELECT	@pm_row_count2 = @pm_row_count2 + 1

	--	SET ROWCOUNT @wk_row_count2
	--	SELECT	@pm_pusher_code = DelegateCode
	--	FROM	#tmp_pusher2
	--	ORDER BY DelegateCode
	--	SET ROWCOUNT 0
	--		print @pm_pusher_code
	--END

END

ELSE
IF	@wk_area_code = '05'	-- 台南
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '05'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '06'	--高雄
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '06'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0

		/*
		IF (@pm_row_cnt%3) = 1 OR (@pm_row_cnt%3) = 2 --2/3給高雄
	BEGIN
		/* 取得催收人員 */
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '06'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
	END
	ELSE					--1/3給台南
	BEGIN
		/* 取得催收人員 */
		INSERT	#tmp_pusher2
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '05'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit2 = COUNT(*) FROM	#tmp_pusher2
		SELECT	@wk_row_count2 = (@pm_row_count2 % @wk_row_limit2)+ 1
		SELECT	@pm_row_count2 = @pm_row_count2 + 1

		SET ROWCOUNT @wk_row_count2
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher2
		ORDER BY DelegateCode
		SET ROWCOUNT 0
	END
		*/
END

ELSE
IF	@wk_area_code = '07'	--桃園
BEGIN
		-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '07'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '08'	--嘉義
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '05'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '09'	--屏東
BEGIN
	IF (@pm_row_cnt%3) = 1 OR (@pm_row_cnt%3) = 2 --2/3給屏東
	BEGIN
		/* 取得催收人員 */
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '09'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
	END
	ELSE					--1/3給台南
	BEGIN
		/* 取得催收人員 */
		INSERT	#tmp_pusher2
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '05'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit2 = COUNT(*) FROM	#tmp_pusher2
		SELECT	@wk_row_count2 = (@pm_row_count2 % @wk_row_limit2)+ 1
		SELECT	@pm_row_count2 = @pm_row_count2 + 1

		SET ROWCOUNT @wk_row_count2
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher2
		ORDER BY DelegateCode
		SET ROWCOUNT 0
	END
END

ELSE
IF	@wk_area_code = '10'	--彰化
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '02'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
			
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '11'	--宜蘭
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '02'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '12'	--南投
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '02'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '13'	--雲林
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '05'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '14'	--宜花
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '02'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
END

ELSE
IF	@wk_area_code = '15'	--苗栗
BEGIN
	-- 取得催收人員
		INSERT	#tmp_pusher
		SELECT	DelegateCode
		FROM	kcsd.Delegate
		WHERE	DelegateCode LIKE 'P%'
		AND	AreaCode = '01'
		AND	IsEnable = 1
		ORDER BY DelegateCode

		SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
		SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+1
		SELECT	@pm_row_count = @pm_row_count + 1

		SET ROWCOUNT @wk_row_count
		SELECT	@pm_pusher_code = DelegateCode
		FROM	#tmp_pusher
		ORDER BY DelegateCode
		SET ROWCOUNT 0
END

SELECT @pm_row_cnt = @pm_row_cnt + 1
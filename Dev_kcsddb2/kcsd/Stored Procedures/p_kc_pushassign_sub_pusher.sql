-- ==========================================================================================
--2020-11-10 特約件抓C開頭的催收，且不等10日就開始抓
--2019-12-01 改為全公司案件派全部催收
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
CREATE PROCEDURE [kcsd].[p_kc_pushassign_sub_pusher] 
	@pm_pusher_code varchar(20) OUTPUT,
	@pm_case_no		varchar(10) = NULL,
	@pm_delay_code	varchar(4) = NULL,
	@pm_row_count	int = 0 OUTPUT,		--行數1
	@pm_row_cnt		int	= 0	OUTPUT,		--總行數	
	@pm_pusher_type varchar(2) = NULL
AS
DECLARE	
	@wk_row_count	int,
	@wk_row_limit	int

CREATE TABLE #tmp_pusher
(
DelegateCode	varchar(10)
)

SELECT	@pm_pusher_code = NULL

IF	@pm_case_no IS NULL OR	@pm_delay_code IS NULL  OR	@pm_pusher_type IS NULL
	RETURN


IF @pm_pusher_type = 'P'
BEGIN
-- 取得催收人員
INSERT #tmp_pusher SELECT DelegateCode FROM kcsd.Delegate WHERE	DelegateCode LIKE 'P%' AND IsEnable = 1 and kc_delay_code = @pm_delay_code ORDER BY DelegateCode
END
ELSE IF @pm_pusher_type = 'P2'
BEGIN
-- 取得移工催收人員
INSERT #tmp_pusher SELECT DelegateCode FROM kcsd.Delegate WHERE	DelegateCode LIKE 'P%' AND IsEnable2 = 1 ORDER BY DelegateCode
END
--會員催收人員
ELSE IF @pm_pusher_type = 'MB'
BEGIN
-- 取得催收人員
INSERT #tmp_pusher SELECT DelegateCode FROM kcsd.Delegate WHERE	DelegateCode LIKE 'P%' AND IsEnable3 = 1 and kc_delay_code = @pm_delay_code ORDER BY DelegateCode
END
ELSE IF @pm_pusher_type = 'T'
BEGIN
-- 取得催收人員
INSERT #tmp_pusher SELECT DelegateCode FROM kcsd.Delegate WHERE	DelegateCode LIKE 'T%' AND IsEnable = 1 ORDER BY DelegateCode
END


ELSE
--特約特別催收
BEGIN
-- 取得催收人員
INSERT #tmp_pusher SELECT DelegateCode FROM kcsd.Delegate WHERE	DelegateCode LIKE 'C%' AND IsEnable = 1 ORDER BY DelegateCode
END


SELECT	@wk_row_limit = COUNT(*) FROM	#tmp_pusher
SELECT	@wk_row_count = (@pm_row_count % @wk_row_limit)+ 1
SELECT	@pm_row_count = @pm_row_count + 1

SET ROWCOUNT @wk_row_count

print ('@wk_row_count' + CONVERT(varchar(100),@wk_row_count) )
SELECT	@pm_pusher_code = DelegateCode FROM	#tmp_pusher ORDER BY DelegateCode

SET ROWCOUNT 0

SELECT @pm_row_cnt = @pm_row_cnt + 1
print ('@pm_row_cnt' + CONVERT(varchar(100),@pm_row_cnt) )

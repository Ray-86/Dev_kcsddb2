-- ==========================================================================================
-- 09/15/07 KC: 法務客戶分析表
-- ==========================================================================================
CREATE   PROCEDURE [kcsd].[p_kc_stat_lawcustomer]
AS
DECLARE	@wk_case_no		varchar(10),
	@wk_age_year		float,
	@wk_age_perd		int,
	@wk_male_count		int,
	@wk_female_count	int,
	@wk_single_count	int,
	@wk_married_count	int,
	@wk_mate_name		varchar(20),
	@wk_sex			varchar(1),

	@wk_over_amt		int,
	@wk_rema_amt		int,
	@wk_pay_sum		int,
	@wk_loan_amt		int,

	@wk_count		int,
	@wk_age_desc		varchar(40)

CREATE TABLE #tmp_statlaw
(kc_age_perd		int,
kc_age_desc		varchar(20),
kc_male_count		int,
kc_female_count		int,
kc_single_count		int,
kc_married_count	int,
kc_rema_amt		int,
kc_pay_sum		int,
kc_over_amt		int,
kc_loan_amt		int
)

SELECT	@wk_count = 3, @wk_case_no=NULL

-- =============================================
-- Init Result Table
WHILE @wk_count <= 12
BEGIN
	SELECT	@wk_age_desc = CONVERT(varchar(10), 5*@wk_count+1 ) + '～'
		+ CONVERT(varchar(10) , 5*(@wk_count+1)) + '歲'	

	INSERT	#tmp_statlaw
		(kc_age_perd, kc_age_desc,
		kc_male_count, kc_female_count, kc_single_count, kc_married_count,
		kc_rema_amt, kc_pay_sum , kc_over_amt, kc_loan_amt)
	VALUES	(@wk_count, @wk_age_desc,
		0, 0, 0, 0, 0, 0, 0, 0) 

	SELECT	@wk_count = @wk_count + 1
END 

UPDATE	#tmp_statlaw
SET	kc_age_desc = '20歲以下'
WHERE	kc_age_perd = 3

UPDATE	#tmp_statlaw
SET	kc_age_desc = '20～25歲'
WHERE	kc_age_perd = 4

UPDATE	#tmp_statlaw
SET	kc_age_desc = '61歲以上'
WHERE	kc_age_perd = 12
-- =============================================


DECLARE	cursor_statlawcustomer	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	--WHERE	kc_pusher_code LIKE 'LA%'
	WHERE	kc_pusher_code LIKE 'L%'

OPEN cursor_statlawcustomer
FETCH NEXT FROM cursor_statlawcustomer INTO @wk_case_no

SELECT	@wk_male_count=0, @wk_female_count=0,
	@wk_single_count=0, @wk_married_count=0


WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT	@wk_mate_name = NULL, @wk_sex=NULL,
		@wk_male_count=0, @wk_female_count=0,
		@wk_single_count=0, @wk_married_count=0

	SELECT	@wk_age_year = DATEDIFF(day, kc_birth_date, kc_buy_date)/365.0,
		@wk_sex = SUBSTRING(kc_id_no, 2, 1),
		@wk_mate_name = kc_mate_name,
		@wk_over_amt = kc_over_amt,
		@wk_rema_amt = kc_rema_amt,
		@wk_loan_amt  = kc_perd_fee * kc_loan_perd
	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	-- Age


	-- 性別
	IF	@wk_sex = '2'
		SELECT	@wk_female_count = 1
	ELSE
		SELECT	@wk_male_count = 1
	-- 婚姻
	IF	@wk_mate_name IS NOT NULL
		SELECT	@wk_married_count = 1
	ELSE	
		SELECT	@wk_single_count = 1

	SELECT	@wk_pay_sum = SUM( ISNULL(kc_pay_fee, 0) )
	FROM	kcsd.kc_loanpayment
	WHERE	kc_case_no = @wk_case_no

	IF	@wk_age_year >= 20
	AND	@wk_age_year < 26
		SELECT	@wk_age_perd = 4
	ELSE
	IF	@wk_age_year < 20
		SELECT	@wk_age_perd = 3
	ELSE
	IF	@wk_age_year >=61
		SELECT	@wk_age_perd = 12
	ELSE
		SELECT	@wk_age_perd = @wk_age_year / 5


	UPDATE	#tmp_statlaw
	SET	kc_male_count = kc_male_count + @wk_male_count,
		kc_female_count = kc_female_count + @wk_female_count,
		kc_single_count = kc_single_count + @wk_single_count,
		kc_married_count = kc_married_count + @wk_married_count,
		kc_rema_amt = kc_rema_amt + ISNULL(@wk_rema_amt,0),
		kc_pay_sum = kc_pay_sum + ISNULL(@wk_pay_sum,0) ,
		kc_over_amt = kc_over_amt + ISNULL(@wk_over_amt,0),
		kc_loan_amt = kc_loan_amt + ISNULL(@wk_loan_amt,0)
	WHERE	kc_age_perd = @wk_age_perd

	FETCH NEXT FROM cursor_statlawcustomer INTO @wk_case_no
END

DEALLOCATE	cursor_statlawcustomer

SELECT	*
FROM	#tmp_statlaw

--SELECT	SUM(kc_male_count), SUM(kc_female_count), SUM(kc_single_count), SUM(kc_married_count)
--FROM	#tmp_statlaw

DROP TABLE #tmp_statlaw

-- ==========================================================================================
-- 2019/04/15 逾期委派自動新增至催繳紀錄並發簡訊(15天內只發一次)
-- 2014/03/19 當日逾期委派自動新增至催繳紀錄並發簡訊
-- ==========================================================================================
CREATE	PROCEDURE [kcsd].[p_kc_autosms_pushassign]
AS
DECLARE  
	@flag	int,
	@i	int,
	@wk_case_no AS VARCHAR(10),
	@wk_pusher_code AS VARCHAR(10),
	@wk_cust_nameu AS NVARCHAR(60),
	@wk_mobil_no AS VARCHAR(12),
	@wk_push_link	VARCHAR(10),
	@wk_area_code as varchar(2),
	@wk_sms_msg		VARCHAR(300),
	@wk_sms_no		INT,
	@wk_push_no		INT,
	@wk_push_date	DATETIME,
	@wk_brand_code as varchar(2)

SELECT @wk_sms_no = 0, @wk_push_no = 0, @wk_push_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

DECLARE cursor1 CURSOR FOR
-- 20210218 簡訊條件變更
/*
SELECT	c.kc_case_no,c.kc_area_code,c.kc_mobil_no,c.kc_brand_code
	FROM	kcsd.kc_customerloan c
	WHERE	kc_loan_stat IN ('D','F')
	AND NOT EXISTS
		(SELECT	'X' 
		FROM kcsd.kc_pushassign p
		WHERE p.kc_case_no = c.kc_case_no
		AND	p.kc_stop_date IS NULL)
	AND NOT EXISTS
		(SELECT	'X' 
		FROM kcsd.kc_push p
		WHERE p.kc_case_no = c.kc_case_no
		AND kc_push_note like '%提醒:您的款項尚未入帳%'
		AND datediff(day,kc_push_date,GETDATE()) < 15)
	AND datediff(day,(SELECT DATEADD(day, -2, MAX(kc_pay_date)) as kc_pay_date FROM kcsd.kc_loanpayment WHERE kc_pay_type = '7' AND kc_pay_date < GETDATE()),kc_dday_date) < 0
	AND c.kc_pusher_code is null
	and c.kc_case_no = '2011370'

ORDER BY c.kc_case_no*/

SELECT	c.kc_case_no,c.kc_area_code,c.kc_mobil_no,c.kc_brand_code
	FROM	kcsd.kc_customerloan c
	left join (select kc_case_no, Min(kc_expt_date) AS kc_min_exptdate from kcsd.kc_loanpayment  where kc_pay_date is null  group by kc_case_no)l on c.kc_case_no = l.kc_case_no
	WHERE	kc_loan_stat IN ('G','D','F')
	AND NOT EXISTS
		(SELECT	'X' 
		FROM kcsd.kc_pushassign p
		WHERE p.kc_case_no = c.kc_case_no
		AND	p.kc_stop_date IS NULL)
	AND   FORMAT( l.kc_min_exptdate, 'yyyyMMdd') = FORMAT( GETDATE(), 'yyyyMMdd')
	AND c.kc_pusher_code is null
ORDER BY c.kc_case_no

OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_case_no,@wk_area_code,@wk_mobil_no,@wk_brand_code

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @wk_mobil_no is not null and len(@wk_mobil_no) = 10
	BEGIN
		SET @i = 1
		WHILE  LEN(@wk_mobil_no) >= @i
		BEGIN
			DECLARE @ChcekValue int 
		
			SELECT  @ChcekValue =  ASCII(SUBSTRING(@wk_mobil_no,@i,1))
			IF(@ChcekValue > 47 AND @ChcekValue < 58 )
			BEGIN		
				SET @flag = 0	-- 數字
		     	END
			ELSE
			BEGIN
				SET @flag = 1	-- 非數字
				BREAK 
			END
			SET @i = @i +1
		END

		IF @wk_brand_code = '02'
		BEGIN
			SET @wk_sms_msg = 'BoBoPay提醒:您的分期款今日到期，請立即繳款，逾期將加計違約金，如已繳款請不需理會，謝謝。'
		END
		ELSE
		BEGIN
			SET @wk_sms_msg = '東元分期提醒:您的分期款今日到期，請立即繳款，逾期將加計違約金，如已繳款請不需理會，謝謝。'
		END
		IF @flag = 0
		BEGIN
			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_link = '0000' + @wk_sms_no
			--催繳
			INSERT INTO kc_push (kc_case_no, kc_item_no, kc_area_code, kc_push_date, kc_push_note, kc_updt_date, kc_updt_user, kc_sms_no, kc_push_link) 
			VALUES (@wk_case_no, @wk_push_no, @wk_area_code, @wk_push_date, @wk_sms_msg, GETDATE(), USER, @wk_sms_no, @wk_push_link)
			--簡訊
			INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link) 
			VALUES (@wk_case_no, @wk_sms_no, @wk_push_date, @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link)
		END
	END
FETCH NEXT FROM cursor1  INTO @wk_case_no,@wk_area_code,@wk_mobil_no,@wk_brand_code
end
CLOSE cursor1
DEALLOCATE cursor1

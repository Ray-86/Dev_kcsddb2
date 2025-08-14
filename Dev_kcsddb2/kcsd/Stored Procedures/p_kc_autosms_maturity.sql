-- ==========================================================================================
-- 20160107 新增強制險有收款日期及合計有餘額案件排除簡訊
-- 20150825 取消7天前傳送，調整簡訊字樣
-- 2014/03/13 強制險到期自動新增至催繳紀錄並發簡訊
-- ==========================================================================================
CREATE          PROCEDURE [kcsd].[p_kc_autosms_maturity]
AS
DECLARE
	@flag	int,
	@i	int,  
	@wk_case_no AS VARCHAR(10),
	@wk_licn_no AS VARCHAR(10),
	@wk_cust_nameu AS NVARCHAR(60),
	@wk_maturity_date AS DATETIME,
	@wk_mobil_no AS VARCHAR(12),
	@wk_item_no AS smallint,
	@wk_push_note AS VARCHAR(150),
	@wk_area_code as varchar(2)

DECLARE cursor1 CURSOR FOR

SELECT  cu.kc_case_no,cu.kc_area_code, cu.kc_licn_no, cu.kc_cust_nameu, cu.kc_maturity_date,kc_mobil_no
FROM kcsd.kc_customerloan cu
WHERE 
cu.kc_issu_code NOT IN ('01') AND
cu.kc_loan_stat NOT IN ('C','E') AND
cu.kc_maturity_date = CONVERT(varchar(10), DATEADD(day, 30,GETDATE()), 23) AND

not EXISTS (SELECT DISTINCT 'X' 
		FROM kcsd.kc_customerloan c ,
		(SELECT kc_case_no , kc_coll_type ,SUM(isnull(kc_coll_fee,0) - isnull(kc_pay_fee,0)) AS kc_sum_fee
			FROM kcsd.kc_feescoll
			WHERE kc_coll_type = 'A' AND kc_coll_date IS NOT NULL
			GROUP BY kc_case_no,kc_coll_type) l  
		WHERE 
		c.kc_case_no = l.kc_case_no AND
		l.kc_sum_fee > 0 AND
		cu.kc_case_no = c.kc_case_no
)AND
not EXISTS (SELECT DISTINCT 'X'  
		FROM kcsd.kc_customerloan c ,kcsd.KC_LOANPAYMENT l  
		WHERE 
		c.kc_case_no = l.kc_case_no AND
		l.KC_RECE_CODE = 'A2' AND
		cu.kc_case_no = c.kc_case_no
)AND
not EXISTS (SELECT DISTINCT  'X' 
		FROM kcsd.kc_customerloan c ,kcsd.kc_carstatus l  
		WHERE 
		c.kc_case_no = l.kc_case_no AND
		l.kc_car_stat IN ('A','E','F')  AND
		cu.kc_case_no = c.kc_case_no
)
AND
not EXISTS (SELECT DISTINCT  'X' 
		FROM kcsd.kc_customerloan c ,kcsd.kc_appraiseh a 
		WHERE 
		c.kc_case_no = a.kc_case_no AND
		kc_appraise_stat = '50' AND
		cu.kc_case_no = c.kc_case_no
)
ORDER BY cu.kc_case_no

OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_case_no,@wk_area_code,@wk_licn_no,@wk_cust_nameu,@wk_maturity_date,@wk_mobil_no
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

		IF @flag = 0
		BEGIN
--			SELECT @wk_push_note = @wk_cust_nameu+'您好:通知您車牌'+@wk_licn_no+'強制險於'+convert(varchar(10), @wk_maturity_date,101)+'到期，請至保險公司續保，以免受罰。02-2226-8886 東元' 
			SELECT @wk_push_note = '東元通知:牌號'+@wk_licn_no+'強制險將到期，請於通知後15日內續保，逾期則由本公司代辦，費用納入未繳餘額收取。02-22268886 東元' 
			SELECT @wk_item_no = isnull(max(kc_item_no),0)+1 from kcsd.kc_push WHERE kc_case_no = @wk_case_no
			--新增至催繳紀錄
			INSERT kcsd.kc_push (kc_case_no,kc_area_code, kc_push_date, kc_push_note,kc_item_no, kc_effe_flag,kc_sms_flag,kc_updt_user,kc_updt_date) VALUES (@wk_case_no,@wk_area_code, CONVERT(varchar(10), GETDATE(), 101),@wk_push_note,@wk_item_no,0,0,USER,GETDATE())
			--新增至簡訊 
			INSERT INTO kcsd.kc_sms (kc_case_no, kc_msg_date, kc_mobil_no, kc_msg_body) VALUES (@wk_case_no,CONVERT(varchar(10), GETDATE(), 101),@wk_mobil_no,@wk_push_note)
		END
	END

FETCH NEXT FROM cursor1  INTO @wk_case_no,@wk_area_code,@wk_licn_no,@wk_cust_nameu,@wk_maturity_date,@wk_mobil_no
end
CLOSE cursor1
DEALLOCATE cursor1

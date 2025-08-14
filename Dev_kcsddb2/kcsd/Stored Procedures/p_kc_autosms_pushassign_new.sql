-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_autosms_pushassign_new]
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
	@wk_brand_code as varchar(2),
	@wk_prod_type as varchar(2),
	@wk_smscomp_type		VARCHAR(4),
	@wk_cp_no AS VARCHAR(10),

	@wk_daytarget		INT,
	@wk_call_type		varchar(2)


SELECT @wk_sms_no = 0, @wk_push_no = 0, @wk_push_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

DECLARE cursor1 CURSOR FOR

select * from(
  
SELECT	c.kc_case_no,c.kc_area_code,c.kc_mobil_no,c.kc_brand_code,c.kc_prod_type,c.kc_cp_no,DATEDIFF(d, FORMAT( l.kc_min_exptdate, 'yyyyMMdd'),FORMAT(GETDATE() , 'yyyyMMdd')) as daytarget
	FROM	kcsd.kc_customerloan c
	left join (select kc_case_no, Min(kc_expt_date) AS kc_min_exptdate from kcsd.kc_loanpayment  where kc_pay_date is null  group by kc_case_no)l on c.kc_case_no = l.kc_case_no
	where 	 c.kc_loan_stat not in ('C','X','Y','Z')
		and kc_prod_type <> '14'

) as xx where  (kc_brand_code = 03 and daytarget = -2) or (kc_brand_code <> 03 and  (daytarget = 1 or  daytarget = 8 or  daytarget = 10 or daytarget = 17 or daytarget = 23))  

ORDER BY kc_case_no

OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_case_no,@wk_area_code,@wk_mobil_no,@wk_brand_code,@wk_prod_type,@wk_cp_no,@wk_daytarget

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

		IF @wk_daytarget = -2
		BEGIN
			SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1013'
		END

		ELSE IF @wk_daytarget = 1
		BEGIN
			SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1029'
		END

		ELSE IF @wk_daytarget = 8
		BEGIN

	    	select @wk_call_type = 0
			select @wk_call_type = kc_call_type ,@wk_sms_msg = kc_call_memo from kcsd.kc_autocalllist where kc_brand_code = @wk_brand_code and  kc_prod_type = @wk_prod_type
			
			INSERT INTO kc_autocall (kc_call_type, kc_call_date, kc_case_no,kc_mobile_no)
						VALUES (@wk_call_type, GETDATE(), @wk_case_no,@wk_mobil_no);
		END

		ELSE IF @wk_daytarget = 10
		BEGIN
			SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1030'
		END
		ELSE IF @wk_daytarget = 17
		BEGIN
			SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1031'
		END
		ELSE IF @wk_daytarget = 23
		BEGIN
			SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1032'
		END

	
		    EXECUTE [kcsd].[p_kc_sms_replace] @wk_sms_msg OUTPUT, @wk_cp_no  

			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_link = '0000' + @wk_sms_no
			--催繳
			INSERT INTO kc_push (kc_case_no, kc_item_no, kc_area_code, kc_push_date, kc_push_note, kc_updt_date, kc_updt_user, kc_sms_no, kc_push_link) 
			VALUES (@wk_case_no, @wk_push_no, @wk_area_code, @wk_push_date, @wk_sms_msg, GETDATE(), USER, @wk_sms_no, @wk_push_link)

			--簡訊
			IF @wk_daytarget <> 8 
			BEGIN
			INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link,kc_smscomp_type) 
			VALUES (@wk_case_no, @wk_sms_no, @wk_push_date, @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link,@wk_smscomp_type)

			END

		END
	END
FETCH NEXT FROM cursor1  INTO @wk_case_no,@wk_area_code,@wk_mobil_no,@wk_brand_code,@wk_prod_type,@wk_cp_no,@wk_daytarget
end
CLOSE cursor1
DEALLOCATE cursor1

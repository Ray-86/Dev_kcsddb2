-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_autosms_createprodtype18] 

AS
DECLARE  

	@wk_case_no AS VARCHAR(10),
	@wk_brand_code AS VARCHAR(2),
	@wk_mobil_no AS VARCHAR(12),
	@wk_area_code	VARCHAR(2),
	@wk_push_no		INT,


	@wk_sms_link VARCHAR(50),
	@wk_sms_mobil AS VARCHAR(15),
	@wk_sms_brand AS VARCHAR(10),

	@wk_sms_msg		VARCHAR(300),

	@flag	int,
	@i	int,
	@wk_push_link	VARCHAR(10),
	@wk_sms_no		INT,

    @wk_push_date	DATETIME,
	@wk_smscomp_type		VARCHAR(4)


	SELECT  @wk_push_date = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

SELECT @wk_sms_no = 0

DECLARE cursor1 CURSOR FOR


			select cp.kc_cp_no,cp.kc_brand_code,cp.kc_mobil_no,cp.kc_area_code 

			from kcsd.kc_cpdata cp

			where kc_prod_type = '18' and kc_finish_flag = 'Y' 

     and GETDATE()  > DATEADD (mi , 20,kc_crdt_date)  





order by kc_crdt_date 


OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_case_no,@wk_brand_code,@wk_mobil_no,@wk_area_code
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

		SELECT @wk_sms_msg = kc_sms_desc,@wk_smscomp_type = kc_smscomp_type from kcsd.kct_smstemplate where kc_sms_type = 'S' and kc_sms_no = '1026'

		IF @flag = 0
		BEGIN
			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_link = '0000' + @wk_sms_no

			--簡訊
			INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link,kc_smscomp_type) 
			VALUES (@wk_case_no, @wk_sms_no, @wk_push_date, @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link,@wk_smscomp_type)
			
		    --照會紀錄
			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_creditmemo WHERE kc_cp_no = @wk_case_no
			INSERT INTO kc_creditmemo (kc_cp_no, kc_item_no, kc_credit_memo,kc_notice_user,kc_notice_date, CreatePerson, CreateDate) 
			VALUES (@wk_case_no, @wk_sms_no, '【BoBoPay】提醒您，您的訂單尚未完成下單步驟!請返回官網後重新下單，謝謝!','super', GETDATE(),  USER, GETDATE())
					
			--更新flag
			update kcsd.kc_cpdata set  kc_finish_flag = 'N',kc_apply_stat = 'N',kc_appv_user = 'super',kc_appv_date = GETDATE(),kc_cp_memo = '未進件完成'  where kc_cp_no = @wk_case_no
			--更新訂單
			update [bobocms].[dbo].[kc_merchanttrade] set  kc_trade_status = '3' where kc_cp_no = @wk_case_no





		END
	END
FETCH NEXT FROM cursor1  INTO @wk_case_no,@wk_brand_code,@wk_mobil_no,@wk_area_code
end
CLOSE cursor1
DEALLOCATE cursor1
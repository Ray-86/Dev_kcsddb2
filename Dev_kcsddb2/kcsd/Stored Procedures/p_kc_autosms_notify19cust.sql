-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_autosms_notify19cust]

AS
DECLARE  
	@wk_cp_no AS VARCHAR(10),
	--@wk_case_no AS VARCHAR(10),
	--@wk_brand_code AS VARCHAR(2),
	@wk_mobil_no AS VARCHAR(12),
		@wk_data_type AS VARCHAR(12),

	@wk_sms_link VARCHAR(50),
	@wk_sms_mobil AS VARCHAR(15),
	@wk_sms_brand AS VARCHAR(10),

	@wk_sms_msg		VARCHAR(300),

	@flag	int,
	@i	int,
	@wk_push_link	VARCHAR(10),
	@wk_sms_no		INT




SELECT @wk_sms_no = 0

DECLARE cursor1 CURSOR FOR


select kc_cp_no ,kc_mobil_no,
case when kc_cfm_date <= DATEADD(dd,-2,GETDATE()) then '2' else '1' end kc_data_type
from kcsd.kc_cpdata where kc_prod_type = '19' and kc_cfm_stat <= 'B' and kc_cfm_date <= DATEADD(dd,-1,GETDATE())

order by kc_cp_no

OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_cp_no,@wk_mobil_no,@wk_data_type

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

		IF @wk_data_type = '1'
		BEGIN
		SET @wk_sms_msg = '很抱歉，DUDUPAY還有您需要補件的資料，請盡快點擊連結 https://testcms.dudupay.com.tw/ 進行補件，DUDUPAY將於明日中午12:00關閉連結。感謝您的合作!'
		END
		ELSE IF @wk_data_type = '2'
		BEGIN
		SET @wk_sms_msg = '很抱歉，由於未收到您的補件資料，我們取消了您的申請。如需繼續，請重新登入DUDUPAY會員並完成後續步驟 https://testcms.dudupay.com.tw/ 。感謝您的理解與合作!'
		END

			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_cp_no
			SELECT @wk_push_link = '0000' + @wk_sms_no

			--簡訊
			INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link) 
			VALUES (@wk_cp_no, @wk_sms_no, GETDATE(), @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link)

		END

	END
FETCH NEXT FROM cursor1  INTO @wk_cp_no,@wk_mobil_no,@wk_data_type
end
CLOSE cursor1
DEALLOCATE cursor1

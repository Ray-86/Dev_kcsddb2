-- =============================================
-- 2021/12/30 進件來源03特約，案件進件時，季送一封簡訊
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_autosms_createsource03]

AS
DECLARE  
	@wk_cp_no AS VARCHAR(10),
	@wk_case_no AS VARCHAR(10),
	@wk_brand_code AS VARCHAR(2),
	@wk_mobil_no AS VARCHAR(12),

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

			select cp.kc_cp_no,c.kc_case_no,cp.kc_brand_code,cp.kc_mobil_no from kcsd.kc_remittance r 
			left join kcsd.kc_customerloan c on c.kc_case_no = r.kc_case_no
			left join kcsd.kc_cpdata cp on c.kc_cp_no = cp.kc_cp_no
			where c.kc_case_no = '1823618'
			--where 	kc_autosms_flag is null and c.kc_buy_date between '2022-01-01' and GETDATE() and kc_source_type = '03' and r.kc_remit_date is not null
order by c.kc_case_no

OPEN cursor1
FETCH NEXT FROM cursor1 INTO @wk_cp_no,@wk_case_no,@wk_brand_code,@wk_mobil_no

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

		IF @wk_brand_code = '01'
		BEGIN	
			SET @wk_sms_link = 'http://nav.cx/8Ue9piZ'			
			SET @wk_sms_mobil = '02-22268886' 
			SET @wk_sms_brand = '東元'

		END
		ELSE
		BEGIN
				
			SET @wk_sms_link = 'https://lin.ee/7xrIykr'		
			SET @wk_sms_mobil = '02-82261033'
			SET @wk_sms_brand = '波波'
		END

		IF @flag = 0
		BEGIN

		SET @wk_sms_msg = @wk_sms_brand+'公司分期電子帳單LINE操作說明: \n１、點擊'+@wk_sms_link+'加入'+@wk_sms_brand+'分期帳單專屬LINE官方帳號。\n２、點選服務選單-首次登入，先輸入您的身分證字號送出，再輸入'+@wk_cp_no +'。\n(如您已曾經登入，請略過此步驟)\n３、點選服務選單-取得帳單，取條碼即可至超商繳費。\n如有操作問題，請來電@wk_sms_mobil'


			SELECT @wk_sms_no = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
			SELECT @wk_push_link = '0000' + @wk_sms_no

			--簡訊
			INSERT INTO kc_sms (kc_case_no, kc_item_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_crdt_date, kc_crdt_user, kc_updt_date, kc_updt_user, kc_push_link) 
			VALUES (@wk_case_no, @wk_sms_no, GETDATE(), @wk_mobil_no, @wk_sms_msg, GETDATE(), USER, GETDATE(), USER, @wk_push_link)

			--更新flag
			update kcsd.kc_remittance set kc_autosms_flag = 'Y' where kc_case_no = @wk_case_no
		END
	END
FETCH NEXT FROM cursor1  INTO @wk_cp_no,@wk_case_no,@wk_brand_code,@wk_mobil_no
end
CLOSE cursor1
DEALLOCATE cursor1

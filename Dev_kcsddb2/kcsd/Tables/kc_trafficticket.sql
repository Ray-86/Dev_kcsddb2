CREATE TABLE [kcsd].[kc_trafficticket] (
    [kc_case_no]    VARCHAR (10)  NOT NULL,
    [kc_item_no]    SMALLINT      NOT NULL,
    [kc_area_code]  VARCHAR (2)   NOT NULL,
    [kc_input_date] SMALLDATETIME NOT NULL,
    [kc_tick_type]  VARCHAR (4)   NOT NULL,
    [kc_tick_kind]  VARCHAR (6)   NULL,
    [kc_tick_date]  SMALLDATETIME NOT NULL,
    [kc_tick_amt]   INT           NOT NULL,
    [kc_rept_date]  SMALLDATETIME NOT NULL,
    [kc_resp_date]  SMALLDATETIME NULL,
    [kc_tick_no]    VARCHAR (20)  NULL,
    [kc_pay_date]   SMALLDATETIME NULL,
    [kc_proc_fee]   INT           NULL,
    [kc_pay_type]   VARCHAR (2)   NULL,
    [kc_updt_user]  VARCHAR (10)  NULL,
    [kc_updt_date]  SMALLDATETIME NULL,
    [kc_tick_item]  VARCHAR (200) NULL,
    [CreatePerson]  VARCHAR (20)  NULL,
    [CreateDate]    DATETIME      NULL,
    CONSTRAINT [PK_kc_trafficticket] PRIMARY KEY CLUSTERED ([kc_case_no] ASC, [kc_item_no] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [i_kc_trafficticket]
    ON [kcsd].[kc_trafficticket]([kc_case_no] ASC, [kc_item_no] ASC);


GO
CREATE NONCLUSTERED INDEX [i_kc_trafficticket_1]
    ON [kcsd].[kc_trafficticket]([kc_case_no] ASC, [kc_area_code] ASC);


GO
CREATE  TRIGGER [kcsd].[t_kc_trafficticket_i] ON [kcsd].[kc_trafficticket] 
FOR INSERT NOT FOR REPLICATION
AS
DECLARE 	@wk_case_no		varchar(10),
		@wk_item_no		int,
		@wk_push_note	varchar(200),
		@wk_push_date	datetime,
		@wk_law_date	datetime,
		@wk_tick_no		varchar(20),
		--@wk_tick_date	varchar(10),
		--@wk_rept_date	varchar(10),
		@wk_law_amt		int,
		@wk_uniform_no	varchar(10),
		@wk_licn_no		varchar(10),
		@wk_issu_desc	varchar(10),
		@wk_tick_type	varchar(2),
		@wk_item_no1	smallint,
		@wk_item_no2	smallint,
		@wk_area_code	varchar(2),
		@wk_tick_kind	VARCHAR(6),
		@wk_user_code	VARCHAR(4),
		@wk_push_count	SMALLINT,
		@wk_case_phone	VARCHAR(10),
		@wk_push_link	NVARCHAR(10),
		@wk_updt_user	varchar(10)

SELECT	@wk_case_no = kc_case_no,
		@wk_item_no = kc_item_no,
		@wk_law_date = kc_input_date,
		@wk_tick_no = kc_tick_no,
		--@wk_tick_date = CONVERT(varchar(10),kc_tick_date, 1),
		--@wk_rept_date = CONVERT(varchar(10), DATEADD(day,-10,kc_rept_date) , 11),
		@wk_law_amt = kc_tick_amt,
		@wk_tick_type = kc_tick_type,
		@wk_tick_kind = kc_tick_kind,
		@wk_updt_user = kc_updt_user
FROM	inserted

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
	FROM	kcsd.kc_trafficticket
	WHERE	kc_case_no = @wk_case_no

	UPDATE	kcsd.kc_trafficticket
	SET	kc_item_no = @wk_item_no
	WHERE	kc_case_no = @wk_case_no
	AND	kc_item_no IS NULL
END

	SELECT	@wk_push_date = CONVERT(varchar(100), GETDATE(), 23)
	SELECT	@wk_uniform_no = i.kc_uniform_no,@wk_licn_no = c.kc_licn_no,@wk_issu_desc = SUBSTRING(i.kc_issu_desc,1,4) FROM kcsd.kct_issuecompany i,kcsd.kc_customerloan c,kcsd.kct_issuecompany WHERE i.kc_issu_code = c.kc_issu_code AND c.kc_case_no = @wk_case_no
	IF @wk_issu_desc = '東元騰有'
	BEGIN
		SELECT @wk_issu_desc = '東元騰'
	END
	
	IF (SELECT COUNT(*) FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no AND kc_push_date = @wk_push_date AND kc_push_note LIKE '%' + @wk_licn_no + '%罰單%') = 0
	BEGIN
		IF @wk_tick_type = 'A'
		BEGIN		
			--新增至催繳記錄
			--取得資料
			SELECT @wk_area_code = kc_area_code from kcsd.kc_customerloan where kc_case_no =@wk_case_no
			SELECT @wk_user_code = EmpCode FROM kcsd.v_Employee WHERE UserCode = @wk_updt_user
			SELECT @wk_push_count = COUNT(*)+1 from kcsd.kc_push where kc_case_no = @wk_case_no
			SELECT @wk_case_phone = kc_mobil_no from kcsd.kc_customerloan where kc_case_no = @wk_case_no
			SELECT @wk_push_link = CONVERT(varchar(4),@wk_user_code) + CONVERT(varchar(4),@wk_push_count) 
			--沒有電話就不傳
			IF NOT((@wk_case_phone IS NULL) OR (@wk_case_phone = ''))
			BEGIN
				IF @wk_tick_kind = 'A56-1'
				BEGIN
					SELECT	@wk_push_note = '您好，請於五日內至超商輸入' + isnull(@wk_licn_no,'') + '統編' + isnull(@wk_uniform_no,'') + '繳罰單' +  CONVERT(varchar(10), @wk_law_amt) + '元及停車費，東元02-22268886#5053(逾期費300元)'
				END
				ELSE
				BEGIN
					IF @wk_tick_kind = 'A43-4'
					BEGIN
						SELECT	@wk_push_note = '您好，違規須吊扣' + isnull(@wk_licn_no,'') + '牌照，請於五日內與本公司繳回車牌辦理以免遭註銷，東元02-22268886#5053(重領牌費2000元)'
					END
					ELSE
					BEGIN
						IF @wk_tick_kind in ('A16-1','A18-1','A17')
						BEGIN
							SELECT	@wk_push_note = '您好，違規車牌' + isnull(@wk_licn_no,'') + '需檢驗車輛，請於五日內與本公司辦理驗車事宜以免遭註銷，東元02-22268886#5053(重領牌費2000元)'
						END
						ELSE
						BEGIN
							SELECT	@wk_push_note = '您好，請於收到簡訊五日內至超商輸入' + isnull(@wk_licn_no,'') + '統編' + isnull(@wk_uniform_no,'') + '繳交罰單' + '，東元02-22268886#5053(逾期費300元)'
						END
					END
				END
				-- 輸入至催繳
				SELECT @wk_item_no1 = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_push WHERE kc_case_no = @wk_case_no
				INSERT	kcsd.kc_push
						(kc_case_no,kc_area_code, kc_push_date, kc_push_note, kc_effe_flag,kc_item_no,kc_updt_user,kc_updt_date,kc_push_link)
				VALUES	(@wk_case_no, @wk_area_code,@wk_push_date, @wk_push_note, 0,@wk_item_no1,@wk_updt_user,GETDATE(),@wk_push_link)
				-- 輸入至簡訊
				-- 簡訊MSGDATE 只能使用日期 不能有當下時間
				SELECT @wk_item_no2 = ISNULL(MAX(kc_item_no),0) + 1 FROM kcsd.kc_sms WHERE kc_case_no = @wk_case_no
				INSERT	kcsd.kc_sms
						( kc_case_no, kc_msg_date, kc_mobil_no, kc_msg_body, kc_updt_user, kc_updt_date, kc_push_link, kc_item_no )
				VALUES	( @wk_case_no, @wk_push_date, @wk_case_phone, @wk_push_note, @wk_updt_user, GETDATE(), @wk_push_link, @wk_item_no2 )
			END
		END
	END

--UPDATE	kcsd.kc_trafficticket
--SET	kc_updt_user = USER, kc_updt_date = GETDATE()
--WHERE	kc_case_no = @wk_case_no
--AND	kc_item_no = @wk_item_no

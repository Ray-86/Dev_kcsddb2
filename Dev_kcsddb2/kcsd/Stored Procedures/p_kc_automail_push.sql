

CREATE                PROCEDURE [kcsd].[p_kc_automail_push]
	@pm_run_code varchar(20)=NULL
AS
DECLARE	
@wk_case_no		varchar(10),		--客戶編號
@wk_area_code	varchar(2),			--分公司
@wk_pusher_date	smalldatetime,		--委派起始日期
@wk_B_count		int,				--委派期間B個數
@wk_L_count		int,				--委派期間L個數
@wk_O_count		int,				--委派期間O個數
@wk_last_pay_date	smalldatetime,	--最後繳款日期
@wk_datediff	int,
@wk_item_no		int,
@wk_mail_flag	varchar(1),
@wk_pay_count	int,				--期間繳款次數
@wk_cust_nameu	nvarchar(10),		--本名
@wk_cust_name1u	nvarchar(10),		--保一名
@wk_cust_name2u	nvarchar(10),		--保二名
@wk_perm_flag	varchar(1),			--本戶籍地址Y
@wk_curr_flag	varchar(1),			--本聯絡地址Y
@wk_perm_flag1	varchar(1),			--保1戶籍地址Y
@wk_curr_flag1	varchar(1),			--保1聯絡地址Y
@wk_perm_flag2	varchar(1),			--保2戶籍地址Y
@wk_curr_flag2	varchar(1),			--保2聯絡地址Y
@wk_perm_zip	varchar(1),			--本戶籍郵遞區號Y
@wk_curr_zip	varchar(1),			--本聯絡郵遞區號Y
@wk_perm_zip1	varchar(1),			--保1戶籍郵遞區號Y
@wk_curr_zip1	varchar(1),			--保1聯絡郵遞區號Y
@wk_perm_zip2	varchar(1),			--保2聯絡戶籍郵遞區號Y
@wk_curr_zip2	varchar(1),			--保2郵遞區號Y
@wk_perm_addr	varchar(200),		--本戶籍地址
@wk_curr_addr	varchar(200),		--本聯絡地址
@wk_perm_addr1	varchar(200),		--保1戶籍地址
@wk_curr_addr1	varchar(200),		--保1聯絡地址
@wk_perm_addr2	varchar(200),		--保2戶籍地址
@wk_curr_addr2	varchar(200)		--保2聯絡地址

CREATE TABLE #tmp_automail_push
(kc_case_no		varchar(10),
kc_law_date		smalldatetime, 
kc_law_code		varchar(1), 
kc_crdt_user	varchar(10), 
kc_crdt_date	smalldatetime,
kc_updt_user	varchar(10), 
kc_updt_date	smalldatetime,
kc_item_no		int, 
kc_area_code	varchar(2),
kc_perm_flag	varchar(1), 
kc_curr_flag	varchar(1), 
kc_perm_flag1	varchar(1), 
kc_curr_flag1	varchar(1), 
kc_perm_flag2	varchar(1), 
kc_curr_flag2	varchar(1)
)

DECLARE	cursor_case_no_P	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan 
	WHERE	kc_pusher_code LIKE 'P%'
	AND	kc_push_sort NOT IN ('C1','C2','C3','C4','C5')
	AND	kc_loan_stat = 'D'
	ORDER BY kc_case_no
OPEN cursor_case_no_P
FETCH NEXT FROM cursor_case_no_P INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SELECT @wk_perm_flag = NULL,@wk_curr_flag = NULL,@wk_perm_flag1 = NULL,@wk_curr_flag1 = NULL,@wk_perm_flag2 = NULL,@wk_curr_flag2 = NULL
	SELECT @wk_perm_addr = NULL,@wk_curr_addr = NULL,@wk_perm_addr1 = NULL,@wk_curr_addr1 = NULL,@wk_perm_addr2 = NULL,@wk_curr_addr2 = NULL
	SELECT @wk_perm_zip = NULL,@wk_curr_zip = NULL,@wk_perm_zip1 = NULL,@wk_curr_zip1 = NULL,@wk_perm_zip2 = NULL,@wk_curr_zip2 = NULL
	SELECT @wk_area_code = kc_area_code,@wk_pusher_date = kc_pusher_date FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
	SELECT @wk_item_no = ISNULL(MAX(kc_item_no),0)+1 FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no
	--取得委派期間BLO個數
	SELECT @wk_B_count = ISNULL(COUNT(*),0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no AND kc_law_code = 'B' AND kc_law_date >= @wk_pusher_date
	SELECT @wk_L_count = ISNULL(COUNT(*),0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no AND kc_law_code = 'L' AND kc_law_date >= @wk_pusher_date
	SELECT @wk_O_count = ISNULL(COUNT(*),0) FROM kcsd.kc_lawstatus WHERE kc_case_no = @wk_case_no AND kc_law_code = 'O' AND kc_law_date >= @wk_pusher_date
	--最後繳款日(若一期未繳則為第一期應繳日)
	SELECT @wk_last_pay_date = ISNULL(MAX(kc_pay_date),MIN(kc_expt_date)) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no
	--委派期間繳款次數
	SELECT @wk_pay_count = ISNULL(COUNT(*),0) FROM kcsd.kc_loanpayment WHERE kc_case_no = @wk_case_no AND kc_pay_date >= @wk_pusher_date

	--委派期間有繳款紀錄 用最後繳款日做判斷 無繳款紀錄 用委派日期做判斷
	IF @wk_pay_count > 0 SELECT @wk_datediff = DATEDIFF(day,@wk_last_pay_date,GETDATE())
	ELSE SELECT @wk_datediff = DATEDIFF(day,@wk_pusher_date,GETDATE())
	SELECT @wk_mail_flag = CASE WHEN @wk_datediff > 80 THEN 'O' WHEN @wk_datediff > 60 THEN 'L' WHEN @wk_datediff > 40 THEN 'B' ELSE '' END

	--PRINT @wk_case_no + '-' + @wk_mail_flag + CONVERT(varchar(100),@wk_datediff) + '-' + CONVERT(varchar(100),@wk_B_count) + '-' + CONVERT(varchar(100),@wk_L_count) + '-' + CONVERT(varchar(100),@wk_O_count)

	--BLO而且沒寄信過
	IF (@wk_mail_flag = 'B' AND @wk_B_count = 0) OR (@wk_mail_flag = 'L' AND @wk_L_count = 0) OR (@wk_mail_flag = 'O' AND @wk_O_count = 0)
	BEGIN
		--PRINT @wk_case_no + '-' + ISNULL(@wk_perm_flag,'X') + ISNULL(@wk_curr_flag,'X') + ISNULL(@wk_perm_flag1,'X') + ISNULL(@wk_curr_flag1,'X') + ISNULL(@wk_perm_flag2,'X') + ISNULL(@wk_curr_flag2,'X')
		SELECT @wk_cust_nameu = kc_cust_nameu, @wk_cust_name1u = kc_cust_name1u, @wk_cust_name2u = kc_cust_name2u,
		@wk_perm_addr = kc_perm_addr, @wk_curr_addr = kc_curr_addr, 
		@wk_perm_addr1 = kc_perm_addr1, @wk_curr_addr1 = kc_curr_addr1, 
		@wk_perm_addr2 = kc_perm_addr2, @wk_curr_addr2 = kc_curr_addr2, 
		@wk_perm_zip = kc_perm_zip, @wk_curr_zip = kc_curr_zip, 
		@wk_perm_zip1 = kc_perm_zip1, @wk_curr_zip1 = kc_curr_zip1, 
		@wk_perm_zip2 = kc_perm_zip2, @wk_curr_zip2 = kc_curr_zip2 
		FROM kcsd.kc_customerloan WHERE kc_case_no = @wk_case_no
		--PRINT @wk_case_no + '-' + ISNULL(@wk_perm_addr,'X') + ISNULL(@wk_curr_addr,'X')
		--PRINT @wk_case_no + '-' + ISNULL(@wk_perm_addr1,'X') + ISNULL(@wk_curr_addr1,'X')
		--PRINT @wk_case_no + '-' + ISNULL(@wk_perm_addr2,'X') + ISNULL(@wk_curr_addr2,'X')
		IF @wk_perm_addr = @wk_curr_addr SELECT @wk_curr_addr = NULL
		IF @wk_perm_zip IS NULL OR @wk_perm_zip = '' OR @wk_cust_nameu IS NULL OR @wk_cust_nameu = '' SELECT @wk_perm_addr = NULL
		IF @wk_curr_zip IS NULL OR @wk_curr_zip = '' OR @wk_cust_nameu IS NULL OR @wk_cust_nameu = '' SELECT @wk_curr_addr = NULL
		IF @wk_perm_addr IS NOT NULL SELECT @wk_perm_flag = 'Y'
		IF @wk_curr_addr IS NOT NULL SELECT @wk_curr_flag = 'Y'
		IF @wk_perm_addr1 = @wk_curr_addr1 SELECT @wk_curr_addr1 = NULL
		IF @wk_perm_zip1 IS NULL OR @wk_perm_zip1 = '' OR @wk_cust_name1u IS NULL OR @wk_cust_name1u = '' SELECT @wk_perm_addr1 = NULL
		IF @wk_curr_zip1 IS NULL OR @wk_curr_zip1 = '' OR @wk_cust_name1u IS NULL OR @wk_cust_name1u = '' SELECT @wk_curr_addr1 = NULL
		IF @wk_perm_addr1 IS NOT NULL SELECT @wk_perm_flag1 = 'Y'
		IF @wk_curr_addr1 IS NOT NULL SELECT @wk_curr_flag1 = 'Y'
		IF @wk_perm_addr2 = @wk_curr_addr2 SELECT @wk_curr_addr2 = NULL
		IF @wk_perm_zip2 IS NULL OR @wk_perm_zip2 = '' OR @wk_cust_name2u IS NULL OR @wk_cust_name2u = '' SELECT @wk_perm_addr2 = NULL
		IF @wk_curr_zip2 IS NULL OR @wk_curr_zip2 = '' OR @wk_cust_name2u IS NULL OR @wk_cust_name2u = '' SELECT @wk_curr_addr2 = NULL
		IF @wk_perm_addr2 IS NOT NULL SELECT @wk_perm_flag2 = 'Y'
		IF @wk_curr_addr2 IS NOT NULL SELECT @wk_curr_flag2 = 'Y'

		--都沒有Y就不寄
		IF (@wk_perm_flag IS NOT NULL OR @wk_curr_flag IS NOT NULL OR @wk_perm_flag1 IS NOT NULL OR @wk_curr_flag1 IS NOT NULL OR @wk_perm_flag2 IS NOT NULL OR @wk_curr_flag2 IS NOT NULL)
		BEGIN
			INSERT INTO #tmp_automail_push
			(kc_case_no, kc_law_date, kc_law_code, kc_crdt_user, kc_crdt_date, kc_updt_user, kc_updt_date, kc_item_no, kc_area_code,
			kc_perm_flag, kc_curr_flag, kc_perm_flag1, kc_curr_flag1, kc_perm_flag2, kc_curr_flag2)
			VALUES
			(@wk_case_no, DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE())), @wk_mail_flag, USER, GETDATE(), USER, GETDATE(), @wk_item_no, @wk_area_code,
			@wk_perm_flag, @wk_curr_flag, @wk_perm_flag1, @wk_curr_flag1, @wk_perm_flag2, @wk_curr_flag2 )
		END
	END

	FETCH NEXT FROM cursor_case_no_P INTO @wk_case_no
END
CLOSE cursor_case_no_P

IF	@pm_run_code = 'EXECUTE'
BEGIN
	INSERT INTO kcsd.kc_lawstatus
    (kc_case_no, kc_law_date, kc_law_code, kc_crdt_user, kc_crdt_date, kc_updt_user, kc_updt_date, kc_item_no, kc_area_code
    ,kc_perm_flag, kc_curr_flag, kc_perm_flag1, kc_curr_flag1, kc_perm_flag2, kc_curr_flag2)
	SELECT * FROM #tmp_automail_push
END
ELSE
BEGIN
	SELECT * FROM #tmp_automail_push
END

DROP TABLE #tmp_automail_push
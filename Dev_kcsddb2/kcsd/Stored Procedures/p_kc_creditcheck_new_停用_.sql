-- =============================================
-- 2012-01-18 增加無DY1資料庫時不連結DY1 (避免當機)
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_creditcheck_new(停用)] @pm_query_input char(20)
AS
/*
B: 黑名單
C: 客戶
C2:低零利, C3:舊客戶, C4: DY3
D: 保人, D2:低零利, D3:舊保人
T: 其他車行
R: 親屬, R2:低零利
*/
DECLARE	@flag 		int,
		@i 		int,
 		@test		varchar(150)

SET @test = 'OPENDATASOURCE( ''SQLOLEDB'', ''Data Source=PCX01;User ID=sa;Password=neteater'').kcsddb.kcsd.dy1kc_customerloan'
SET @i = 1
WHILE  LEN(@pm_query_input) >= @i
BEGIN
	DECLARE @ChcekValue int 

	SELECT  @ChcekValue =  ASCII(SUBSTRING(@pm_query_input,@i,1))
	IF(@ChcekValue > 122)
	BEGIN		
		SET @flag = 1	-- 中文
		BREAK 
     	END
	ELSE
	BEGIN
		SET @flag = 0	-- 英文數字
	END
	SET @i = @i +1	
END

	IF @flag =1
	BEGIN		
		------------------------------------------------------------------------------------------------------------------------------------
		-- C: 本人 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- D: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
	
		-- D: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL

		-- R: 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2R' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_mate_name = @pm_query_input
		OR	kc_papa_name = @pm_query_input
		OR	kc_mama_name = @pm_query_input
		OR	kc_mate_name1 = @pm_query_input
		OR	kc_papa_name1 = @pm_query_input
		OR	kc_mama_name1 = @pm_query_input
		OR	kc_mate_name2 = @pm_query_input
		OR	kc_papa_name2 = @pm_query_input
		OR	kc_mama_name2 = @pm_query_input
		UNION ALL

		-- B: 黑名單 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'B' as wk_ctype_no, kc_id_no as wk_link_info,
			Convert(nvarchar,isnull(kc_black_reason,'')) + Convert(nvarchar,isnull(kc_black_reason2,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- T: 其他車行 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'T' as wk_ctype_no, kc_id_no as wk_link_info,
			 Convert(nvarchar,isnull(kc_comp_code,'')) + Convert(nvarchar,isnull(kc_memo,'')) as wk_loan_stat
		FROM	kcsd.kc_othercase
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL

		--XC3:舊客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		--XD3:舊客戶保人1
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC1' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
	
		--XD3:舊客戶保人2
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC2' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL

		------------------------------------------------------------------------------------------------------------------------------------		
		--DY1

		-- XC: 客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- XD: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- XD: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- R: 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1R' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_mate_name = @pm_query_input
		OR	kc_papa_name = @pm_query_input
		OR	kc_mama_name = @pm_query_input
		OR	kc_mate_name1 = @pm_query_input
		OR	kc_papa_name1 = @pm_query_input
		OR	kc_mama_name1 = @pm_query_input
		OR	kc_mate_name2 = @pm_query_input
		OR	kc_papa_name2 = @pm_query_input
		OR	kc_mama_name2 = @pm_query_input
		UNION ALL
		------------------------------------------------------------------------------------------------------------------------------------		
		--DY3

		-- XC: 客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- XD: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- XD: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- R: 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3R' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_mate_name = @pm_query_input
		OR	kc_papa_name = @pm_query_input
		OR	kc_mama_name = @pm_query_input
		OR	kc_mate_name1 = @pm_query_input
		OR	kc_papa_name1 = @pm_query_input
		OR	kc_mama_name1 = @pm_query_input
		OR	kc_mate_name2 = @pm_query_input
		OR	kc_papa_name2 = @pm_query_input
		OR	kc_mama_name2 = @pm_query_input
		UNION ALL

		--本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
		
		-- D: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- D: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- R: 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZR' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_mate_name = @pm_query_input
		OR	kc_papa_name = @pm_query_input
		OR	kc_mama_name = @pm_query_input
		OR	kc_mate_name1 = @pm_query_input
		OR	kc_papa_name1 = @pm_query_input
		OR	kc_mama_name1 = @pm_query_input
		OR	kc_mate_name2 = @pm_query_input
		OR	kc_papa_name2 = @pm_query_input
		OR	kc_mama_name2 = @pm_query_input
		------------------------------------------------------------------------------------------------------------------------------------
     	END
	ELSE
	BEGIN
		------------------------------------------------------------------------------------------------------------------------------------
		--本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
		
		-- D: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- D: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D2C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL
	
		-- B: 黑名單 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'B' as wk_ctype_no, kc_id_no as wk_link_info,
			Convert(nvarchar,isnull(kc_black_reason,'')) + Convert(nvarchar,isnull(kc_black_reason2,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
		
		-- T: 其他車行 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'T' as wk_ctype_no, kc_id_no as wk_link_info,
			Convert(nvarchar,isnull(kc_comp_code,'')) + Convert(nvarchar,isnull(kc_memo,'')) as wk_loan_stat
		FROM	kcsd.kc_othercase
		WHERE	kc_id_no = @pm_query_input
		UNION ALL

		--XC3:舊客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		--XD3:舊客戶保人1
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC1' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
	
		--XD3:舊客戶保人2
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'OC2' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	kcsd.kc_customerold c
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL
	
		--DY1

		-- XC: 客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		-- XD: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- XD: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D1C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan
		FROM	kcsddb.kcsd.dy1kc_customerloan
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL
	
		--DY3

		-- XC: 客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		-- XD: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- XD: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'D3C2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		FROM	kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL

		--本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
		
		-- D: 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC1' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- D: 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'ZC2' as wk_ctype_no, kc_case_no as wk_link_info,
			kc_loan_stat as wk_loan_stat
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.dy1kc_customerloan2
		FROM	kcsddb.kcsd.dy1kc_customerloan2
		WHERE	kc_id_no2 = @pm_query_input
		------------------------------------------------------------------------------------------------------------------------------------
	END

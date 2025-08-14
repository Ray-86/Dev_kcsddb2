-- ==========================================================================================
-- 2015-05-08 dy2案件增加歷史id查詢
-- 2013-07-18 取消查詢舊客戶資料 (案件皆超過十年以上)
-- 2013-06-03 調整查詢方式與優化查詢
-- ==========================================================================================

CREATE PROCEDURE [kcsd].[p_kc_creditcheck] @pm_query_input Nvarchar(20)
AS

DECLARE	@flag 		int,
		@i 		int
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
		-- DY2本人 
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 本人' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 0 and 
		EXISTS (
			SELECT 'x'
			FROM kcsd.kc_customers x
			WHERE 
			s.kc_id_no = x.kc_id_no and
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_cust_nameu =  @pm_query_input 
			)
		)
		UNION
		SELECT distinct kc_id_no as wk_id_no,kc_cust_nameu as wk_cust_name,'DY2 本人' as wk_ctype_no,kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customerloan
		WHERE kc_cust_nameu = @pm_query_input

		UNION ALL
		-- DY2保人1
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 保人1' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 1 and 
		EXISTS (
			SELECT 'x'
			FROM kcsd.kc_customers x
			WHERE 
			s.kc_id_no = x.kc_id_no and
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_cust_nameu =  @pm_query_input 
			)
		)
		UNION
		SELECT distinct kc_id_no as wk_id_no, kc_cust_nameu as wk_cust_name,'DY2 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_name1u = @pm_query_input

		UNION ALL
	
		-- DY2保人2 
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 保人2' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 2 and 
		EXISTS (
			SELECT 'x'
			FROM kcsd.kc_customers x
			WHERE 
			s.kc_id_no = x.kc_id_no and
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_cust_nameu =  @pm_query_input 
			)
		)
		UNION
		SELECT distinct kc_id_no as wk_id_no, kc_cust_nameu as wk_cust_name,'DY2 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_name2u = @pm_query_input

		UNION ALL

		-- DY2 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_nameu as wk_cust_name,'DY2 親屬' as wk_ctype_no, kc_case_no as wk_link_info,	kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan
		WHERE	kc_cust_nameu = @pm_query_input
		OR	kc_papa_nameu = @pm_query_input
		OR	kc_mama_nameu = @pm_query_input
		OR	kc_mate_name1u = @pm_query_input
		OR	kc_papa_name1u = @pm_query_input
		OR	kc_mama_name1u = @pm_query_input
		OR	kc_mate_name2u = @pm_query_input
		OR	kc_papa_name2u = @pm_query_input
		OR	kc_mama_name2u = @pm_query_input
		UNION ALL

		-- DY2 使用人
		SELECT	c1.kc_id_no5 as wk_id_no, c1.kc_cust_name5u as wk_cust_name,'DY2 使用人' as wk_ctype_no, c1.kc_case_no as wk_link_info,	c.kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan1 c1,kcsd.kc_customerloan c
		WHERE	c1.kc_case_no = c.kc_case_no and
			c1.kc_cust_name5u = @pm_query_input
		UNION ALL

		-- DY2 黑名單 
		SELECT b.kc_id_no as wk_id_no, b.kc_cust_name as wk_cust_name,'婉拒' as wk_ctype_no, '' as wk_link_info,	Convert(NVARCHAR(10),kc_updt_date,111)+ Convert(nvarchar,isnull(b1.kc_black_reason,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist b,kcsd.kc_blacklistlist b1
		WHERE	b.kc_cust_name =  @pm_query_input  and b.kc_id_no = b1.kc_id_no AND b.kc_decline_flag = '0' and b1.kc_item_no IN( SELECT MAX(kc_item_no) FROM  kcsd.kc_blacklistlist WHERE kc_id_no =  b.kc_id_no )
		UNION ALL
		
		-- DY2 黑名單 
		SELECT b.kc_id_no as wk_id_no, b.kc_cust_name as wk_cust_name,'拒往' as wk_ctype_no, '' as wk_link_info,	Convert(NVARCHAR(10),kc_updt_date,111)+ Convert(nvarchar,isnull(b1.kc_black_reason,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist b,kcsd.kc_blacklistlist b1
		WHERE	b.kc_cust_name =  @pm_query_input  and b.kc_id_no = b1.kc_id_no AND b.kc_decline_flag = '-1' and b1.kc_item_no IN( SELECT MAX(kc_item_no) FROM  kcsd.kc_blacklistlist WHERE kc_id_no =  b.kc_id_no )
		UNION ALL
	
		-- DY2 其他車行 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'其他車行' as wk_ctype_no, '' as wk_link_info,Convert(nvarchar,isnull(kc_comp_code,'')) + Convert(nvarchar,isnull(kc_memo,'')) as wk_loan_stat
		FROM	kcsd.kc_othercase
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
		/*
		--DY2 舊客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 本人' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		--DY2 舊客戶保人1
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 保人1' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
	
		--DY2 舊客戶保人2
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 保人2' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
		*/
		-- DY1 本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- DY1 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- DY1  保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- DY1 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 親屬' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
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

		-- DY3 本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
	
		-- DY3 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- DY3 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- DY3 親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 親屬' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
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

		--DY1 低零利本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_cust_name = @pm_query_input
		UNION ALL
		
		-- DY1 低零利保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_cust_name1 = @pm_query_input
		UNION ALL
		
		-- DY1 低零利保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_cust_name2 = @pm_query_input
		UNION ALL
	
		-- DY1 低零利親屬
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 親屬' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
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
		-- DY2 本人
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 本人' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 0 and 
		EXISTS (
			SELECT DISTINCT  x.kc_id_no
			FROM kcsd.kc_customers x
			WHERE
			s.kc_id_no = x.kc_id_no AND
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_id_no = @pm_query_input 
				)	
			)

		UNION ALL
		
		-- DY2 保人1 
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 保人1' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 1 and 
		EXISTS (
			SELECT DISTINCT  x.kc_id_no
			FROM kcsd.kc_customers x
			WHERE
			s.kc_id_no = x.kc_id_no AND
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_id_no = @pm_query_input 
				)	
			)
		UNION ALL
		
		-- DY2 保人2 
		SELECT distinct s.kc_id_no as wk_id_no,s.kc_cust_nameu as wk_cust_name,'DY2 保人2' as wk_ctype_no,s.kc_case_no as wk_link_info,u.kc_loan_stat as wk_loan_stat
		FROM kcsd.kc_customers s,kcsd.kc_customerloan u
		WHERE
		s.kc_case_no = u.kc_case_no AND
		s.kc_cust_type = 2 and 
		EXISTS (
			SELECT DISTINCT  x.kc_id_no
			FROM kcsd.kc_customers x
			WHERE
			s.kc_id_no = x.kc_id_no AND
			EXISTS ( select 'x' FROM kcsd.kc_customers c WHERE
					x.kc_case_no = c.kc_case_no and 
					x.kc_cust_type = c.kc_cust_type and
					c.kc_id_no = @pm_query_input 
				)	
			)
		UNION ALL

		-- DY2 使用人
		SELECT	c1.kc_id_no5 as wk_id_no, c1.kc_cust_name5u as wk_cust_name,'DY2 使用人' as wk_ctype_no, c1.kc_case_no as wk_link_info,	c.kc_loan_stat as wk_loan_stat
		FROM	kcsd.kc_customerloan1 c1,kcsd.kc_customerloan c
		WHERE	c1.kc_case_no = c.kc_case_no and
			c1.kc_id_no5 = @pm_query_input
		UNION ALL
	
		-- DY2 黑名單 婉拒
		SELECT b.kc_id_no as wk_id_no, b.kc_cust_name as wk_cust_name,'婉拒' as wk_ctype_no, '' as wk_link_info,	Convert(NVARCHAR(10),kc_updt_date,111)+ Convert(nvarchar,isnull(b1.kc_black_reason,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist b,kcsd.kc_blacklistlist b1
		WHERE	b.kc_id_no =  @pm_query_input  and b.kc_id_no = b1.kc_id_no AND b.kc_decline_flag = '0' and b1.kc_item_no IN( SELECT MAX(kc_item_no) FROM  kcsd.kc_blacklistlist WHERE kc_id_no =  b.kc_id_no )
		UNION ALL
		
		-- DY2 黑名單 拒往
		SELECT b.kc_id_no as wk_id_no, b.kc_cust_name as wk_cust_name,'拒往' as wk_ctype_no, '' as wk_link_info,	Convert(NVARCHAR(10),kc_updt_date,111)+ Convert(nvarchar,isnull(b1.kc_black_reason,'')) as wk_loan_stat
		FROM	kcsd.kc_blacklist b,kcsd.kc_blacklistlist b1
		WHERE	b.kc_id_no =  @pm_query_input  and b.kc_id_no = b1.kc_id_no AND b.kc_decline_flag = '-1' and b1.kc_item_no IN( SELECT MAX(kc_item_no) FROM  kcsd.kc_blacklistlist WHERE kc_id_no =  b.kc_id_no )
		UNION ALL
		
		-- DY2 其他車行 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'其他車行' as wk_ctype_no, '' as wk_link_info,Convert(nvarchar,isnull(kc_comp_code,'')) + Convert(nvarchar,isnull(kc_memo,'')) as wk_loan_stat
		FROM	kcsd.kc_othercase
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
		/*
		-- DY2 舊客戶
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 本人' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		-- DY2 舊客戶保人1
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 保人1' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
	
		-- DY2 舊客戶保人2
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,
			'舊客戶 保人2' as wk_ctype_no, kc_case_no as wk_link_info,
			'' as wk_loan_stat
		FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerold
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL
		*/	
		-- DY1 本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		-- DY1 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- DY1 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY1 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.dy1kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL

		-- DY3 本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
	
		-- DY3 保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 保人1' as wk_ctype_no, kc_case_no as wk_link_info,	kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- DY3 保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'DY3 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb3.kcsd.kc_customerloan
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb3.kcsd.kc_customerloan
		WHERE	kc_id_no2 = @pm_query_input
		UNION ALL

		-- DY1 低零利本人
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 本人' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_id_no = @pm_query_input
		UNION ALL
		
		-- DY1 低零利保人1 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 保人1' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_id_no1 = @pm_query_input
		UNION ALL
		
		-- DY1 低零利保人2 
		SELECT	kc_id_no as wk_id_no, kc_cust_name as wk_cust_name,'低零利 保人2' as wk_ctype_no, kc_case_no as wk_link_info,kc_loan_stat as wk_loan_stat
		FROM	kcsddb.kcsd.kc_customerloan2
		--FROM	OPENDATASOURCE( 'SQLOLEDB', 'Data Source=PCX01;User ID=sa;Password=neteater').kcsddb.kcsd.kc_customerloan2
		WHERE	kc_id_no2 = @pm_query_input
		------------------------------------------------------------------------------------------------------------------------------------
	END

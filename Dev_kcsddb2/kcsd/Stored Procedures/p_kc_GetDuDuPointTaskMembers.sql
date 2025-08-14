-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_GetDuDuPointTaskMembers]  @task_sql NVARCHAR(MAX) =NULL , @wk_list_no VARCHAR(10) =NULL ,@wk_sql_result	NVARCHAR(MAX) =NULL	OUTPUT		--結果回傳	
AS
BEGIN

--select @task_sql = N'select kc_target_ID from kcsd.kc_dudupointtasktarget_detail  WHERE kc_target_ID in (1,2) group by kc_target_ID ';
--select @wk_list_no = '2506250003'



CREATE TABLE #tmp_target_ID
(
kc_target_ID int
)

-- 執行並寫入結果表
EXEC('
INSERT INTO #tmp_target_ID 
' + @task_sql);


DECLARE @sql NVARCHAR(MAX);
DECLARE @select NVARCHAR(MAX);
DECLARE @union_sql NVARCHAR(MAX) = N'';
DECLARE @segment int;

DECLARE @select_kc_loan_totalfee NVARCHAR(MAX);
DECLARE @from_kc_loan_totalfee NVARCHAR(MAX);


DECLARE segment_cursor CURSOR FOR
    select kc_target_ID from #tmp_target_ID 
OPEN segment_cursor;
FETCH NEXT FROM segment_cursor INTO @segment;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @conditions NVARCHAR(MAX) = null;
    
    -- 累加該群組的 AND 條件
SELECT 
@conditions = ISNULL(@conditions + ' AND ', '') +
    '(' + QUOTENAME(kc_field_name) + ' ' + kc_operator_type + ' ' +
    CASE 
        WHEN ISNUMERIC(Value) = 1 THEN Value
        ELSE '''' + REPLACE(Value, '''', '''''') + ''''
    END + ')'

FROM kcsd.kc_dudupointtasktarget_detail
where kc_target_ID = @segment


    -- 組合成 SELECT 語句，加上群組名稱
    --SET @sql = '
    --SELECT kc_no, kc_age, kc_membertarget_type, kc_introduce_code, ''' +  CAST(@segment AS VARCHAR) + ''' AS segment_name
    --FROM kc_users 
    --WHERE ' + @conditions;

	set @select  = CASE WHEN CHARINDEX('kc_membertarget_type', @conditions) > 0 or CHARINDEX('kc_apply_stat', @conditions) > 0 or  CHARINDEX('kc_introduce_code', @conditions) > 0 
		THEN ' ,''Y'' as CP_type ' ELSE '  ,''N'' as CP_type ' END 
		 + 
        CASE WHEN CHARINDEX('kc_loan_fee', @conditions) > 0 or CHARINDEX('kc_loan_totalfee', @conditions) > 0 
		THEN ' ,''Y'' as CASE_type ' ELSE '  ,''N'' as CASE_type ' END 

	set @select_kc_loan_totalfee  =  CASE WHEN CHARINDEX('kc_loan_totalfee', @conditions) > 0 THEN ' kc_loan_totalfee  ' ELSE ' 0 as kc_loan_totalfee' END 

	set	@from_kc_loan_totalfee =  CASE WHEN CHARINDEX('kc_loan_totalfee', @conditions) > 0 THEN ' 
	left join (
		select cc.kc_member_no,sum(kc_loan_fee) kc_loan_totalfee 
		from kcsd.kc_customerloan cc 
		left join kcsd.kc_remittance rr on cc.kc_case_no = rr.kc_case_no 
		JOIN #tmp_time_table_with e2 ON kc_agent_date BETWEEN e2.kc_strt_date AND e2.kc_stop_date
		where  kc_loan_stat in (''G'',''N'') and cc.kc_prod_type = ''14''
		GROUP BY cc.kc_member_no
	) TC on m.kc_member_no = TC.kc_member_no ' ELSE ' ' END 
	
	



	-- 組合成 SELECT 語句，加上群組名稱
    SET @sql = '
    SELECT m.kc_member_no,cp.kc_membertarget_type,cp.kc_apply_stat,kc_loan_fee,'+@select_kc_loan_totalfee+',m.kc_introduce_code,kc_cp_date,cp.kc_cp_no,cu.kc_case_no' + @select + ', kc_agent_date, ''' +  CAST(@segment AS VARCHAR) + ''' AS segment_name
    from kcsd.kc_memberdata m
    left join kcsd.kc_cpdata cp on m.kc_cp_no = cp.kc_cp_no
    left join kcsd.kc_customerloan cu on m.kc_member_no = cu.kc_member_no and kc_loan_stat in (''G'',''N'') and cu.kc_prod_type = ''14''
    left join kcsd.kc_remittance r on cu.kc_case_no = r.kc_case_no  ' + @from_kc_loan_totalfee


    -- 找時間範圍內
    SET @sql = @sql + 
        CASE WHEN CHARINDEX('kc_membertarget_type', @conditions) > 0 or CHARINDEX('kc_apply_stat', @conditions) > 0 or  CHARINDEX('kc_introduce_code', @conditions) > 0 
		THEN ' JOIN #tmp_time_table_with e1
		ON kc_cp_date BETWEEN e1.kc_strt_date AND e1.kc_stop_date ' ELSE '' END 
		 + 
        CASE WHEN CHARINDEX('kc_loan_fee', @conditions) > 0 
		THEN ' JOIN #tmp_time_table_with e2
		ON kc_agent_date BETWEEN e2.kc_strt_date AND e2.kc_stop_date ' ELSE '' END 
	--合成where	
		+ ' WHERE ' + @conditions;

       

    -- 累加 UNION ALL
    SET @union_sql = @union_sql + 
        CASE WHEN LEN(@union_sql) > 0 THEN ' UNION ' ELSE '' END +
        @sql;


    FETCH NEXT FROM segment_cursor INTO @segment;
END
CLOSE segment_cursor;
DEALLOCATE segment_cursor;





--推薦碼需要補充
SELECT @union_sql = REPLACE(@union_sql, '[kc_introduce_code]', 'cp.[kc_introduce_code]');
SELECT @union_sql = REPLACE(@union_sql, '[kc_apply_stat]', 'cp.[kc_apply_stat]');

--PRINT @union_sql;
--EXEC sp_executesql @union_sql;

select @wk_sql_result = @union_sql

DROP TABLE #tmp_target_ID

END

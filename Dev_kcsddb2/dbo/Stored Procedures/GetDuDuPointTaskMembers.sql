-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE GetDuDuPointTaskMembers @task_sql NVARCHAR(MAX) =NULL , @wk_list_no VARCHAR(10) =NULL ,@wk_sql_result	NVARCHAR(MAX) =NULL	OUTPUT		--結果回傳	
AS
BEGIN

--select @task_sql = N'select kc_target_ID from kcsd.kc_dudupointtasktarget_detail  WHERE kc_target_ID in (1,2) group by kc_target_ID ';
--select @wk_list_no = '2506250003'

DECLARE @wk_taskstrt_date datetime;
DECLARE @wk_taskstop_date datetime;

select @wk_taskstrt_date = kc_taskstrt_date,@wk_taskstop_date = kc_taskstop_date from kcsd.kc_dudupointsend
where kc_list_type = 'B'
and kc_list_stat = 'B'
and kc_list_no = @wk_list_no

--活動狀態有效期限
CREATE TABLE #tmp_time_table
(
kc_stat varchar(1),
kc_time datetime
)
INSERT INTO #tmp_time_table VALUES ('B',@wk_taskstrt_date);
INSERT INTO #tmp_time_table select kc_list_stat,CreateDate from kcsd.kc_dudupointsendstatlog ;
INSERT INTO #tmp_time_table VALUES ('C',@wk_taskstop_date);

--活動有效期限
CREATE TABLE #tmp_time_table_with
(
kc_strt_date datetime,
kc_stop_date datetime
)

CREATE TABLE #tmp_target_ID
(
kc_target_ID int
)

-- 執行並寫入結果表
EXEC('
INSERT INTO #tmp_target_ID 
' + @task_sql);


DECLARE @sql NVARCHAR(MAX);
DECLARE @union_sql NVARCHAR(MAX) = N'';
DECLARE @segment int;

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
    SET @sql = '
    SELECT kc_no, kc_age, kc_membertarget_type, kc_introduce_code, ''' +  CAST(@segment AS VARCHAR) + ''' AS segment_name
    FROM kc_users 
    WHERE ' + @conditions;

	-- 組合成 SELECT 語句，加上群組名稱
    SET @sql = '
    SELECT m.kc_member_no,cp.kc_membertarget_type,cp.kc_apply_stat,kc_loan_fee,0 as kc_loan_totalfee,m.kc_introduce_code,kc_cp_date,cp.kc_cp_no,cu.kc_case_no,kc_agent_date, ''' +  CAST(@segment AS VARCHAR) + ''' AS segment_name
    from kcsd.kc_memberdata m
    left join kcsd.kc_cpdata cp on m.kc_cp_no = cp.kc_cp_no
    left join kcsd.kc_customerloan cu on m.kc_member_no = cu.kc_member_no and kc_loan_stat in (''G'',''N'')
    left join kcsd.kc_remittance r on cu.kc_case_no = r.kc_case_no  ' 
   -- WHERE ' + @conditions;

    -- 找時間範圍內
    SET @sql = @sql + 
        CASE WHEN CHARINDEX('kc_membertarget_type', @conditions) > 0 or CHARINDEX('kc_apply_stat', @conditions) > 0 or  CHARINDEX('kc_introduce_code', @conditions) > 0 
		THEN ' JOIN #tmp_time_table_with e1
		ON kc_cp_date BETWEEN e1.kc_strt_date AND e1.kc_stop_date ' ELSE '' END 
		 + 
        CASE WHEN CHARINDEX('kc_loan_fee', @conditions) > 0 or CHARINDEX('kc_loan_totalfee', @conditions) > 0 
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





 WITH status_with_rownum AS (
    SELECT 
        kc_stat, 
        kc_time AS status_time,
        ROW_NUMBER() OVER (ORDER BY kc_time) AS rn
    FROM #tmp_time_table
),
enable_ranges AS (
    SELECT 
        s1.status_time AS start_time,
        s2.status_time AS end_time
    FROM status_with_rownum s1
    JOIN status_with_rownum s2
      ON s1.rn + 1 = s2.rn
     AND s1.kc_stat = 'B'
     AND s2.kc_stat <> 'B'
)
INSERT INTO #tmp_time_table_with
select * from enable_ranges

--推薦碼需要補充
SELECT @union_sql = REPLACE(@union_sql, '[kc_introduce_code]', 'cp.[kc_introduce_code]');


--PRINT @union_sql;
--EXEC sp_executesql @union_sql;

select @wk_sql_result = @union_sql



DROP TABLE #tmp_target_ID
DROP TABLE #tmp_time_table
DROP TABLE #tmp_time_table_with

END

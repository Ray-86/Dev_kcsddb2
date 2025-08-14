-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [kcsd].[p_kc_DuDuPointSend]  @task_sql NVARCHAR(MAX) =NULL , @wk_list_no VARCHAR(10) =NULL ,@wk_run_code varchar(10)

AS
BEGIN


select @task_sql = N' select kc_member_no,kc_cp_no,kc_case_no,segment_name,CP_type,CASE_type from ( '+@task_sql +' ) as xx' ;

DECLARE @wk_taskstrt_date datetime;		--任務開始時間
DECLARE @wk_taskstop_date datetime;		--任務結束時間
DECLARE @wk_dudupoint int;				--發送的數量
DECLARE @wk_member_no varchar(15);		--符合資格的會員
DECLARE @wk_segment int;				--符合資格的原因
DECLARE @wk_sendat_type varchar(15);	--任務發送種類
DECLARE @wk_sendat_date datetime;		--任務預計種類發送時間
DECLARE @wk_limit_count int;			--上限
DECLARE @wk_totaled_count int;			--目前任務已發過
DECLARE @wk_cp_count int;	
DECLARE @wk_case_count int;	

DECLARE @wk_cp_no varchar(15);
DECLARE @wk_case_no varchar(15);
DECLARE @wk_CP_type varchar(1);
DECLARE @wk_CASE_type varchar(1);

--select @wk_list_no  = '2506250003'

select @wk_taskstrt_date = kc_taskstrt_date,@wk_taskstop_date = kc_taskstop_date,@wk_dudupoint = kc_dudupoint_fee,
@wk_sendat_type = kc_sendat_type,@wk_sendat_date = kc_sendat_date,@wk_limit_count = ISNULL(kc_limit_count,999999) from kcsd.kc_dudupointsend
where kc_list_type = 'B'
and kc_list_stat = 'B'
and kc_list_no = @wk_list_no


--select *  from kcsd.kc_dudupointsend
--where kc_list_type = 'B'
--and kc_list_stat = 'B'
--and kc_list_no = '2506250003'


CREATE TABLE #tmp_member_ID
(
kc_member_no varchar(15),
kc_cp_no varchar(15),
kc_case_no varchar(15),
kc_segment_name int ,
kc_CP_type varchar(1),
kc_CASE_type  varchar(1)
)
--假的測試用資料表
CREATE TABLE #tmp_dudupointsend_detail
(
kc_list_no  varchar(10),
kc_member_no varchar(15),
kc_dudupoint_fee int,
kc_expiration_date datetime,
IsEnable bit,
kc_segment int 
)

CREATE TABLE #tmp_dudupointsendlog
(
kc_tasklist_no  varchar(10),
kc_member_no varchar(15),
kc_cp_no varchar(10),
kc_case_no varchar(10)
)

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
);

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

PRINT @task_sql;


INSERT INTO #tmp_member_ID
EXEC sp_executesql @task_sql;

DECLARE pointsend_cursor CURSOR FOR
    select * from #tmp_member_ID
OPEN pointsend_cursor;
FETCH NEXT FROM pointsend_cursor INTO @wk_member_no,@wk_cp_no,@wk_case_no,@wk_segment,@wk_CP_type,@wk_CASE_type;

WHILE @@FETCH_STATUS = 0
BEGIN
   
   select @wk_totaled_count = COUNT(*) from kcsd.kc_dudupointsendlog where kc_tasklist_no = @wk_list_no and kc_member_no = @wk_member_no GROUP BY kc_tasklist_no 
   select @wk_cp_count = COUNT(*) from kcsd.kc_dudupointsendlog where kc_tasklist_no = @wk_list_no and kc_member_no = @wk_member_no and kc_cp_no = @wk_cp_no  GROUP BY kc_tasklist_no 
   select @wk_case_count = COUNT(*) from kcsd.kc_dudupointsendlog where kc_tasklist_no = @wk_list_no and kc_member_no = @wk_member_no and kc_case_no = @wk_case_no  GROUP BY kc_tasklist_no 

   IF(@wk_totaled_count is null or (@wk_totaled_count < @wk_limit_count and @wk_cp_count < 1 and @wk_case_count < 1))
     BEGIN
		--紀錄LOG
		select @wk_cp_no = case when @wk_CP_type = 'Y' then @wk_cp_no else '' end,@wk_case_no = case when @wk_CASE_type = 'Y' then @wk_case_no else '' end

		IF(@wk_run_code = 'EXEC')
			BEGIN
				INSERT INTO kcsd.kc_dudupointsend_detail (kc_list_no, kc_member_no, kc_dudupoint_fee, kc_expiration_date, IsEnable,kc_segment,CreatePerson,CreateDate)
					VALUES (@wk_list_no, @wk_member_no, @wk_dudupoint,CAST(CAST(YEAR(GETDATE()) AS VARCHAR) + '-12-31' AS DATETIME),0,@wk_segment,'super',GETDATE());
				--紀錄LOG
				INSERT INTO kcsd.kc_dudupointsendlog (kc_tasklist_no, kc_member_no, kc_cp_no, kc_case_no, CreatePerson,CreateDate)
					VALUES (@wk_list_no, @wk_member_no, @wk_cp_no, @wk_case_no,'super',GETDATE());
			END
		else
			BEGIN
				--測試用
				INSERT INTO #tmp_dudupointsend_detail (kc_list_no, kc_member_no, kc_dudupoint_fee, kc_expiration_date, IsEnable,kc_segment)
					VALUES (@wk_list_no, @wk_member_no, @wk_dudupoint,CAST(CAST(YEAR(GETDATE()) AS VARCHAR) + '-12-31' AS DATETIME),0,@wk_segment);
				INSERT INTO #tmp_dudupointsendlog (kc_tasklist_no, kc_member_no, kc_cp_no, kc_case_no)
					VALUES (@wk_list_no, @wk_member_no, @wk_cp_no, @wk_case_no);
			END
     END



    FETCH NEXT FROM pointsend_cursor INTO @wk_member_no,@wk_cp_no,@wk_case_no,@wk_segment,@wk_CP_type,@wk_CASE_type;
END
CLOSE pointsend_cursor;
DEALLOCATE pointsend_cursor;

insert into fake_dudupointsend_detail
select * from #tmp_dudupointsend_detail
--select * from #tmp_dudupointsendlog

DROP TABLE #tmp_time_table
DROP TABLE #tmp_time_table_with
DROP TABLE #tmp_member_ID
DROP TABLE #tmp_dudupointsend_detail
DROP TABLE #tmp_dudupointsendlog







END

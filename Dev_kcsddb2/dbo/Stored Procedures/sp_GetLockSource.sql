-- =============================================
-- Author:		rachen
-- Create date: 2012.11.01
-- Description:	取得資料鎖定的主要來源.
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetLockSource]
AS
BEGIN

	set nocount on;

	create table #sp_who2 (
		[SPID] smallint null ,
		[Status] nvarchar(30) null ,
		[Login]	nvarchar(30) null ,
		[HostName] nvarchar(30) null ,	
		[BlkBy]	varchar(3000) null , /*CommandText*/
		[DBName] nvarchar(100) null ,	
		[Command] nvarchar(100) null ,
		[CPUTime] int null ,
		[DiskIO] int null ,
		[LastBatch]	varchar(30) null , /*IsLockSource*/
		[ProgramName] nvarchar(60) null ,
		[BlkBySPID] smallint null
	);
	/*把 sp_who2 的結果塞入 temp 表單 */
	insert into #sp_who2 exec sp_who2;

	/*將 [BlkBy]處理成數字，以利後續處理 */
	update #sp_who2 set [BlkBySPID] = convert(smallint,Replace(Rtrim(Ltrim(BlkBy)),'.','')) , [BlkBy] = '' , [LastBatch] = '0';

	declare @SPID smallint;
	declare @CommandText varchar(3000);
	declare @Handle binary(20);

	declare SPIDList cursor  for
		select distinct M.SPID
		from #sp_who2 M 
		join #sp_who2 D on M.SPID = D.BlkBySPID 
		where M.BlkBySPID = 0 or M.SPID = D.SPID;
	open SPIDList;

	while 1 = 1 begin

		fetch next from SPIDList into @SPID;
		if ( @@fetch_status <> 0 ) goto WhileEnd

		set @CommandText = null;
		set @Handle = (select top 1 sql_handle from master.dbo.sysprocesses where spid = @SPID);
		set @CommandText = (select top 1 convert(varchar(3000),[text]) from ::fn_get_sql(@Handle));
		update #sp_who2 set [BlkBy] = isnull(@CommandText,'') , [LastBatch] = 1 where [SPID] = @SPID;

	end

	WhileEnd:

	close SPIDList;
	deallocate SPIDList;

	select SPID, Status, Login , HostName , DBName , Command , CPUTime , DiskIO ,  ProgramName , BlkBySPID ,
		BlkBy [CommandText] , 
		LastBatch [IsLockSource]
	from #sp_who2
	where LastBatch = '1';

END

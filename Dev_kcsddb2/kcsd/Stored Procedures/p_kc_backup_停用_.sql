CREATE PROCEDURE [kcsd].[p_kc_backup(停用)]
	@databaseName VARCHAR(50),
	@backupMedia CHAR(1)
AS

DECLARE @backupFilePath VARCHAR(200)

SET @backupFilePath = '\\Dys01s\_BACKUP'+ @backupMedia +'\SQL\DYS01-' + @databaseName + '.bak'

/*DATEPART sunday:1 mondat:2*/
IF DATEPART(weekday, getdate()) = '1' 
	BEGIN
		BACKUP DATABASE @databaseName TO  DISK = @backupFilePath WITH INIT,RETAINDAYS = 41
	END
ELSE
	BEGIN
		BACKUP DATABASE @databaseName TO  DISK = @backupFilePath WITH DIFFERENTIAL
	END

CREATE PROCEDURE [kcsd].[p_update_all_stats]
AS
/*
	This procedure will run UPDATE STATISTICS against
	all user-defined tables within this database.
*/
DECLARE @tablename varchar(30)
DECLARE @tablename_header varchar(75)
DECLARE tnames_cursor CURSOR FOR SELECT name FROM sysobjects 
	WHERE type = 'U'
OPEN tnames_cursor
FETCH NEXT FROM tnames_cursor INTO @tablename
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SELECT @tablename_header = "Updating " + 
			RTRIM(UPPER(@tablename))
		SELECT @tablename_header
		EXEC ("UPDATE STATISTICS " + @tablename )
	END
	FETCH NEXT FROM tnames_cursor INTO @tablename
END
PRINT " "
PRINT " "
SELECT @tablename_header = "*************  NO MORE TABLES" +
			 "  *************" 
PRINT @tablename_header
PRINT " "
PRINT "Statistics have been updated for all tables."
DEALLOCATE tnames_cursor

CREATE    PROCEDURE [kcsd].[p_kc_getservertime] AS
DECLARE	
	@pm_server_time datetime

	SELECT @pm_server_time =  GETDATE()

	SELECT @pm_server_time AS kc_server_time

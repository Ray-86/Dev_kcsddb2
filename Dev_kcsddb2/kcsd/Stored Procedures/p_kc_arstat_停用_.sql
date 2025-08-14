CREATE PROCEDURE [kcsd].[p_kc_arstat(停用)]
@pm_strt_date datetime=NULL,
@pm_stop_date datetime=NULL
AS
SELECT	GETDATE()

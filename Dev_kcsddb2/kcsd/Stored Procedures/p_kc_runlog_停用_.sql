CREATE PROCEDURE [kcsd].[p_kc_runlog(停用)]
	@pm_proc_name varchar(20)
AS

INSERT	kcsd.kc_runlog
	(kc_proc_name, kc_updt_date, kc_updt_user)
VALUES	(@pm_proc_name, GETDATE(), USER)

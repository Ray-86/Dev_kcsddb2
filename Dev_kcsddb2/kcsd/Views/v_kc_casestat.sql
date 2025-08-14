CREATE VIEW [kcsd].[v_kc_casestat] AS 
	SELECT  kc_case_no, kc_loan_stat
	FROM	
	kcsddb2.kcsd.kc_customerloan
	--OPENDATASOURCE ('SQLOLEDB','Data Source=DYS01;User ID=sa;Password=neteater' ).kcsddb2.kcsd.kc_customerloan
    UNION ALL
    SELECT	kc_cp_no, kc_apply_stat
    FROM	
	kcsddb2.kcsd.kc_cpdata
	--OPENDATASOURCE ('SQLOLEDB','Data Source=DYS01;User ID=sa;Password=neteater' ).kcsddb2.kcsd.kc_cpdata

-- =============================================
-- View DY3
-- =============================================
CREATE VIEW [kcsd].[v_kc_customerloan_dy3]
AS 
	SELECT *
    FROM
	kcsddb3.kcsd.kc_customerloan
	--OPENDATASOURCE('SQLOLEDB','Data Source=PCX01;User ID=sa;Password=neteater' ).kcsddb3.kcsd.kc_customerloan

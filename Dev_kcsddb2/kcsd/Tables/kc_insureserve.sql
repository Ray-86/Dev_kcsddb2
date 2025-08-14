CREATE TABLE [kcsd].[kc_insureserve] (
    [kc_user_name] VARCHAR (20)  NOT NULL,
    [kc_rese_type] VARCHAR (1)   NOT NULL,
    [kc_insu_no]   VARCHAR (8)   NULL,
    [kc_updt_date] SMALLDATETIME NULL
);


GO


CREATE  TRIGGER [kcsd].[t_kc_insureserve_i] ON [kcsd].[kc_insureserve] 
FOR INSERT NOT FOR REPLICATION
AS

DECLARE @wk_rese_type	char(1),
	@wk_insu_no	varchar(20),
	@wk_insu_no2	varchar(20),
	@wk_maxno	int,
	@wk_rowcount	int

BEGIN TRANSACTION
	SELECT	@wk_rese_type = kc_rese_type
	FROM	inserted
	
	DELETE FROM kcsd.kc_insureserve
	WHERE	kc_user_name = USER
	AND	kc_insu_no <> NULL

	IF	@wk_rese_type = 'A'
	BEGIN
		/* from table */
		SELECT	@wk_insu_no = MAX(kc_insu_no)
		FROM	kcsd.kc_insurance
		WHERE	kc_insu_no NOT LIKE '½¦©╔%'

		/* from reserve */
		SELECT	@wk_insu_no2 = MAX(kc_insu_no)
		FROM	kcsd.kc_insureserve
		WHERE	kc_insu_no NOT LIKE '½¦©╔%'

		IF	@wk_insu_no2 > @wk_insu_no
			SELECT	@wk_insu_no = @wk_insu_no2

		SELECT	@wk_maxno= CONVERT(int, @wk_insu_no) + 1
		SELECT	@wk_insu_no = LTRIM(RTRIM(STR(@wk_maxno, 8)))
		SELECT	@wk_insu_no = '00000000' + @wk_insu_no
		SELECT	@wk_insu_no = RIGHT(@wk_insu_no, 6)
		
		UPDATE	kcsd.kc_insureserve
		SET	kc_insu_no = @wk_insu_no,
			kc_updt_date = GETDATE()
		WHERE	kc_user_name = USER
		AND	kc_rese_type = @wk_rese_type
	END

	IF	@wk_rese_type = 'D'
	BEGIN
		SELECT	@wk_insu_no = NULL

		SELECT	@wk_insu_no = MIN(kc_insu_no)
		FROM	kcsd.kct_insuremano
		WHERE	kc_insu_no NOT IN
			(SELECT kc_insu_no
			FROM kcsd.kc_insurance)
		AND	kc_insu_no NOT IN
			(SELECT kc_insu_no
			FROM kcsd.kc_insureserve)
			
		UPDATE	kcsd.kc_insureserve
		SET	kc_insu_no = @wk_insu_no,
			kc_updt_date = GETDATE()
		WHERE	kc_user_name = USER
		AND	kc_rese_type = @wk_rese_type
	END


COMMIT TRANSACTION



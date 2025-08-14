CREATE TABLE [kcsd].[kc_cpresult] (
    [kc_cp_no]       VARCHAR (10)  NOT NULL,
    [kc_case_no]     VARCHAR (10)  NOT NULL,
    [kc_cust_type]   VARCHAR (10)  NULL,
    [kc_cust_name]   VARCHAR (10)  NULL,
    [kc_id_no]       VARCHAR (10)  NULL,
    [kc_papa_name]   VARCHAR (10)  NULL,
    [kc_mama_name]   VARCHAR (10)  NULL,
    [kc_mate_name]   VARCHAR (10)  NULL,
    [kc_cust_name1]  VARCHAR (10)  NULL,
    [kc_id_no1]      VARCHAR (10)  NULL,
    [kc_papa_name1]  VARCHAR (10)  NULL,
    [kc_mama_name1]  VARCHAR (10)  NULL,
    [kc_mate_name1]  VARCHAR (10)  NULL,
    [kc_cust_name2]  VARCHAR (10)  NULL,
    [kc_id_no2]      VARCHAR (10)  NULL,
    [kc_papa_name2]  VARCHAR (10)  NULL,
    [kc_mama_name2]  VARCHAR (10)  NULL,
    [kc_mate_name2]  VARCHAR (10)  NULL,
    [kc_area_code]   VARCHAR (2)   NULL,
    [kc_cp_stat]     VARCHAR (2)   NULL,
    [kc_cust_nameu]  NVARCHAR (60) NULL,
    [kc_papa_nameu]  NVARCHAR (60) NULL,
    [kc_mama_nameu]  NVARCHAR (60) NULL,
    [kc_mate_nameu]  NVARCHAR (60) NULL,
    [kc_cust_name1u] NVARCHAR (60) NULL,
    [kc_papa_name1u] NVARCHAR (60) NULL,
    [kc_mama_name1u] NVARCHAR (60) NULL,
    [kc_mate_name1u] NVARCHAR (60) NULL,
    [kc_cust_name2u] NVARCHAR (60) NULL,
    [kc_papa_name2u] NVARCHAR (60) NULL,
    [kc_mama_name2u] NVARCHAR (60) NULL,
    [kc_mate_name2u] NVARCHAR (60) NULL
);


GO
CREATE NONCLUSTERED INDEX [i_kc_cpresult]
    ON [kcsd].[kc_cpresult]([kc_cp_no] ASC) WITH (FILLFACTOR = 20);


GO
CREATE NONCLUSTERED INDEX [i_kc_cpresult_1]
    ON [kcsd].[kc_cpresult]([kc_area_code] ASC) WITH (FILLFACTOR = 20);


GO
CREATE NONCLUSTERED INDEX [i_kc_cpresult_2]
    ON [kcsd].[kc_cpresult]([kc_case_no] ASC);


GO

CREATE  TRIGGER [kcsd].[t_kc_cpresult_iu] ON [kcsd].[kc_cpresult]
FOR INSERT, UPDATE, DELETE NOT FOR REPLICATION
AS
DECLARE	@wk_cp_no varchar(10),
	@wk_area_code varchar(2),
	@wk_emp_code varchar(6)

SELECT	@wk_cp_no = NULL, @wk_area_code = NULL, @wk_emp_code = NULL

SELECT	@wk_cp_no = kc_cp_no, @wk_area_code = kc_area_code
FROM	inserted

IF	(@@SERVERNAME = 'DYS01'  or  @@SERVERNAME = 'DYAP01')
	BEGIN

	/* 填入分公司 */
	IF	@wk_area_code IS NULL
	BEGIN
		SELECT	@wk_area_code = e.AreaCode
		FROM	kcsd.kc_cpdata c, kcsd.v_Employee e
		WHERE	c.kc_cp_no = @wk_cp_no
		AND	c.kc_emp_code = e.EmpCode

		IF	@wk_area_code IS NOT NULL
			UPDATE	kcsd.kc_cpresult
			SET	kc_area_code = @wk_area_code
			WHERE	kc_cp_no = @wk_cp_no
	END
END





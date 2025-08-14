CREATE PROCEDURE [kcsd].[p_kc_addrhistory_create]
AS
DECLARE	@wk_case_no	varchar(10),

	@wk_addr_type	varchar(2),
	@wk_addr_data	varchar(100),
	@wk_updt_date	datetime,
	@wk_updt_user	varchar(10),
	@wk_count	int,

	/* Ñ╗ñH */
	@wk_id_no	varchar(10),
	@wk_perm_addr	varchar(100),
	@wk_curr_addr	varchar(100),
	@wk_comp_addr	varchar(100),
	@wk_trans_addr	varchar(100),
	@wk_perm_phone	varchar(20),
	@wk_curr_phone	varchar(20),
	@wk_comp_phone	varchar(20),
	@wk_mobil_no	varchar(12),

	/* ½OñH1 */
	@wk_id_no1	varchar(10),
	@wk_perm_addr1	varchar(100),
	@wk_curr_addr1	varchar(100),
	@wk_comp_addr1	varchar(100),
	@wk_perm_phone1	varchar(20),
	@wk_curr_phone1	varchar(20),
	@wk_comp_phone1	varchar(20),
	@wk_mobil_no1	varchar(12),

	/* ½OñH2 */
	@wk_id_no2	varchar(10),
	@wk_perm_addr2	varchar(100),
	@wk_curr_addr2	varchar(100),
	@wk_comp_addr2	varchar(100),
	@wk_perm_phone2	varchar(20),
	@wk_curr_phone2	varchar(20),
	@wk_comp_phone2	varchar(20),
	@wk_mobil_no2	varchar(12)

SELECT	@wk_case_no=NULL

/* ñú║ÌÁ▓«Î¬║ */
DECLARE	cursor_case_no	CURSOR
FOR	SELECT	kc_case_no
	FROM	kcsd.kc_customerloan
	WHERE	kc_loan_stat <> 'C'

OPEN cursor_case_no
FETCH NEXT FROM cursor_case_no INTO @wk_case_no

WHILE (@@FETCH_STATUS = 0)
BEGIN
	/* init */
	SELECT	@wk_addr_data=NULL, @wk_trans_addr=NULL,
		@wk_id_no=NULL, @wk_perm_addr=NULL, @wk_curr_addr=NULL, @wk_comp_addr=NULL,
		@wk_perm_phone=NULL, @wk_curr_phone=NULL, @wk_comp_phone=NULL, @wk_mobil_no=NULL,
		@wk_id_no1=NULL, @wk_perm_addr1=NULL, @wk_curr_addr1=NULL, @wk_comp_addr1=NULL,
		@wk_perm_phone1=NULL, @wk_curr_phone1=NULL, @wk_comp_phone1=NULL, @wk_mobil_no1=NULL,
		@wk_id_no2=NULL, @wk_perm_addr2=NULL, @wk_curr_addr2=NULL, @wk_comp_addr2=NULL,
		@wk_perm_phone2=NULL, @wk_curr_phone2=NULL, @wk_comp_phone2=NULL, @wk_mobil_no2=NULL


	/* get case data */
	SELECT	@wk_id_no = kc_id_no, @wk_id_no1 = kc_id_no1, @wk_id_no2 = kc_id_no2,
		@wk_perm_addr=kc_perm_addr,@wk_perm_addr1=kc_perm_addr1,@wk_perm_addr2=kc_perm_addr2,
		@wk_curr_addr=kc_curr_addr,@wk_curr_addr1=kc_curr_addr1,@wk_curr_addr2=kc_curr_addr2,
		@wk_comp_addr=kc_comp_addr,
		@wk_trans_addr=kc_trans_addr,
		@wk_perm_phone=kc_perm_phone,@wk_perm_phone1=kc_perm_phone1,@wk_perm_phone2=kc_perm_phone2,
		@wk_curr_phone=kc_curr_phone,@wk_curr_phone1=kc_curr_phone1,@wk_curr_phone2=kc_curr_phone2,
		@wk_comp_phone=kc_comp_phone,@wk_comp_phone1=kc_comp_phone1,@wk_comp_phone2=kc_comp_phone2,
		@wk_mobil_no=kc_mobil_no, @wk_mobil_no1=kc_mobil_no1, @wk_mobil_no2=kc_mobil_no2

	FROM	kcsd.kc_customerloan
	WHERE	kc_case_no = @wk_case_no

	/* Ñ╗ñH */
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A1', @wk_perm_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A2', @wk_curr_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A3', @wk_comp_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'A4', @wk_trans_addr
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P1', @wk_perm_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P2', @wk_curr_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P3', @wk_comp_phone
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no, 'P4', @wk_mobil_no

	/* ½OñH1 */
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A1', @wk_perm_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A2', @wk_curr_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'A3', @wk_comp_addr1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P1', @wk_perm_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P2', @wk_curr_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P3', @wk_comp_phone1
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no1, 'P4', @wk_mobil_no1

	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A1', @wk_perm_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A2', @wk_curr_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'A3', @wk_comp_addr2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P1', @wk_perm_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P2', @wk_curr_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P3', @wk_comp_phone2
	EXECUTE	kcsd.p_kc_addrhistory_create_sub1 @wk_id_no2, 'P4', @wk_mobil_no2


	FETCH NEXT FROM cursor_case_no INTO @wk_case_no
END

DEALLOCATE	cursor_case_no

CREATE  PROCEDURE [kcsd].[p_kc_profitexercise_sub1]
@pm_case_no varchar(10),
@pm_loan_cost int
AS
DECLARE	@wk_credit_fee	int,
	@wk_insu_fee	int,
	@wk_totm_fee	int,
	@wk_aux_fee	int,
	@wk_give_amt	int,
	@wk_cred_chk	bit,
	@wk_check_amt	int,		/* 徵信人數 */
	@wk_cust_name1	varchar(20),
	@wk_cust_name2	varchar(20)
/*wk_loan_cost: [wk_credit_fee]+[wk_insu_fee]+[wk_totm_fee]+[wk_aux_fee]+[wk_give_amt]*/
SELECT	@pm_loan_cost=0, @wk_credit_fee=0, @wk_insu_fee=0, @wk_totm_fee=0,
	@wk_aux_fee=0, @wk_give_amt=0,
	@wk_cred_chk=0, @wk_cust_name1=NULL, @wk_cust_name2=NULL, @wk_check_amt=0

SELECT	@wk_cred_chk = kc_cred_chk
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

/* 徵信費 */
SELECT	@wk_cust_name1 = kc_cust_name1, @wk_cust_name2 = kc_cust_name2
FROM	kcsd.kc_customerloan
WHERE	kc_case_no = @pm_case_no

SELECT	@wk_check_amt = @wk_check_amt + 1
IF	@wk_cust_name1 IS NOT NULL
	SELECT	@wk_check_amt = @wk_check_amt + 1

IF	@wk_cust_name2 IS NOT NULL
	SELECT	@wk_check_amt = @wk_check_amt + 1

/* SELECT	@wk_credit_fee = */
	
/* SELECT	@wk_check_amt = IIf(IsNull([kc_cust_name1]),0,1)+IIf(IsNull([kc_cust_name2]),0,1)+1

 IIf([kc_cred_chk]=0,0,[wk_nchecker]*100+100)
*/

CREATE TABLE [kcsd].[kc_blacklistlist] (
    [kc_id_no]        VARCHAR (10)  NOT NULL,
    [kc_item_no]      SMALLINT      NOT NULL,
    [kc_black_reason] VARCHAR (255) NULL,
    [kc_updt_date]    SMALLDATETIME NULL,
    [kc_updt_user]    VARCHAR (10)  NULL,
    CONSTRAINT [PK_kc_blacklistlist] PRIMARY KEY CLUSTERED ([kc_id_no] ASC, [kc_item_no] ASC)
);


GO

-- =============================================
-- 02/14/09 KC: Black list can have many events
-- =============================================
CREATE  TRIGGER [kcsd].[t_kc_blacklistlist_iu] ON [kcsd].[kc_blacklistlist]
FOR INSERT,UPDATE NOT FOR REPLICATION
AS

DECLARE	@wk_id_no		varchar(10),
	@wk_black_reason	varchar(255),
	@wk_item_no			int ,
	@wk_updt_user		varchar(10)

SELECT	@wk_id_no = kc_id_no, @wk_black_reason = kc_black_reason,
	@wk_item_no = kc_item_no, @wk_updt_user = kc_updt_user
FROM	inserted

IF	USER = 'dbo'
	RETURN

IF	@wk_item_no IS NULL
BEGIN
	SELECT	@wk_item_no = ISNULL(MAX(kc_item_no), 0) + 1
	FROM	kcsd.kc_blacklistlist
	WHERE	kc_id_no = @wk_id_no

	UPDATE	kcsd.kc_blacklistlist
	SET	kc_item_no = @wk_item_no
	WHERE	kc_id_no = @wk_id_no
	AND	kc_item_no IS NULL
END


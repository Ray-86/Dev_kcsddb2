CREATE TABLE [kcsd].[kc_cpdatalog(停用)] (
    [kc_cp_no]          VARCHAR (10)  NULL,
    [kc_updt_user]      VARCHAR (20)  NULL,
    [kc_updt_date]      SMALLDATETIME NULL,
    [kc_apply_stat_old] VARCHAR (2)   NULL,
    [kc_apply_stat]     VARCHAR (2)   NULL,
    [kc_rej_note_old]   VARCHAR (150) NULL,
    [kc_rej_note]       VARCHAR (150) NULL,
    [kc_cred_stat_old]  VARCHAR (1)   NULL,
    [kc_cred_stat]      VARCHAR (1)   NULL,
    [kc_drive_flag_old] VARCHAR (1)   NULL,
    [kc_drive_flag]     VARCHAR (1)   NULL
);


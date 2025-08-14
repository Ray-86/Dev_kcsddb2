CREATE TABLE [kcsd].[kc_smslog] (
    [id]       INT      IDENTITY (1, 1) NOT NULL,
    [ip]       BIGINT   NOT NULL,
    [sendcnt]  TINYINT  NOT NULL,
    [lasttime] DATETIME NOT NULL,
    CONSTRAINT [PK_sys_sendsmslog] PRIMARY KEY CLUSTERED ([id] ASC)
);


CREATE TABLE [kcsd].[_bobo_cust] (
    [uid]          INT           IDENTITY (100000, 1) NOT NULL,
    [idno]         VARCHAR (10)  NOT NULL,
    [username]     NVARCHAR (50) NULL,
    [password]     VARCHAR (50)  NOT NULL,
    [email]        VARCHAR (50)  NULL,
    [mobile]       VARCHAR (50)  NULL,
    [chatid]       INT           NULL,
    [storeid]      INT           NULL,
    [mallagid]     SMALLINT      NULL,
    [avatar]       VARCHAR (50)  NULL,
    [paycredits]   INT           NULL,
    [rankcredits]  INT           NULL,
    [verifyemail]  TINYINT       NULL,
    [verifymobile] TINYINT       NULL,
    [liftbantime]  DATETIME      NULL,
    [salt]         NVARCHAR (50) NULL,
    [isenable]     BIT           NULL,
    CONSTRAINT [PK_bobo_cust] PRIMARY KEY CLUSTERED ([uid] ASC)
);


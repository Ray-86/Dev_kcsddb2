CREATE TABLE [kcsd].[_AccountUser] (
    [Uid]          INT           IDENTITY (100000, 1) NOT NULL,
    [Ucode1]       VARCHAR (10)  NOT NULL,
    [Ucode2]       VARCHAR (10)  NOT NULL,
    [Username]     NVARCHAR (50) NULL,
    [Password]     VARCHAR (50)  NOT NULL,
    [Email]        VARCHAR (50)  NULL,
    [Mobile]       VARCHAR (50)  NULL,
    [Chatid]       INT           NULL,
    [Storeid]      INT           NULL,
    [Mallagid]     SMALLINT      NULL,
    [Avatar]       VARCHAR (50)  NULL,
    [Paycredits]   INT           NULL,
    [Rankcredits]  INT           NULL,
    [Verifyemail]  TINYINT       NULL,
    [Verifymobile] TINYINT       NULL,
    [Liftbantime]  DATETIME      NULL,
    [Salt]         NVARCHAR (50) NULL,
    [IsEnable]     BIT           NULL,
    CONSTRAINT [PK_bobo_agent] PRIMARY KEY CLUSTERED ([Uid] ASC)
);


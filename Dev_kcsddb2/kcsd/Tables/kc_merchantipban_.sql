CREATE TABLE [kcsd].[kc_merchantipban_] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [longip]       BIGINT        NOT NULL,
    [CreatePerson] VARCHAR (10)  NOT NULL,
    [CreateDate]   DATETIME      NOT NULL,
    [kc_updt_user] VARCHAR (10)  NOT NULL,
    [kc_updt_date] SMALLDATETIME NOT NULL,
    CONSTRAINT [PK_kc_merchantipban] PRIMARY KEY CLUSTERED ([id] ASC)
);


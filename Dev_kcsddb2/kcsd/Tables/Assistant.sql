CREATE TABLE [kcsd].[Assistant] (
    [AssistantCode] VARCHAR (50) NOT NULL,
    [AssistantName] VARCHAR (50) NOT NULL,
    [AssistantUser] VARCHAR (4)  NULL,
    [AreaCode]      VARCHAR (2)  NOT NULL,
    [IsEnable]      BIT          NOT NULL,
    CONSTRAINT [PK_Assistant] PRIMARY KEY CLUSTERED ([AssistantCode] ASC)
);


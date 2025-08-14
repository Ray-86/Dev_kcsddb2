CREATE TABLE [kcsd].[Delegate] (
    [DelegateCode]    VARCHAR (10) NOT NULL,
    [DelegateName]    VARCHAR (10) NOT NULL,
    [AreaCode]        VARCHAR (2)  NOT NULL,
    [DelegateUser]    VARCHAR (4)  NULL,
    [ExtensionNumber] VARCHAR (5)  CONSTRAINT [DF_Delegate_ExtensionNumber] DEFAULT ('') NOT NULL,
    [IsEnable]        BIT          CONSTRAINT [DF_Delegate_IsEnable] DEFAULT ((0)) NOT NULL,
    [IsEnable2]       BIT          NOT NULL,
    [IsEnable3]       BIT          NULL,
    [ContactName]     VARCHAR (10) CONSTRAINT [DF_Delegate_ContactName] DEFAULT ('') NOT NULL,
    [ContactData]     VARCHAR (50) CONSTRAINT [DF_Delegate_ContactData] DEFAULT ('') NOT NULL,
    [ContactData2]    VARCHAR (50) CONSTRAINT [DF_Delegate_ContactData2] DEFAULT ('') NOT NULL,
    [ContactData3]    VARCHAR (50) CONSTRAINT [DF_Delegate_ContactData3] DEFAULT ('') NOT NULL,
    [kc_delay_code]   VARCHAR (4)  NULL,
    CONSTRAINT [PK_Delegate] PRIMARY KEY CLUSTERED ([DelegateCode] ASC)
);


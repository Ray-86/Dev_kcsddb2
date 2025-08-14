CREATE TABLE [kcsd].[kc_linenotify] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [kc_sender_no] VARCHAR (10)   NOT NULL,
    [kc_rcpt_no]   VARCHAR (10)   NOT NULL,
    [kc_notify_id] VARCHAR (43)   NOT NULL,
    [kc_msg_date]  DATETIME       NOT NULL,
    [kc_msg_body]  VARCHAR (300)  NOT NULL,
    [kc_send_stat] INT            NULL,
    [kc_send_date] DATETIME       NULL,
    [CreatePerson] VARCHAR (20)   NULL,
    [CreateDate]   DATETIME       NULL,
    [kc_updt_user] VARCHAR (20)   NULL,
    [kc_updt_date] DATETIME       NULL,
    [kc_line_memo] NVARCHAR (150) NULL,
    CONSTRAINT [PK_kc_linenotify] PRIMARY KEY CLUSTERED ([ID] ASC)
);


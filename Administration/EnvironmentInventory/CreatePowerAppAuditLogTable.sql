/****** Object:  Table [dbo].[PowerAppAuditLog]    Script Date: 5/28/2019 9:58:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PowerAppAuditLog](
	[auditLogID] [nchar](40) NOT NULL,
	[environmentID] [nvarchar](50) NOT NULL,
	[operation] [nvarchar](20) NOT NULL,
	[creationTime] [datetime] NOT NULL,
	[resultStatus] [nchar](10) NOT NULL,
	[userKey] [nvarchar](50) NOT NULL,
	[appID] [nvarchar](50) NOT NULL,
	[version] [smallint] NOT NULL,
 CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED 
(
	[auditLogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


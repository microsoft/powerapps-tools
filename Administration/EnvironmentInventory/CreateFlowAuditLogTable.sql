/****** Object:  Table [dbo].[FlowAuditLog]    Script Date: 5/28/2019 9:58:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FlowAuditLog](
	[auditLogID] [nchar](40) NOT NULL,
	[environmentID] [nvarchar](50) NOT NULL,
	[operation] [nvarchar](20) NOT NULL,
	[creationTime] [datetime] NOT NULL,
	[resultStatus] [nchar](10) NOT NULL,
	[clientIP] [nchar](16) NULL,
	[flowID] [nchar](36) NOT NULL,
	[flowConnectorNames] [nvarchar](200) NULL,
	[sharingPermission] [smallint] NULL,
	[userTypeInitiated] [smallint] NULL,
	[userKey] [nvarchar](50) NOT NULL,
	[userType] [smallint] NOT NULL,
	[version] [smallint] NOT NULL,
 CONSTRAINT [PK_FlowAuditLog] PRIMARY KEY CLUSTERED 
(
	[auditLogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/****** Object:  Table [dbo].[Environment]    Script Date: 5/21/2019 4:59:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Environment](
	[environmentID] [nvarchar](50) NOT NULL,
	[displayName] [nvarchar](60) NULL,
	[description] [nvarchar](50) NULL,
	[createdTime] [datetime] NULL,
	[creatorTenantId] [nchar](36) NULL,
	[creatorUPN] [nvarchar](50) NULL,
	[creatorDisplayName] [nvarchar](50) NULL,
	[environmentType] [nchar](10) NULL,
	[isDefault] [bit] NULL,
	[expirationTime] [datetime] NULL,
	[type] [nchar](20) NULL,
	[friendlyName] [nvarchar](60) NULL,
	[uniqueName] [nchar](12) NULL,
	[version] [nchar](10) NULL,
	[domainName] [nchar](25) NULL,
	[lastRecorded] [datetime] NULL,
 CONSTRAINT [PK_Environment] PRIMARY KEY CLUSTERED 
(
	[environmentID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Environment] ADD  CONSTRAINT [DF_Environment_isDefault]  DEFAULT ((0)) FOR [isDefault]
GO


/****** Object:  Table [dbo].[PowerApp]    Script Date: 5/21/2019 4:59:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PowerApp](
	[appID] [nvarchar](50) NOT NULL,
	[environmentID] [nvarchar](50) NOT NULL,
	[formFactor] [nchar](10) NULL,
	[creatorUPN] [nvarchar](50) NULL,
	[createdTime] [datetime] NULL,
	[lastModifiedTime] [datetime] NULL,
	[lastModifiedUPN] [nvarchar](50) NULL,
	[displayName] [nvarchar](80) NULL,
	[description] [nvarchar](max) NULL,
	[sharedUsersCount] [int] NULL,
	[sharedGroupsCount] [int] NULL,
	[appOpenURI] [nvarchar](80) NULL,
	[isFeaturedApp] [bit] NULL,
	[bypassConsent] [bit] NULL,
	[isSharePointForm] [bit] NULL,
	[isHeroApp] [bit] NULL,
	[isEnvironmentALMMode] [bit] NULL,
	[lastRecorded] [datetime] NULL,
 CONSTRAINT [PK_PowerApp] PRIMARY KEY CLUSTERED 
(
	[appID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PowerApps MetaData' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PowerApp'
GO


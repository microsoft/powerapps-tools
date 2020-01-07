/****** Object:  Table [dbo].[PowerAppConnection]    Script Date: 5/21/2019 4:59:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PowerAppConnection](
	[appIDconnectorName] [nvarchar](100) NOT NULL,
	[appID] [nvarchar](50) NOT NULL,
	[connectorName] [nvarchar](50) NOT NULL,
	[dataSources] [nvarchar](50) NULL,
	[isOnPremiseConnection] [bit] NULL,
	[bypassConsent] [bit] NULL,
	[isPremiumAPI] [bit] NULL,
	[isCustomAPIConnection] [bit] NULL,
	[iconUri] [nvarchar](max) NULL,
	[lastRecorded] [datetime] NULL,
 CONSTRAINT [PK_PowerAppConnection_1] PRIMARY KEY CLUSTERED 
(
	[appIDconnectorName] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


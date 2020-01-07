/****** Object:  Table [dbo].[Flow]    Script Date: 5/21/2019 4:59:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Flow](
	[flowID] [nvarchar](50) NOT NULL,
	[environmentID] [nvarchar](50) NOT NULL,
	[displayName] [nvarchar](100) NULL,
	[createdTime] [datetime] NULL,
	[lastModifiedTime] [datetime] NULL,
	[creatorUPN] [nvarchar](50) NULL,
	[description] [nvarchar](max) NULL,
	[lastRecorded] [datetime] NULL,
 CONSTRAINT [PK_Flow] PRIMARY KEY CLUSTERED 
(
	[flowID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


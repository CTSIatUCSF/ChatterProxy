IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GrantFile]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GrantFile](
	[FileId] [uniqueidentifier] NOT NULL,
	[FileName] [varchar](255) NOT NULL,
	[Processed] [bit] NOT NULL,
 CONSTRAINT [PK_GrantFile] PRIMARY KEY CLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
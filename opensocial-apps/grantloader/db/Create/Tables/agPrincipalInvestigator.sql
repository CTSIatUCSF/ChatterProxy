/****** Object:  Table [dbo].[agPrincipalInvestigator]    Script Date: 04/01/2012 12:42:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agPrincipalInvestigator]') AND type in (N'U'))
DROP TABLE [dbo].[agPrincipalInvestigator]
GO

/****** Object:  Table [dbo].[agPrincipalInvestigator]    Script Date: 04/01/2012 12:42:42 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agPrincipalInvestigator]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[agPrincipalInvestigator](
	[PrincipalInvestigatorPK] [uniqueidentifier] NOT NULL,
	[PrincipalInvestigator_Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[EmployeeId] [nvarchar](50) NULL,
 CONSTRAINT [PK_PrincipalInvestigator] PRIMARY KEY CLUSTERED 
(
	[PrincipalInvestigatorPK] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO


/****** Object:  Index [IX_PrincipalInvestigator]    Script Date: 04/01/2012 12:42:42 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agPrincipalInvestigator]') AND name = N'IX_PrincipalInvestigator')
CREATE NONCLUSTERED INDEX [IX_PrincipalInvestigator] ON [dbo].[agPrincipalInvestigator] 
(
	[PrincipalInvestigator_Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


/****** Object:  Table [UCSF.].[ChatterActivity]    Script Date: 11/09/2012 11:10:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[ChatterActivity](
	[activityLogId] [int] NOT NULL,
	[externalMessage] [bit] NOT NULL,
	[employeeId] [nvarchar](50) NULL,
	[url] [nvarchar](255) NULL,
	[title] [nvarchar](255) NULL,
	[body] [nvarchar](255) NULL,
	[chatterFlag] [char](1) NULL,
	[chatterAttempts] [int] NULL,
	[createdDT] [datetime] NOT NULL,
	[updatedDT] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [UCSF.].[ChatterActivity]  WITH CHECK ADD  CONSTRAINT [FK_ChatterActivity_ActivityLog] FOREIGN KEY([activityLogId])
REFERENCES [UCSF.].[ActivityLog] ([activityLogId])
GO

ALTER TABLE [UCSF.].[ChatterActivity] CHECK CONSTRAINT [FK_ChatterActivity_ActivityLog]
GO

ALTER TABLE [UCSF.].[ChatterActivity] ADD  CONSTRAINT [DF_chatterActivity_createdDT]  DEFAULT (getdate()) FOR [createdDT]
GO

CREATE TRIGGER [UCSF.].[addChatterActivity]
ON [UCSF.].[ActivityLog]
AFTER INSERT
AS
/* Get the range of level for this job type from the jobs table. */
DECLARE 
   @activityLogId int,
   @privacyCode int,
   @employeeId nvarchar(50),
   @methodName nvarchar(255),
   @param1 nvarchar(255),
   @param2 nvarchar(255),
   @externalMessage bit,
   @url nvarchar(255),
   @title nvarchar(255),
   @body nvarchar(255),
   @journalTitle varchar(1000)
SELECT @activityLogId = i.activityLogId, @privacyCode = i.privacyCode, @employeeId = p.InternalUserName, 
	@methodName = i.methodName, @param1 = i.param1, @param2 = i.param2, @externalMessage = 0
FROM inserted i LEFT OUTER JOIN [Profile.Data].[Person] p ON i.personId = p.personID
-- if we have a PMID, go ahead and grab that info
IF (@param1 = 'PMID')
   SELECT @url = 'http://www.ncbi.nlm.nih.gov/pubmed/' + @param2, @journalTitle = JournalTitle, @externalMessage = 1 FROM
		[Profile.Data].[Publication.PubMed.General] 
		WHERE PMID = cast(@param2 as int)
-- USER activities		
IF (@privacyCode = -1) 
BEGIN   
	IF (@methodName = 'Profiles.Edit.Utilities.DataIO.AddPublication')
		SELECT @title = 'added a publication to their profile from the journal: ' + @journalTitle
	ELSE IF (@methodName = 'Profiles.Edit.Utilities.DataIO.AddCustomPublication')
		SELECT @title = 'added "'  + @param1 + '" to the ' + cp._propertyLabel + ' section of their profile : ' + @param2
			FROM [UCSF.].[ActivityLog] al JOIN
			[Ontology.].[ClassProperty] cp ON cp.Property = al.property 		
			WHERE al.activityLogId = @activityLogId AND al.property IS NOT NULL
	ELSE IF (@methodName = 'Profiles.Edit.Utilities.DataIO.UpdateSecuritySetting')
		SELECT @title = 'made "'  + cp._propertyLabel + '" visible in their profile'
			FROM [UCSF.].[ActivityLog] al JOIN
			[Ontology.].[ClassProperty] cp ON cp.Property = al.property 		
			WHERE al.activityLogId = @activityLogId AND al.property IS NOT NULL
	ELSE IF (@methodName like 'Profiles.Edit.Utilities.DataIO.Add%')
		SELECT @title = 'added "'  + @param1 + '" to the ' + cp._propertyLabel + ' section of their profile'
			FROM [UCSF.].[ActivityLog] al JOIN
			[Ontology.].[ClassProperty] cp ON cp.Property = al.property 		
			WHERE al.activityLogId = @activityLogId AND al.property IS NOT NULL
	ELSE IF (@methodName like 'Profiles.Edit.Utilities.DataIO.Update%')
		SELECT @title = 'updated "' + cp._propertyLabel + '" in their profile'
			FROM [UCSF.].[ActivityLog] al JOIN
			[Ontology.].[ClassProperty] cp ON cp.Property = al.property 		
			WHERE al.activityLogId = @activityLogId AND al.property IS NOT NULL
END
ELSE IF (@methodName = 'ProfilesGetNewHRAndPubs.Disambiguation') 
	SELECT @title = 'has a new publication listed in UCSF Profiles in the journal: ' + @journalTitle
ELSE IF (@methodName = 'ProfilesGetNewHRAndPubs.AddedToProfiles') 
	SELECT @title = 'was just added to UCSF Profiles'

-- if we have @title, then insert
IF (@title != NULL)
	INSERT [UCSF.].[ChatterActivity] (activityLogId, externalMessage, employeeId, url, title, body)
		SELECT @activityLogId, @externalMessage, @employeeId, @url, @title, @body

GO

/*
                        "just added a new publication in UCSF Profiles in the journal: " + journalTitle.Value);
                        "has a new publication listed in UCSF Profiles in the journal: " + journalTitle.Value);
            service.CreateExternalMessage("http://www.ncbi.nlm.nih.gov/pubmed/" + pmid, title, body, employeeId);




--Creates script table for remote updating

USE [LSONE_CTC]
GO

/****** Object:  Table [dbo].[ScriptTable]    Script Date: 8/06/2020 6:41:38 PM ******/
DROP TABLE [dbo].[ScriptTable]
GO

/****** Object:  Table [dbo].[ScriptTable]    Script Date: 8/06/2020 6:41:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ScriptTable](
	[ScriptName] [nvarchar](max) NOT NULL,
	[ScriptCode] [nvarchar](max) NOT NULL,
	[ScriptDate] [datetime] NOT NULL,
	[LoadDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Create SP to execute scripts from table

USE [LSONE_CTC]
GO

/****** Object:  StoredProcedure [dbo].[ExecuteSQLScript]    Script Date: 8/06/2020 6:38:44 PM ******/
DROP PROCEDURE [dbo].[ExecuteSQLScript]
GO

/****** Object:  StoredProcedure [dbo].[ExecuteSQLScript]    Script Date: 8/06/2020 6:38:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[ExecuteSQLScript]
	
AS 

	DECLARE @ScriptCode NVARCHAR(MAX)
	DECLARE @ScriptName NVARCHAR(MAX)

	SET NOCOUNT ON;

	WHILE (SELECT TOP 1 COUNT(ScriptCode)
	FROM ScriptTable
	WHERE ScriptDate > LoadDate) > 0 BEGIN

	SET @ScriptName = (SELECT TOP 1 ScriptName FROM ScriptTable WHERE ScriptDate > LoadDate ORDER BY ScriptName,ScriptDate)
	SET @ScriptCode = (SELECT TOP 1 ScriptCode FROM ScriptTable WHERE ScriptDate > LoadDate ORDER BY ScriptName,ScriptDate)

	exec sp_executesql @ScriptCode

	UPDATE ScriptTable SET LoadDate = GETDATE() WHERE ScriptName = @ScriptName

	END
GO
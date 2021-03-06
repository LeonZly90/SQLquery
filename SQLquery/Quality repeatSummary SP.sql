USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[RepeatSummaryReport]    Script Date: 12/10/2021 10:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[RepeatSummaryReport]
	-- Add the parameters for the stored procedure here
	@ProjectID nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select ProjectNo,ProjectName,WeightedValue,Severity,
	Repeated,
	count(Repeated) as [CountRepeated],
	sum(PCC_SUM) as PCC_SUM_total,
	sum(SUB_SUM) as SUB_SUM_total,
	sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM]
	from(
	select Project.Project_No as ProjectNo, 
	(select top 1 Project.Project_Name
	from dbo.Project where Project_No =IIF(@ProjectID IS NULL, Project_No, @ProjectID)) as ProjectName,
	w.WeightedValue as WeightedValue,
	w.[Desc] as Severity,
	Obs_Repeated as Repeated,
	(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
	(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where Project_No =  IIF(@ProjectID IS NULL, Project_No, @ProjectID)
	) a
	group by ProjectNo,ProjectName,WeightedValue,Severity,Repeated
END

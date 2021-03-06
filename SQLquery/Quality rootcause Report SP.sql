USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[RootCauseReport]    Script Date: 12/10/2021 10:53:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[RootCauseReport]
	-- Add the parameters for the stored procedure here
	@ProjectID nvarchar(50)
	--,
	--@ProjectName nvarchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select ProjectNo, ProjectName,RootId,RootCause,
	count(Obs_RootCause_Id) as [Count],
	sum(PCC_SUM) as PCC_SUM_total,
	sum(SUB_SUM) as SUB_SUM_total,
	sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM]

	from(
		select Project.Project_No as ProjectNo, 
		(select top 1 Project.Project_Name
		from dbo.Project where Project_No = IIF(@ProjectID IS NULL, Project_No, @ProjectID)) as ProjectName,
		obs.Obs_RootCause_Id as RootId, 
		RootCause_Desc as RootCause,
		obs.Obs_RootCause_Id,
		(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
		(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
		from dbo.Observation obs
		join dbo.Project on obs.Obs_Proj_Id = Project.id
		join dbo.RootCause on RootCause.id = obs.Obs_RootCause_Id
		where Project_No =  IIF(@ProjectID IS NULL, Project_No, @ProjectID)
		) a
	group by 
	ProjectNo,ProjectName,RootId,RootCause
	--or Project_No is NULL
	--or Project_Name=@ProjectName or @ProjectName = ''
	--order by Obs_RootCause_Id
END


USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[COST_Quality_table1]    Script Date: 1/14/2022 11:36:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[COST_Quality_table1] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
		Project_No,ProjectNoName,Project_Company,Obs_Date,ObsComplianceDate, (select DATEDIFF(DAY,Obs_Date,ObsComplianceDate)) as ObsDurationDay,
		round(isnull(cast(sum(PCC_SUM+SUB_SUM) as float)/nullif(cast((select DATEDIFF(DAY,Obs_Date,ObsComplianceDate)) as float),0),0),4) as ObsAverPerDay,
		--sum(PCC_SUM) as PCC_SUM_total,
		--sum(SUB_SUM) as SUB_SUM_total,
		sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],ProjectCost,ProjectStartDate,ProjectTotalWeek,ProjectEndDate,WeeksTillToday,
		ObsWeeksFromStart, --1/14/21
		case when round(cast(WeeksTillToday as float)/cast(ProjectTotalWeek as float),4)>1 then 1
		else round(cast(WeeksTillToday as float)/cast(ProjectTotalWeek as float),4) end as CompletePercent

		from(
			select 
			Project_No, Project.Project_No+' '+Project_Name as ProjectNoName,Project.Project_Company,Obs_Date,

			case when (Obs_Compliance_Date IS NULL) and (select dateadd(ww, Project_TotalWeek, Project_Start_Date))<=(select GETDATE()) then (select dateadd(ww, Project_TotalWeek, Project_Start_Date))
			when (Obs_Compliance_Date IS NULL) and (select dateadd(ww, Project_TotalWeek, Project_Start_Date))>=(select GETDATE()) then (select GETDATE())
			else Obs_Compliance_Date end as ObsComplianceDate,

			(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project.Project_Cost as ProjectCost,Project_Start_Date as ProjectStartDate,
			(select dateadd(ww, Project_TotalWeek, Project_Start_Date)) AS ProjectEndDate,
			(select GETDATE()) as TodayDate,
			(SELECT DATEDIFF(ww, Project_Start_Date, (select GETDATE()))) AS WeeksTillToday,

			(SELECT DATEDIFF(ww, Project_Start_Date, Obs_Date)) AS ObsWeeksFromStart,

			Project_TotalWeek as ProjectTotalWeek
			from dbo.Observation obs join dbo.Project on obs.Obs_Proj_Id = Project.id
			where Project_Start_Date is not null
		) a group by Project_No,ProjectNoName,Project_Company,Obs_Date,ObsComplianceDate,ProjectCost,ProjectStartDate,ProjectEndDate,ProjectTotalWeek,WeeksTillToday,ObsWeeksFromStart
END


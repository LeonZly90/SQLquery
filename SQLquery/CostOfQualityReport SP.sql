USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[CostOfQualityReport]    Script Date: 12/14/2021 11:42:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[CostOfQualityReport] 
	-- Add the parameters for the stored procedure here
	@ProjectID nvarchar(50),
	@StartDate DATE,
	@EndDate   DATE


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @now date
	declare @actualStartDate date
	declare @actualEndDate date

	set @now = GETDATE()

	set @actualStartDate = (select Project_Start_Date from dbo.Project where --Project_No = --'1401115'
	(Project_No+Project_Name like  '%'+IsNull(@ProjectID,Project_No)+'%') and Project_Start_Date is not null) 

	set @actualEndDate = dateadd(ww,
								(select Project_TotalWeek from dbo.Project where --Project_No = --'1401115'
								(Project_No+Project_Name like  '%'+IsNull(@ProjectID,Project_No)+'%') and Project_Start_Date is not null) ,
								@actualStartDate)


	SET @StartDate =
	CASE 
		WHEN @StartDate = '' then @actualStartDate
		WHEN @StartDate < @actualStartDate then @actualStartDate
		WHEN @actualEndDate < @now  and @actualEndDate < @StartDate then @actualStartDate
		WHEN @actualEndDate < @now  and @actualEndDate > @StartDate then @StartDate
		WHEN @actualEndDate > @now  and @now < @StartDate then @actualStartDate
		WHEN @actualEndDate > @now  and @now > @StartDate then @StartDate
	END 

	SET @EndDate =
	CASE 
		WHEN @actualEndDate < @now and @EndDate = '' then @actualEndDate
		WHEN @actualEndDate > @now and @EndDate = '' then @now
		WHEN @actualEndDate < @now and @EndDate < @actualEndDate and @EndDate > @actualStartDate then @EndDate
		WHEN @actualEndDate < @now and @EndDate < @actualStartDate then @actualEndDate
		WHEN @actualEndDate < @now and @EndDate > @actualEndDate then @actualEndDate
		WHEN @actualEndDate > @now and @EndDate < @now and @EndDate > @actualStartDate then @EndDate
		WHEN @actualEndDate > @now and @EndDate < @actualStartDate then @now
		WHEN @actualEndDate > @now and @EndDate > @now then @now
	END


	select c.*, isnull(
	[PCC+SUB SUM]/ nullif(([percent] *ProjectCost),0), 0) as latest
	from(
		select b.*,
		case when round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4)>1 then 1
		else round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4) end as [percent]
		from(
			select ProjectNoName,
			sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],
			ProjectCost,
			ProjectstartDate,
			ProjectEndDate,
			ProjectTotalWeek,
			number_of_weeks
			from(
				select 
				--Project.Project_No as ProjectNo, 
				--Project.Project_Name as ProjectName,
				Project.Project_No+' '+Project_Name as ProjectNoName,
				(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
				(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
				Project.Project_Cost as ProjectCost,
				@actualStartDate as ProjectStartDate,
				@actualEndDate as ProjectEndDate,
				(SELECT DATEDIFF(ww, @StartDate, @EndDate)) AS number_of_weeks,
				Project_TotalWeek as ProjectTotalWeek
				from 
				dbo.Observation obs
				join dbo.Project on obs.Obs_Proj_Id = Project.id
				where 
				(Project_No+Project_Name like  '%'+IsNull(@ProjectID,Project_No)+'%')
				and 
				Project_Start_Date is not null
				) a
			group by ProjectNoName,ProjectCost,ProjectStartDate,ProjectEndDate, ProjectTotalWeek,number_of_weeks
		) b
	) c
	order by [percent]


END



EXEC dbo.RootCauseReport '1108668'
EXEC dbo.RepeatSummaryReport '1108668'
EXEC dbo.ComparisonReport'1401115'

EXEC dbo.CostOfQualityReport '1501470' '1601645'
EXEC dbo.CostOfQualityReport '1108668', '2018-11-12','2021-12-18'
-- 2021-03-01 2018-06-16

select * from Observation
select * from Project order by Project_No
select * from #QTemp
drop table #QTemp

--create #QTemp

select b.*
	into #QTemp
	from(
		select 
		ProjectNoName,Project_Company,Obs_Date,ObsComplianceDate, (select DATEDIFF(DAY,Obs_Date,ObsComplianceDate)) as ObsDurationDay,
		round(isnull(cast(sum(PCC_SUM+SUB_SUM) as float)/nullif(cast((select DATEDIFF(DAY,Obs_Date,ObsComplianceDate)) as float),0),0),4) as ObsAverPerDay,
		--sum(PCC_SUM) as PCC_SUM_total,
		--sum(SUB_SUM) as SUB_SUM_total,
		sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],ProjectCost,ProjectStartDate,ProjectTotalWeek,ProjectEndDate,WeeksTillToday,

		case when round(cast(WeeksTillToday as float)/cast(ProjectTotalWeek as float),4)>1 then 1
		else round(cast(WeeksTillToday as float)/cast(ProjectTotalWeek as float),4) end as CompletePercent

		from(
			select 
			Project.Project_No+' '+Project_Name as ProjectNoName,Project.Project_Company,Obs_Date,

			case when (Obs_Compliance_Date IS NULL) and (select dateadd(ww, Project_TotalWeek, Project_Start_Date))<=(select GETDATE()) then (select dateadd(ww, Project_TotalWeek, Project_Start_Date))
			when (Obs_Compliance_Date IS NULL) and (select dateadd(ww, Project_TotalWeek, Project_Start_Date))>=(select GETDATE()) then (select GETDATE())

			else Obs_Compliance_Date end as ObsComplianceDate,
			(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project.Project_Cost as ProjectCost,Project_Start_Date as ProjectStartDate,
			(select dateadd(ww, Project_TotalWeek, Project_Start_Date)) AS ProjectEndDate,
			(select GETDATE()) as TodayDate,
			(SELECT DATEDIFF(ww, Project_Start_Date, (select GETDATE()))) AS WeeksTillToday,
			Project_TotalWeek as ProjectTotalWeek
			from dbo.Observation obs join dbo.Project on obs.Obs_Proj_Id = Project.id
			where Project_Start_Date is not null
		) a group by ProjectNoName,Project_Company,Obs_Date,ObsComplianceDate,ProjectCost,ProjectStartDate,ProjectEndDate,ProjectTotalWeek,WeeksTillToday
	) b --order by ProjectEndDate

select *,
[PCC+SUB SUM]/ nullif(([percent] *ProjectCost),0) as latest
from #QTemp order by [percent]
-------------------------------------------------
select c.*, isnull(
[PCC+SUB SUM]/ nullif(([percent] *ProjectCost),0), 0) as latest
from(
	select b.*,
	case when round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4)>1 then 1
	else round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4) end as [percent]
	--into #QTemp
	from(
		select 
		--ProjectNo, 
		--ProjectName,
		ProjectNoName,
		--sum(PCC_SUM) as PCC_SUM_total,
		--sum(SUB_SUM) as SUB_SUM_total,
		sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],
		ProjectCost,
		ProjectstartDate,
		ProjectTotalWeek,
		--TodayDate,
		--(SELECT DATEDIFF(ww, ProjectstartDate, TodayDate)) AS number_of_weeks
		number_of_weeks
		from(
			select 
			--Project.Project_No as ProjectNo, 
			--Project.Project_Name as ProjectName,
			Project.Project_No+' '+Project_Name as ProjectNoName,
			--(select top 1 Project.Project_Name from dbo.Project 
			--where Project_No = '1601645') as ProjectName,
			(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project.Project_Cost as ProjectCost,
			Project_Start_Date as ProjectstartDate,
			(select GETDATE()) as TodayDate,
			(SELECT DATEDIFF(ww, Project_Start_Date, (select GETDATE()))) AS number_of_weeks,
			Project_TotalWeek as ProjectTotalWeek
			from 
			dbo.Observation obs
			join dbo.Project on obs.Obs_Proj_Id = Project.id
			where 
			--(Project.Project_No+' '+Project_Name like '%South 1501470-Phs2%')
			--and 
			Project_Start_Date is not null
		) a
		--where a.ProjectstartData = '1900-01-01 12:00:00'
		group by ProjectNoName,ProjectCost,ProjectstartDate,ProjectTotalWeek,number_of_weeks
		--, 
		--ProjectName
		--order by ProjectCost
	) b
) c
order by ProjectNoName
-------------------------------------------------

declare 
@ProjectID nvarchar(50),@Company nvarchar(50),@StartDate DATE,@EndDate DATE,
@now date,@i int

set @i = 1 --1 week
set @now = GETDATE()

set @StartDate = '2021-01-01' 
set @EndDate = '2022-01-01' --start + i week
set @ProjectID = '1801334'
set @Company = 'PCCW'

--Cost Quality formula

--select 
----*
----,
--ProjectNoName,Project_Company,
--ObsAverPerDay,(select DATEDIFF(DAY,PccSubStart,PccSubEnd)) as InputDayRange,InputWeekRange,ProjectTotalWeek,
--ObsAverPerDay*(select DATEDIFF(DAY,PccSubStart,PccSubEnd)) as PCCSUBSUM
--, case when round(cast(InputWeekRange as float)/cast(ProjectTotalWeek as float),4)>1 then 1
--else round(cast(InputWeekRange as float)/cast(ProjectTotalWeek as float),4) end as FirstPercent,
--ProjectCost,

--isnull(ObsAverPerDay*(select DATEDIFF(DAY,PccSubStart,PccSubEnd))/ nullif(( --PCC and sub cost during the input date range
--(case when cast(InputWeekRange as float)/cast(ProjectTotalWeek as float)>1 then 1 -- project percent during the input date range if complete show 1
--else cast(InputWeekRange as float)/cast(ProjectTotalWeek as float) end) -- project percent during the input date range
--*ProjectCost),0), 0) as FirstLoop -- total project cost

--from(
	select *,isnull([PCC+SUB SUM]/ nullif((CompletePercent *ProjectCost),0), 0) as CurrentQualityCost,	
				(SELECT DATEDIFF(ww,	
				CASE 
					WHEN @StartDate = '' then ProjectStartDate
					WHEN @StartDate <= ProjectStartDate then ProjectStartDate
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0 
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate then @StartDate
					WHEN ProjectEndDate >= @now  and @now >= @StartDate then @StartDate
				END ,	
						
				CASE 							 
					WHEN ProjectEndDate <= @now and @EndDate = '' then ProjectEndDate
					WHEN ProjectEndDate >= @now and @EndDate = '' then @now
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now and @EndDate <= ProjectEndDate and @EndDate >= ProjectStartDate then @EndDate
					WHEN ProjectEndDate <= @now and @EndDate >= ProjectEndDate and @StartDate >= ProjectStartDate then ProjectEndDate

					WHEN ProjectEndDate >= @now and @EndDate <= @now and @EndDate >= ProjectStartDate then @EndDate							
					WHEN ProjectEndDate >= @now and @StartDate>=ProjectStartDate and @EndDate >= @now then @now
				END
						)) AS InputWeekRange,

		case 
			when @StartDate > @EndDate then 0 
			when @StartDate<=Obs_Date or @StartDate = '' then Obs_Date
			when @StartDate>=Obs_Date and @StartDate<=ObsComplianceDate then @StartDate
			when @StartDate>=ObsComplianceDate then ObsComplianceDate
			end as PccSubStart, --edge case

		case 
			when @StartDate > @EndDate then 0 
			when @EndDate>=ObsComplianceDate or @EndDate = '' then ObsComplianceDate
			when @EndDate>=Obs_Date and @EndDate<=ObsComplianceDate then @EndDate
			when @EndDate<=Obs_Date then Obs_Date
			end as PccSubEnd --edge case

		from #QTemp 
		where 
		(ProjectNoName like  '%'+IsNull(@ProjectID,ProjectNoName)+'%') 
		and 
		(Project_Company = IsNull(@Company,Project_Company) or @Company='') 
) list1									
order by ProjectNoName

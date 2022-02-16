select * from WeightOfIssue
select * from RootCause
select * from Project 
select * from Observation order by Obs_Contractor
select * from Contractor order by id

EXEC dbo.RootCauseReport '1108668'
EXEC dbo.RepeatSummaryReport '1108668'
EXEC dbo.ComparisonReport'1601712'

select ProjectNo, ProjectName, 
--Contractor_Name,TradeNo,
--Display_Name,Company,
case 
when a.Company='PCCI' then CONCAT(RTRIM(TradeNo),' ',Company,' ',Contractor_Name) 
when a.Company='PCC' then Display_Name 
end as TradeName,
sum(PCC_SUM) as PCC_SUM_total,
sum(SUB_SUM) as SUB_SUM_total,
sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM]
from(
select Project.Project_No as ProjectNo, 
Project.Project_Name as ProjectName, 
--(select top 1 Project.Project_Name
--from dbo.Project where Project_No = '1601712') as ProjectName,
c.Contractor_Name,c.TradeNo,
c.Display_Name,
c.Company,
(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
from dbo.Observation obs
join dbo.Project on obs.Obs_Proj_Id = Project.id
join dbo.Contractor c on c.id = obs.Obs_Contractor
where 
Project.Project_No = '1601712' 
and 
c.Display_Name like '%SPG%' and
(c.TradeNo = '03' or c.TradeNo =  '05' or c.TradeNo =  '06' or c.TradeNo =  '07' or c.TradeNo =  '09') 
) a
group by ProjectNo, ProjectName, 
Contractor_Name,TradeNo,
Display_Name,Company
order by ProjectNo,TradeNo






select ProjectNo,ProjectName,WeightedValue,Severity,
--count(WeightedValue) as [CountSeverity],
Repeated,
count(Repeated) as [CountRepeated],
--PCC_SUM,
sum(PCC_SUM) as PCC_SUM_total,
--SUB_SUM,
sum(SUB_SUM) as SUB_SUM_total,
sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM]
from(
	select Project.Project_No as ProjectNo, 
	--Project.Project_Name, 
	(select top 1 Project.Project_Name
	from dbo.Project where Project_No = '1108668') as ProjectName,
	--obs.Obs_Weighted, 
	--w.id as WeighedId,
	w.WeightedValue as WeightedValue,
	w.[Desc] as Severity,
	Obs_Repeated as Repeated,
	(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
	(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where 
	Project_No = '1108668' 
--and 
--Obs.Obs_Repeated = 'Yes'
) a
group by ProjectNo,ProjectName,WeightedValue,Severity,Repeated
--order by WeightedValue




select ProjectNo, ProjectName,RootId,RootCause,
	count(Obs_RootCause_Id) as [Count],
	sum(Obs_ActualCostToFix) as ActualCostSum 

from(
select Project.Project_No as ProjectNo, 
	(select top 1 Project.Project_Name
	from dbo.Project where Project_No = '1501470') as ProjectName,
	obs.Obs_RootCause_Id as RootId, 
	RootCause_Desc as RootCause,
	obs.Obs_RootCause_Id,
	obs.Obs_ActualCostToFix
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.RootCause on RootCause.id = obs.Obs_RootCause_Id
	where Project_No =  '1501470'
	--Order by Obs_RootCause_Id
	--or Project_No is NULL
	--or Project_Name=@ProjectName or @ProjectName = ''
	
	--group by 
	--Project_No,Project_Name,
	--Obs_RootCause_Id,RootCause_Desc
	) a
	group by 
	ProjectNo,ProjectName,
	RootId,RootCause
	--,[Count],ActualCostSum


		----select * into #QTemp from (
	--	select c.*, isnull(
	--	[PCC+SUB SUM]/ nullif(([percent] *ProjectCost),0), 0) as latest
	--	from(
	--		select b.*,
	--		case when round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4)>1 then 1
	--		else round(cast(number_of_weeks as float)/cast(ProjectTotalWeek as float),4) end as [percent]
	--		--into #QTemp
	--		from(

	--			select 
	--			--ProjectNo, 
	--			--ProjectName,
	--			ProjectNoName,
	--			--sum(PCC_SUM) as PCC_SUM_total,
	--			--sum(SUB_SUM) as SUB_SUM_total,
	--			sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],
	--			ProjectCost,
	--			ProjectstartDate,
	--			ProjectTotalWeek,
	--			--TodayDate,
	--			--(SELECT DATEDIFF(ww, ProjectstartDate, TodayDate)) AS number_of_weeks
	--			number_of_weeks

	--			from(

	--				select 
	--				--Project.Project_No as ProjectNo, 
	--				--Project.Project_Name as ProjectName,
	--				Project.Project_No+' '+Project_Name as ProjectNoName,
	--				--(select top 1 Project.Project_Name from dbo.Project 
	--				--where Project_No = '1601645') as ProjectName,
	--				(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
	--				(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
	--				Project.Project_Cost as ProjectCost,
	--				Project_Start_Date as ProjectstartDate,
	--				(select GETDATE()) as TodayDate,

	--				--(SELECT DATEDIFF(ww, Project_Start_Date, (select GETDATE()))) AS number_of_weeks,
	--				(SELECT DATEDIFF(ww, 

	--				(select
	--					CASE 
	--						WHEN @StartDate = '' then @actualStartDate
	--						WHEN @StartDate < @actualStartDate then @actualStartDate
	--						WHEN @actualEndDate < @now  and @actualEndDate < @StartDate then @actualStartDate
	--						WHEN @actualEndDate < @now  and @actualEndDate > @StartDate then @StartDate
	--						WHEN @actualEndDate > @now  and @now < @StartDate then @actualStartDate
	--						WHEN @actualEndDate > @now  and @now > @StartDate then @StartDate
	--					END), 
	--				(select
	--					CASE 
	--						WHEN @actualEndDate < @now and @EndDate = '' then @actualEndDate
	--						WHEN @actualEndDate > @now and @EndDate = '' then @now
	--						WHEN @actualEndDate < @now and @EndDate < @actualEndDate and @EndDate > @actualStartDate then @EndDate
	--						WHEN @actualEndDate < @now and @EndDate < @actualStartDate then @actualEndDate
	--						WHEN @actualEndDate < @now and @EndDate > @actualEndDate then @actualEndDate
	--						WHEN @actualEndDate > @now and @EndDate < @now and @EndDate > @actualStartDate then @EndDate
	--						WHEN @actualEndDate > @now and @EndDate < @actualStartDate then @now
	--						WHEN @actualEndDate > @now and @EndDate > @now then @now
	--					END)
					
	--				)) AS number_of_weeks,

	--				Project_TotalWeek as ProjectTotalWeek
	--				from 
	--				dbo.Observation obs
	--				join dbo.Project on obs.Obs_Proj_Id = Project.id
	--				where 
	--				--(Project.Project_No+' '+Project_Name like '%1108668%')
	--				(Project_No+Project_Name like  '%'+IsNull(@ProjectID,Project_No)+'%')
	--				and 
	--				Project_Start_Date is not null
	--			) a

	--		--where a.ProjectstartData = '1900-01-01 12:00:00'
	--		group by ProjectNoName,ProjectCost,ProjectstartDate,ProjectTotalWeek,number_of_weeks
	--		--, 
	--		--ProjectName
	--		--order by ProjectCost

	--		) b
	--	) c
	--	order by ProjectNoName
	--	--) d

--declare @ProjectID nvarchar(50)
		
--set @ProjectID = '1108668'

--select *,(SELECT DATEDIFF(ww,@StartDate,@EndDate)) AS dateRange
--from (
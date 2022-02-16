select Project_No+' '+Project_Name as ProjectNoName, Last_Review_Date as Last_Date_of_Job_Review 
into #Last_Review_Date
from (
	select ROW_NUMBER() over (partition by Project_Name order by Obs_Date desc) as Rank_Date, Obs_Date as Last_Review_Date, Project_Company, Project_No, Project_Name
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.Contractor c on c.id = obs.Obs_Contractor --no need
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id) x
where Rank_Date = 1 --and Project_No='1501470'

--# Items Open
select ProjectNoName, count(Obs_Status) as Items_Open 
into #Items_Open -- row 205
from(
	select Project_No+' '+Project_Name as ProjectNoName, Obs_Status
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where Obs_status = 'No') x
group by ProjectNoName

--% total 
select ProjectNoName, count(Obs_Status) as total_items
into #Items_Total -- row 237
from(
	select  Project_No+' '+Project_Name as ProjectNoName, Obs_Status
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id) x 
group by (ProjectNoName)

-- item repeated
select ProjectNoName, count(Obs_Repeated) as Items_Repeated 
into #Items_Repeated -- row 117 
from(
	select  Project_No+' '+Project_Name as ProjectNoName, Obs_Repeated
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where Obs_Repeated='Yes') x 
group by (ProjectNoName)

-- item close
select ProjectNoName, count(Obs_Status) as Items_Close 
into #Items_Close --row 216
from(
	select Project_No+' '+Project_Name as ProjectNoName, Obs_Status
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where Obs_status != 'No') x
group by ProjectNoName

-- severity_0
select ProjectNoName, count(WeightedValue) as severity_0 
into #severity_0 --row 158
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=0) x
group by ProjectNoName

-- severity_1
select ProjectNoName, count(WeightedValue) as severity_1 
into #severity_1 --row 140
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=1) x
group by ProjectNoName


-- severity_2
select ProjectNoName, count(WeightedValue) as severity_2
into #severity_2 --row 105
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=2) x
group by ProjectNoName

-- severity_3
select ProjectNoName, count(WeightedValue) as severity_3
into #severity_3 --row 217
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=3) x
group by ProjectNoName


-- severity_4
select ProjectNoName, count(WeightedValue) as severity_4
into #severity_4 --row 170
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=4) x
group by ProjectNoName

-- severity_5
select ProjectNoName, count(WeightedValue) as severity_5
into #severity_5 --row 168
from(
	select Project_No+' '+Project_Name as ProjectNoName, w.WeightedValue,w.[Desc] as Severity
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=5) x
group by ProjectNoName

-- #Project_Cost
select *, 
[PCC+SUB SUM]/nullif(Project_Cost_to_Date,0)*100 as Cost_of_Quality_Percent 
into #Project_Cost
from(
	select ProjectNoName,Total_Project_Cost, Percent_Project_complete * Total_Project_Cost as Project_Cost_to_Date, 100*Percent_Project_complete as Percent_Project_complete,
	Pepper_Cost_Quailty,Sub_Cost_Quailty, [PCC+SUB SUM]
	from(
		select 
		ProjectNoName,sum(PCC_SUM) as Pepper_Cost_Quailty,sum(SUB_SUM) as Sub_Cost_Quailty,sum(PCC_SUM+SUB_SUM) as [PCC+SUB SUM],
		Total_Project_Cost,ProjectstartDate,ProjectTotalWeek,number_of_weeks,
		case when cast(number_of_weeks as float)/ProjectTotalWeek>1 then 1
			else cast(number_of_weeks as float)/ProjectTotalWeek end as Percent_Project_complete
		from(
			select 
			Project.Project_No+' '+Project_Name as ProjectNoName,
			(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost,
			Project_Start_Date as ProjectstartDate,
			(select GETDATE()) as TodayDate,
			(SELECT DATEDIFF(ww, Project_Start_Date, (select GETDATE()))) AS number_of_weeks,
			Project_TotalWeek as ProjectTotalWeek
			from dbo.Observation obs
			join dbo.Project on obs.Obs_Proj_Id = Project.id
			--join dbo.Contractor c on c.id = obs.Obs_Contractor
			--where 
			----Project_No =  IIF(@ProjectID IS NULL, Project_No, @ProjectID)
			----and 
			--c.Display_Name like '%SPG%' and
			--(c.TradeNo = '03' or c.TradeNo =  '05' or c.TradeNo =  '06' or c.TradeNo =  '07' or c.TradeNo =  '09')
		) a
		group by ProjectNoName,Total_Project_Cost,ProjectstartDate,ProjectTotalWeek,number_of_weeks
	) b
) c


--#item_open_duration
select ProjectNoName,sum([1-15 days]) as [1-15 days], sum([16-30 days]) as [16-30 days],sum([31-60 days]) as [31-60 days],sum([61-90 days]) as [61-90 days],sum([>90 days]) as [>90 days] 
into #item_open_duration -- row 205
from(
	select ProjectNoName,
	isnull(case when ObsDurationDay<=15 then 1 end, 0) as [1-15 days],
	isnull(case when ObsDurationDay>15 and ObsDurationDay<=30 then 1 end, 0) as [16-30 days],
	isnull(case when ObsDurationDay>30 and ObsDurationDay<=60 then 1 end, 0) as [31-60 days],
	isnull(case when ObsDurationDay>60 and ObsDurationDay<=90 then 1 end, 0) as [61-90 days],
	isnull(case when ObsDurationDay>90 then 1 end, 0) as [>90 days]
	from(
		select Project_No+' '+Project_Name as ProjectNoName, Obs_Status, Obs_Date,Obs_Compliance_Date,(select DATEDIFF(DAY,Obs_Date,GETDATE())) as ObsDurationDay
		from dbo.Observation obs
		join dbo.Project on obs.Obs_Proj_Id = Project.id
		where Obs_status = 'No' and Obs_Compliance_Date is null
	) a
) b
group by ProjectNoName--,[1-15 days],[16-30 days],[31-60 days],[61-90 days],[>90 days]


-- % Pre-install Complete total list--A
select Project.Project_No+' '+Project_Name as ProjectNoName, ChecklistId, IsCompleted,CheckListItem
into #pre_install_list 
from  dbo.ProjectCheckList
left join dbo.Project on ProjectCheckList.ProjectId = Project.id
left join dbo.PreinstallationChecklist on ProjectCheckList.ChecklistId = PreinstallationChecklist.Id

--% Pre-install Complete -- A1
select ProjectNoName,
count(ChecklistId) as TotalChecklist, count(IsCompleted) as CompletedChecklist, cast(count(IsCompleted)as float)/count(ChecklistId)*100 as [% Pre-install Complete]
into #Pre_install
from #pre_install_list
group by ProjectNoName -- row 226

-- Pre-install not Completed to Date--A2
select distinct t1.ProjectNoName,
stuff((SELECT distinct ', ' + t2.CheckListItem from #pre_install_list t2 
		where t1.ProjectNoName = t2.ProjectNoName
		FOR XML PATH('')),1,1,''
		) [Pre-install not Completed to Date]
into #Pre_install_unCompleted 
from #pre_install_list t1 -- row 226
where IsCompleted is null -- row 217

-- #SPG35679 & Project_Company
select 	distinct P_id,Project_No, ProjectNoName, Company--,
		--case 
		--when Company='PCCI' then CONCAT(RTRIM(TradeNo),' ',Company,' ',Contractor_Name) 
		--when Company='PCC' then Display_Name 
		--end as TradeName 
into #SPG35679 -- row 117
from(
	select Project.id as P_id, Project_No, Project_No+' '+Project_Name as ProjectNoName, --Project.Project_Company,
			c.Contractor_Name,c.TradeNo,
			c.Display_Name,
			c.Company,
			Project_Cost
			from dbo.Project
			left join dbo.Observation obs on obs.Obs_Proj_Id = Project.id
			left join dbo.Contractor c on c.id = obs.Obs_Contractor
			--where 
			----Project_No =  IIF(@ProjectID IS NULL, Project_No, @ProjectID)
			----and 
			--c.Display_Name like '%SPG%' and
			--(c.TradeNo = '03' or c.TradeNo =  '05' or c.TradeNo =  '06' or c.TradeNo =  '07' or c.TradeNo =  '09')
) x
--select distinct * from Project

-- run
select Project_No,ProjectNoName, Company,--TradeName,
--case 
	--when a.Company='PCCI' then CONCAT(RTRIM(TradeNo),' ',Company,' ',Contractor_Name) 
	--when a.Company='PCC' then Display_Name 
	--end as TradeName,
Last_Date_of_Job_Review,total_items,
--Items_Open,Items_Close, 
cast(Items_Close as float)/total_items as Percent_Closed,Items_Repeated,severity_0,severity_1,severity_2,severity_3,severity_4,severity_5,
Total_Project_Cost,Project_Cost_to_Date,Percent_Project_complete,Pepper_Cost_Quailty,Sub_Cost_Quailty,Cost_of_Quality_Percent,
[1-15 days],[16-30 days],[31-60 days],[61-90 days],[>90 days],
[% Pre-install Complete],[Pre-install not Completed to Date] 
into #All_Compare_Project
from(
	select #Items_Total.ProjectNoName,Last_Date_of_Job_Review, total_items,isnull(Items_Open,0) as Items_Open, isnull(Items_Close,0) as Items_Close,
	isnull(Items_Repeated,0) as Items_Repeated,
	isnull(severity_0,0) as severity_0,isnull(severity_1,0) as severity_1,isnull(severity_2,0) as severity_2,isnull(severity_3,0) as severity_3,isnull(severity_4,0) as severity_4,isnull(severity_5,0) as severity_5,
	--Contractor_Name, TradeNo,Display_Name, Company,--Project_Cost,
	 Total_Project_Cost,Project_Cost_to_Date,Percent_Project_complete,Pepper_Cost_Quailty,Sub_Cost_Quailty,Cost_of_Quality_Percent,
	isnull([1-15 days],0) as [1-15 days],isnull([16-30 days],0) as [16-30 days],isnull([31-60 days],0) as [31-60 days],isnull([61-90 days],0) as [61-90 days],isnull([>90 days],0) as [>90 days],
	[% Pre-install Complete],[Pre-install not Completed to Date], Company, Project_No--,P_id--, TradeName
	from #Items_Total 
	inner join #SPG35679 on #Items_Total.ProjectNoName = #SPG35679.ProjectNoName --row 117
	left join #Last_Review_Date on #Items_Total.ProjectNoName = #Last_Review_Date.ProjectNoName
	left join #Items_Open on #Items_Total.ProjectNoName = #Items_Open.ProjectNoName
	left join #Items_Close on #Items_Total.ProjectNoName = #Items_Close.ProjectNoName 
	left join #Items_Repeated on #Items_Total.ProjectNoName = #Items_Repeated.ProjectNoName
		left join #severity_0 on #Items_Total.ProjectNoName = #severity_0.ProjectNoName
			left join #severity_1 on #Items_Total.ProjectNoName = #severity_1.ProjectNoName
				left join #severity_2 on #Items_Total.ProjectNoName = #severity_2.ProjectNoName
					left join #severity_3 on #Items_Total.ProjectNoName = #severity_3.ProjectNoName
						left join #severity_4 on #Items_Total.ProjectNoName = #severity_4.ProjectNoName
							left join #severity_5 on #Items_Total.ProjectNoName = #severity_5.ProjectNoName 
	left join #Project_Cost on #Items_Total.ProjectNoName = #Project_Cost.ProjectNoName
	--inner join #SPG35679_Project_Cost on #Items_Total.ProjectNoName = #SPG35679_Project_Cost.ProjectNoName
	left join #item_open_duration on #Items_Total.ProjectNoName = #item_open_duration.ProjectNoName 
	left join #Pre_install on #Items_Total.ProjectNoName = #Pre_install.ProjectNoName 
	left join #Pre_install_unCompleted on #Items_Total.ProjectNoName = #Pre_install_unCompleted.ProjectNoName	
	--inner join #SPG35679 on #Items_Total.ProjectNoName = #SPG35679.ProjectNoName 
	) a 

drop table #Items_Open
drop table #Items_Total
drop table #Items_Close
drop table #Last_Review_Date
drop table #Items_Repeated
drop table #severity_0
drop table #severity_1
drop table #severity_2
drop table #severity_3
drop table #severity_4
drop table #severity_5
drop table #Project_Cost
drop table #item_open_duration
drop table #pre_install_list
drop table #Pre_install
drop table #Pre_install_unCompleted
drop table #SPG35679
----------

select * from #All_Compare_Project
drop table #All_Compare_Project

--select * from Observation
--select * from WeightOfIssue
--select * from RootCause
--select * from Project 
--select * from Observation order by Obs_Contractor
--select * from SubDivCode where ParentCode='05' and SubCode = '40'
--select * from Contractor order by id


--select Obs_SubDiv,Contractor_Name,dbo.Project.id ,Project_No,Project_Name,Project_Company,[Desc],* --from WeightOfIssue
--from dbo.Observation obs
--join dbo.Project on obs.Obs_Proj_Id = Project.id
--join dbo.Contractor c on c.id = obs.Obs_Contractor
--join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id


----just use dbo.contractor to get division #
--select a.TradeNo,a.Display_Name, count(a.id) as count_same_id ,Project_No,Project_Name,Project_Company 
--from(
--	select --Obs_SubDiv,
--	c.TradeNo,c.Display_Name, dbo.Project.id ,Project_No,Project_Name,Project_Company --,* --from WeightOfIssue
--	--into #temp1
--	from Observation obs
--	--join SubDivCode s on s.DisplayName = obs.Obs_SubDiv
--	join dbo.Project on obs.Obs_Proj_Id = Project.id
--	join dbo.Contractor c on c.id = obs.Obs_Contractor
--	--where Obs_SubDiv is not null and Obs_SubDiv !='_Select Subcode' order by ParentCode --2410 rows without wrong data--4208 rows/1798 rows not correct
--) a
--group by TradeNo,Display_Name,Project_No,Project_Name,Project_Company --1430 rows 



-------------------------------------------------------------------------------------------------
--0. copy observation to temp new  #obs
select * into #update_ObsSubDivCode from Observation 

--1. get wrong data only
select --REPLACE(REPLACE(Obs_SubDiv,', ','-'),' ','-')  select * from #wrongData drop table #update_ObsSubDivCode
Obs_SubDiv,right(Obs_SubDiv,2)
as Obs_SubDiv2, s.ParentCode,s.DisplayName,TradeNo,c.Display_Name, --(REPLACE(c.TradeNo,' ','')+'-'+right(Obs_SubDiv,2)) as Obs_SubDiv_update
Project_No,Project_Name,Project_Company, obs.id
into #wrongData
from Observation obs
left join SubDivCode s on s.DisplayName = obs.Obs_SubDiv
join dbo.Project on obs.Obs_Proj_Id = Project.id --9456 rows
left join dbo.Contractor c on c.id = obs.Obs_Contractor
where Obs_SubDiv is not null and Obs_SubDiv !='_Select Subcode'  and ParentCode is null --4208 rows total/1798 rows not correct

--2. correct wrong data --select * from #wrongData_cal
select #wrongData.*, SubDivCode.DisplayName as SubDiv_name into #wrongData_cal 
from #wrongData 
join SubDivCode on TradeNo = SubDivCode.ParentCode and Obs_SubDiv2 = SubDivCode.SubCode --1284 rows corrected

--3. update to new temp observation
update #update_ObsSubDivCode
set Obs_SubDiv=SubDiv_name
from #update_ObsSubDivCode join #wrongData_cal on #update_ObsSubDivCode.id = #wrongData_cal.id 
--select * from #update_ObsSubDivCode

--part 1 -subdivision & Contractor_Display & project
select ParentCode,Obs_SubDiv,TradeNo,Contractor_Display, count(projectID)as Obs_Projects_count,projectID, Project_No,Project_Name,Project_Company
into #scp from(
	select --ParentCode,
	ParentCode,Obs_SubDiv,c.Display_Name as Contractor_Display,c.TradeNo,dbo.Project.id as projectID ,Project_No,Project_Name,Project_Company

	from #update_ObsSubDivCode obsTemp
	join SubDivCode s on s.DisplayName = obsTemp.Obs_SubDiv
	left join dbo.Project on obsTemp.Obs_Proj_Id = Project.id
	left join dbo.Contractor c on c.id = obsTemp.Obs_Contractor
	where Obs_SubDiv is not null and Obs_SubDiv !='_Select Subcode' 
	--NOW 3687 without wrong data--4208 rows/528 rows not correct. was 1798
	) a 
group by projectID,ParentCode,Obs_SubDiv,TradeNo,Contractor_Display,Project_No,Project_Name,Project_Company --1430 rows unique for each trade/parent code

--select * from #scp

drop table #wrongData
drop table #wrongData_cal
drop table #update_ObsSubDivCode


--part 2 obs_status = 'No' (Avg days open)
select id, Project_No,Project_Name, count(Obs_Status) as Items_Close, isnull(days_from_today,0) as days_from_today
into #obs_status --row 205
from(
	select Project.id, Project_No,Project_Name, Obs_Status,Project_Start_Date, Project_TotalWeek, datediff(day,Project_Start_Date,GETDATE()) as days_from_today
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where Obs_status = 'No') x
group by id, Project_No,Project_Name,days_from_today

--part 3.0 - projects Serverity issues 0
select id, Project_No,Project_Name, count(WeightedValue) as severity_0, sum(PCC_SUM) as PCC_SUM_severity_0,sum(SUB_SUM) as SUB_SUM_severity_0,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_0
into #severity_0 --row 158
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=0) x
group by id, Project_No,Project_Name

select a.*, isnull(days_from_today,0) as days_from_today_0 
into #sever_0
from #severity_0 a left join #obs_status on a.id = #obs_status.id --158


--part 3.1 - projects Serverity issues 1
select id, Project_No,Project_Name, count(WeightedValue) as severity_1, sum(PCC_SUM) as PCC_SUM_severity_1,sum(SUB_SUM) as SUB_SUM_severity_1,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_1
into #severity_1 --row 140
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=1) x --593 rows
group by id, Project_No,Project_Name

select b.*, isnull(days_from_today,0) as days_from_today_1 
into #sever_1
from #severity_1 b left join #obs_status on b.id = #obs_status.id --140

--part 3.2 - projects Serverity issues 2
select id, Project_No,Project_Name, count(WeightedValue) as severity_2, sum(PCC_SUM) as PCC_SUM_severity_2,sum(SUB_SUM) as SUB_SUM_severity_2,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_2
into #severity_2 --row 105
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=2) x --386 rows
group by id, Project_No,Project_Name

select c.*, isnull(days_from_today,0) as days_from_today_2 
into #sever_2
from #severity_2 c left join #obs_status on c.id = #obs_status.id --105

--part 3.3 - projects Serverity issues 3
select id, Project_No,Project_Name, count(WeightedValue) as severity_3, sum(PCC_SUM) as PCC_SUM_severity_3,sum(SUB_SUM) as SUB_SUM_severity_3,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_3
into #severity_3 --row 217
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=3) x --3686 rows
group by id, Project_No,Project_Name

select d.*, isnull(days_from_today,0) as days_from_today_3 
into #sever_3
from #severity_3 d left join #obs_status on d.id = #obs_status.id --217

--part 3.4 - projects Serverity issues 4
select id, Project_No,Project_Name, count(WeightedValue) as severity_4, sum(PCC_SUM) as PCC_SUM_severity_4,sum(SUB_SUM) as SUB_SUM_severity_4,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_4
into #severity_4 --row 170
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=4) x --1948 rows
group by id, Project_No,Project_Name

select e.*, isnull(days_from_today,0) as days_from_today_4 
into #sever_4
from #severity_4 e left join #obs_status on e.id = #obs_status.id --170

--part 3.5 - projects Serverity issues 5
select id, Project_No,Project_Name, count(WeightedValue) as severity_5, sum(PCC_SUM) as PCC_SUM_severity_5,sum(SUB_SUM) as SUB_SUM_severity_5,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_severity_5
into #severity_5 --row 168
from(
	select Project.id, Project_No,Project_Name, w.WeightedValue,w.[Desc] as Severity,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM,
			Project_Cost as Total_Project_Cost
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	join dbo.WeightOfIssue w on obs.Obs_Weighted = w.id
	where WeightedValue=5) x --2245 rows
group by id, Project_No,Project_Name

select f.*, isnull(days_from_today,0) as days_from_today_5 
into #sever_5
from #severity_5 f left join #obs_status on f.id = #obs_status.id --168
--
drop table #severity_0
drop table #severity_1
drop table #severity_2
drop table #severity_3
drop table #severity_4
drop table #severity_5
drop table #obs_status
----------------------------------------------------------------------------------
				--part 4 add together (scp(subdivision/contractors/projects)+issues= scpi)
				select #scp.*,
				PCC_SUM_severity_0,SUB_SUM_severity_0,PCC_SUB_SUM_severity_0,days_from_today_0,
				PCC_SUM_severity_1,SUB_SUM_severity_1,PCC_SUB_SUM_severity_1,days_from_today_1,
				PCC_SUM_severity_2,SUB_SUM_severity_2,PCC_SUB_SUM_severity_2,days_from_today_2,
				PCC_SUM_severity_3,SUB_SUM_severity_3,PCC_SUB_SUM_severity_3,days_from_today_3,
				PCC_SUM_severity_4,SUB_SUM_severity_4,PCC_SUB_SUM_severity_4,days_from_today_4,
				PCC_SUM_severity_5,SUB_SUM_severity_5,PCC_SUB_SUM_severity_5,days_from_today_5
				into #scpi 
				from #scp --1430
				left join #sever_0 on #scp.projectID = #sever_0.id
				left join #sever_1 on #scp.projectID = #sever_1.id
				left join #sever_2 on #scp.projectID = #sever_2.id
				left join #sever_3 on #scp.projectID = #sever_3.id
				left join #sever_4 on #scp.projectID = #sever_4.id
				left join #sever_5 on #scp.projectID = #sever_5.id
--------------
drop table #sever_0 --select * from #sever_0        select * from #scp
drop table #sever_1
drop table #sever_2
drop table #sever_3
drop table #sever_4
drop table #sever_5
drop table #scp

--part 5 repeat scpir (scp(subdivision/contractors/projects)+issues+repeat= scpir)
select id, Project_No,Project_Name, count(Obs_Repeated) as Items_Repeated,
sum(PCC_SUM) as PCC_SUM_repeat,sum(SUB_SUM) as SUB_SUM_repeat,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_repeat
into #drillDown_Repeated --117
from(
	select  Project.id, Project_No,Project_Name, Obs_Repeated,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	where Obs_Repeated='Yes') x --867
group by id, Project_No,Project_Name

				select #scpi.*,
				Items_Repeated, PCC_SUM_repeat,SUB_SUM_repeat,PCC_SUB_SUM_repeat
				into #scpir
				from #scpi --1430
				left join #drillDown_Repeated on #scpi.projectID = #drillDown_Repeated.id

drop table #drillDown_Repeated
drop table #scpi

--part 6 prior talk -scpirt (scp(subdivision/contractors/projects)+issues+repeat+talk = scpirt)

select id, Project_No,Project_Name, count(Obs_PriorTalk) as Obs_PriorTalk_count,
sum(PCC_SUM) as PCC_SUM_PriorTalk,sum(SUB_SUM) as SUB_SUM_PriorTalk,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_PriorTalk
into #drillDown_talk --117
from(
	select  Project.id, Project_No,Project_Name, Obs_PriorTalk,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	where Obs_PriorTalk=1) x --867
group by id, Project_No,Project_Name --206

				select #scpir.*,
				Obs_PriorTalk_count, PCC_SUM_PriorTalk,SUB_SUM_PriorTalk,PCC_SUB_SUM_PriorTalk
				into #scpirt
				from #scpir --1430
				left join #drillDown_talk on #scpir.projectID = #drillDown_talk.id

drop table #drillDown_talk
drop table #scpir

--part 7 forman not present -scpirtf (scp(subdivision/contractors/projects)+issues+repeat+talk+forman = scpirtf)

select id, Project_No,Project_Name, count(Obs_Foreman_Present) as Foreman_NOT_Present_count,
sum(PCC_SUM) as PCC_SUM_Foreman,sum(SUB_SUM) as SUB_SUM_Foreman,sum(PCC_SUM+SUB_SUM) as PCC_SUB_SUM_Foreman
into #drillDown_forman
from(
	select  Project.id, Project_No,Project_Name, Obs_Foreman_Present,(select isnull(Obs_ActualCostToFix, 0)) as PCC_SUM,
			(select isnull(Obs_ApproximateCost, 0)) as SUB_SUM
	from dbo.Observation obs
	join dbo.Project on obs.Obs_Proj_Id = Project.id
	where Obs_Foreman_Present=0) x --2946
group by id, Project_No,Project_Name --215

				select #scpirt.*,
				Foreman_NOT_Present_count, PCC_SUM_Foreman,SUB_SUM_Foreman,PCC_SUB_SUM_Foreman
				into #scpirtf
				from #scpirt --1430
				left join #drillDown_forman on #scpirt.projectID = #drillDown_forman.id

drop table #drillDown_forman
drop table #scpirt

--select * from #scpirtf where Obs_SubDiv like '%05-20%'

--part 8 Contractor_List
select distinct Obs_SubDiv,
stuff((SELECT distinct ', ' + #scpirtf.Contractor_Display from #scpirtf 
		where Obs_SubDiv like '%05-20%'
		FOR XML PATH('')),1,1,''
		) Contractor_List
into #Contractor_List 
from #scpirtf where Obs_SubDiv like '%05-20%'



--part 9 --calculate
select --*
ParentCode, #scpirtf.Obs_SubDiv,Contractor_List,
--count(TradeNo) as TradeNo_count,
--count(Contractor_Display) as Contractor_Display_count,
--count(Obs_Projects_count) as Obs_time_count,
--count(projectID) as projectID_count,
count(Project_No) as Project_No_count,
--count(Project_Name) as Project_Name_count,
--count(Project_Company) as Project_Company_count,

sum(PCC_SUM_severity_0) as PCC_SUM_severity_0,
sum(SUB_SUM_severity_0) as SUB_SUM_severity_0,
sum(PCC_SUB_SUM_severity_0) as PCC_SUB_SUM_severity_0,
--avg(days_from_today_0) as avg_days_from_today_0,

sum(PCC_SUM_severity_1) as PCC_SUM_severity_1,
sum(SUB_SUM_severity_1) as SUB_SUM_severity_1,
sum(PCC_SUB_SUM_severity_1) as PCC_SUB_SUM_severity_1,
--avg(days_from_today_1) as avg_days_from_today_1,

sum(PCC_SUM_severity_2) as PCC_SUM_severity_2,
sum(SUB_SUM_severity_2) as SUB_SUM_severity_2,
sum(PCC_SUB_SUM_severity_2) as PCC_SUB_SUM_severity_2,
--avg(days_from_today_2) as avg_days_from_today_2,

sum(PCC_SUM_severity_3) as PCC_SUM_severity_3,
sum(SUB_SUM_severity_3) as SUB_SUM_severity_3,
sum(PCC_SUB_SUM_severity_3) as PCC_SUB_SUM_severity_3,
--avg(days_from_today_3) as avg_days_from_today_3,

sum(PCC_SUM_severity_4) as PCC_SUM_severity_4,
sum(SUB_SUM_severity_4) as SUB_SUM_severity_4,
sum(PCC_SUB_SUM_severity_4) as PCC_SUB_SUM_severity_4,
--avg(days_from_today_4) as avg_days_from_today_4,

sum(PCC_SUM_severity_5) as PCC_SUM_severity_5,
sum(SUB_SUM_severity_5) as SUB_SUM_severity_5,
sum(PCC_SUB_SUM_severity_5) as PCC_SUB_SUM_severity_5,
--avg(days_from_today_5) as avg_days_from_today_5,

sum(Items_Repeated) as Items_Repeated_sum,
sum(PCC_SUM_repeat) as PCC_SUM_repeat,
sum(SUB_SUM_repeat) as SUB_SUM_repeat,
sum(PCC_SUB_SUM_repeat) as PCC_SUB_SUM_repeat,

sum(Obs_PriorTalk_count) as Obs_PriorTalk_sum,
sum(PCC_SUM_PriorTalk) as PCC_SUM_PriorTalk,
sum(SUB_SUM_PriorTalk) as SUB_SUM_PriorTalk,
sum(PCC_SUB_SUM_PriorTalk) as PCC_SUB_SUM_PriorTalk,

sum(Foreman_NOT_Present_count) as Foreman_NOT_Present_sum,
sum(PCC_SUM_Foreman) as PCC_SUM_Foreman,
sum(SUB_SUM_Foreman) as SUB_SUM_Foreman,
sum(PCC_SUB_SUM_Foreman) as PCC_SUB_SUM_Foreman

from #scpirtf left join #Contractor_List on #scpirtf.Obs_SubDiv = #Contractor_List.Obs_SubDiv
where #scpirtf.Obs_SubDiv like '%05-20%' 
group by ParentCode, Contractor_List, #scpirtf.Obs_SubDiv
order by #scpirtf.Obs_SubDiv



drop table #scpirtf
drop table #Contractor_List

--exec dbo.DrillDownReport_1 '09-20'
select Project.Project_No, Project.Project_Name, 
obs.Obs_RootCause_Id, 
RootCause_Desc as Root_cause
from dbo.Observation obs
join dbo.Project on obs.Obs_Proj_Id = Project.id
join dbo.RootCause on RootCause.id = obs.Obs_RootCause_Id

select * from RootCause
select * from Project where Project_No = '1500256'
select * from Observation

EXEC dbo.RootCauseReport '1501470'

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
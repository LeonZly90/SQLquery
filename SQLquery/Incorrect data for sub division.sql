
--1. get wrong data only
select --REPLACE(REPLACE(Obs_SubDiv,', ','-'),' ','-')  select * from #wrongData drop table #update_ObsSubDivCode
Obs_SubDiv,
TradeNo,c.Display_Name, --(REPLACE(c.TradeNo,' ','')+'-'+right(Obs_SubDiv,2)) as Obs_SubDiv_update
Project_No,Project_Name,Project_Company, obs.id
--into #wrongData
from Observation obs
left join SubDivCode s on s.DisplayName = obs.Obs_SubDiv
join dbo.Project on obs.Obs_Proj_Id = Project.id --9456 rows
left join dbo.Contractor c on c.id = obs.Obs_Contractor
where Obs_SubDiv is not null and Obs_SubDiv !='_Select Subcode'  and ParentCode is null --4208 rows total/1798 rows not correct
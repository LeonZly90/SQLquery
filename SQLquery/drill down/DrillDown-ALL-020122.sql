--exec [dbo].[DrillDownReport_1] '05', '20','2020-01-01','2022-01-01'
declare @StartDate DATETIME,@EndDate DATETIME,@Div nvarchar(100),@SubDiv nvarchar(100),@Company nvarchar(100),
@C_name1 nvarchar(100),@C_name2 nvarchar(100),@C_name3 nvarchar(100),@C_name4 nvarchar(100),@C_name5 nvarchar(100) 

,@i nvarchar(10)--,@r nvarchar(10),@p nvarchar(10),@f nvarchar(10),@all nvarchar(10)

set @StartDate = '2020-01-01'
set @EndDate = '2022-01-01'
set @Div = '09'
set @SubDiv = '20'
set @Company = 'PCC'
set @C_name1 = '1086' set @C_name2 = '4172' set @C_name3 = '2091'set @C_name4 = '4236'set @C_name5 = ''
--'1086','4172','2091','4236','7'

set @i = 'i' --set @r = 'r' set @p = 'p' set @f = 'f' set @all = 'all'

declare @drill table 

(ParentCode nvarchar(50),SubCode nvarchar(100), Obs_SubDiv nvarchar(100), TradeNo nvarchar(50), Contractor_Display nvarchar(100), Obs_Projects_count int, 
projectID int, Project_No int, Project_Name nvarchar(100), Project_Company nvarchar(100), Obs_id int,SubcontractorId int,

severity_0 int, PCC_SUM_severity_0 float, SUB_SUM_severity_0 float, PCC_SUB_SUM_severity_0 float, days_from_today_0 int, 
severity_1 int,PCC_SUM_severity_1 float, SUB_SUM_severity_1 float, PCC_SUB_SUM_severity_1 float, days_from_today_1 int, 
severity_2 int,PCC_SUM_severity_2 float, SUB_SUM_severity_2 float, PCC_SUB_SUM_severity_2 float, days_from_today_2 int, 
severity_3 int,PCC_SUM_severity_3 float, SUB_SUM_severity_3 float, PCC_SUB_SUM_severity_3 float, days_from_today_3 int, 
severity_4 int,PCC_SUM_severity_4 float, SUB_SUM_severity_4 float, PCC_SUB_SUM_severity_4 float, days_from_today_4 int, 
severity_5 int,PCC_SUM_severity_5 float, SUB_SUM_severity_5 float, PCC_SUB_SUM_severity_5 float, days_from_today_5 int, 

Items_Repeated int, PCC_SUM_repeat float, SUB_SUM_repeat float, PCC_SUB_SUM_repeat float,
Obs_PriorTalk_count int, PCC_SUM_PriorTalk float, SUB_SUM_PriorTalk float, PCC_SUB_SUM_PriorTalk float,
Foreman_NOT_Present_count int, PCC_SUM_Foreman float, SUB_SUM_Foreman float, PCC_SUB_SUM_Foreman float
)
INSERT into @drill 
exec dbo.[DrillDownReport_scpirtf] @Div,@SubDiv, @StartDate, @EndDate,@Company

select * into #rank from @drill; --select * from #rankAll


--------------------------------------------------------------------

select b.*,DENSE_RANK() over (order by Total_2_5_count) as Total_2_5_count_rank,
DENSE_RANK() over (order by Total_2_5_Cost) as Total_2_5_Cost_rank
into #rankAll
from (
	select a.*, sum(severity_2+severity_3+severity_4+severity_5) as Total_2_5_count,
		sum(PCC_SUB_SUM_severity_2+PCC_SUB_SUM_severity_3+PCC_SUB_SUM_severity_4+PCC_SUB_SUM_severity_5) as Total_2_5_Cost
	
	from (
		select SubcontractorId, Contractor_Display, 
		isnull(sum(severity_2),0) as severity_2,
		isnull(sum(severity_3),0) as severity_3,
		isnull(sum(severity_4),0) as severity_4,
		isnull(sum(severity_5),0) as severity_5,
		isnull(sum(PCC_SUB_SUM_severity_2),0) as PCC_SUB_SUM_severity_2,
		isnull(sum(PCC_SUB_SUM_severity_3),0) as PCC_SUB_SUM_severity_3, 
		isnull(sum(PCC_SUB_SUM_severity_4),0) as PCC_SUB_SUM_severity_4,
		isnull(sum(PCC_SUB_SUM_severity_5),0) as PCC_SUB_SUM_severity_5

		from #rank 
		where 
		SubcontractorId =iif(@C_name1 is null,SubcontractorId, @C_name1)
		or (SubcontractorId=iif(@C_name2 is null,SubcontractorId, @C_name2) )
		or (SubcontractorId=iif(@C_name3 is null,SubcontractorId, @C_name3) )
		or (SubcontractorId=iif(@C_name4 is null,SubcontractorId, @C_name4) )
		or (SubcontractorId=iif(@C_name5 is null,SubcontractorId, @C_name5))
		group by SubcontractorId, Contractor_Display
		)a group by SubcontractorId, Contractor_Display,severity_2,severity_3,severity_4,severity_5,PCC_SUB_SUM_severity_2,PCC_SUB_SUM_severity_3, PCC_SUB_SUM_severity_4,PCC_SUB_SUM_severity_5
	)b

-------------------------------top severity2_CountRank------------------------------
select SubcontractorId as Issue_Count_IdBest, Contractor_Display as Issue_Count_Best,
Total_2_5_count as Best_2_5_count, DENSE_RANK() over (order by Total_2_5_count) as Issue_Count_RankBest--,
--Total_2_5_Cost,DENSE_RANK() over (order by Total_2_5_Cost_rank) as severity2_5_CostRank
into #icb
from #rankAll
order by Issue_Count_RankBest
-------------------------------top Issue-Cost-Best------------------------------
select SubcontractorId as Issue_Cost_IdBest, Contractor_Display as Issue_Cost_Best,
Total_2_5_Cost as Best_2_5_cost,DENSE_RANK() over (order by Total_2_5_Cost) as Issue_Cost_RankBest
into #i_COST_b
from #rankAll
order by Issue_Cost_RankBest

SELECT * into #issue
FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY Best_2_5_count) AS rn11 FROM #icb) AS t11
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY Best_2_5_cost) AS rn31 FROM #i_COST_b) AS t31
ON t11.rn11 = t31.rn31


--select SubcontractorId, Contractor_Display, Total_2_5_count,Total_2_5_count_rank,Total_2_5_Cost,Total_2_5_Cost_rank from #rankAll order by Total_2_5_count_rank

--select * from #best
--select * from #worst

--insert into #best select * from #worst 
--select * from #best

select x.*,
DENSE_RANK() over (order by Items_Repeated) as Items_Repeated_rank,
DENSE_RANK() over (order by Obs_PriorTalk_count) as Obs_PriorTalk_count_rank,
DENSE_RANK() over (order by Foreman_NOT_Present_count) as Foreman_NOT_Present_count_rank,

DENSE_RANK() over (order by PCC_SUB_SUM_repeat) as PCC_SUB_SUM_repeat_rank,
DENSE_RANK() over (order by PCC_SUB_SUM_PriorTalk) as PCC_SUB_SUM_PriorTalk_rank,
DENSE_RANK() over (order by PCC_SUB_SUM_Foreman) as PCC_SUB_SUM_Foreman_rank
into #rankAll_RPF
	
	from (
		select SubcontractorId, Contractor_Display, 
		isnull(sum(Items_Repeated),0) as Items_Repeated,
		isnull(sum(Obs_PriorTalk_count),0) as Obs_PriorTalk_count,
		isnull(sum(Foreman_NOT_Present_count),0) as Foreman_NOT_Present_count,

		isnull(sum(PCC_SUB_SUM_repeat),0) as PCC_SUB_SUM_repeat,
		isnull(sum(PCC_SUB_SUM_PriorTalk),0) as PCC_SUB_SUM_PriorTalk, 
		isnull(sum(PCC_SUB_SUM_Foreman),0) as PCC_SUB_SUM_Foreman

		from #rank 
		where 
		SubcontractorId =iif(@C_name1 is null,SubcontractorId, @C_name1)
		or (SubcontractorId=iif(@C_name2 is null,SubcontractorId, @C_name2) )
		or (SubcontractorId=iif(@C_name3 is null,SubcontractorId, @C_name3) )
		or (SubcontractorId=iif(@C_name4 is null,SubcontractorId, @C_name4) )
		or (SubcontractorId=iif(@C_name5 is null,SubcontractorId, @C_name5))
		group by SubcontractorId, Contractor_Display
		
	)x
--select * from #rankAll_RPF
-------------------------------top RepeatedCount-Best------------------------------
select SubcontractorId as RepeatedCount_IdBest, Contractor_Display as RepeatedCount_Best_list,
Items_Repeated as Best_RepeatedCount, DENSE_RANK() over (order by Items_Repeated) as RepeatedCount_RankBest
into #RepeatedCount_RankBest
from #rankAll_RPF
order by RepeatedCount_RankBest

-------------------------------top RepeatedCOST-Best------------------------------
select SubcontractorId as RepeatedCOST_IdBest, Contractor_Display as RepeatedCOST_Best_list,
PCC_SUB_SUM_repeat as Best_RepeatedCOST, DENSE_RANK() over (order by PCC_SUB_SUM_repeat) as RepeatedCOST_RankBest
into #RepeatedCOST_RankBest
from #rankAll_RPF
order by RepeatedCOST_RankBest

SELECT * into #repeat
FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCount_RankBest) AS rn1 FROM #RepeatedCount_RankBest) AS t1
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCOST_RankBest) AS rn3 FROM #RepeatedCOST_RankBest) AS t3
ON t1.rn1 = t3.rn3

-------------------------------top PriorTalk-COUNT-Best------------------------------
select SubcontractorId as PriorTalkCOUNT_IdBest, Contractor_Display as PriorTalk_COUNT_Best_list,
Obs_PriorTalk_count as BestPriorTalk_COUNT,DENSE_RANK() over (order by Obs_PriorTalk_count) as PriorTalk_COUNT_RankBest
into #PriorTalk_COUNT_RankBest
from #rankAll_RPF
order by PriorTalk_COUNT_RankBest

-------------------------------top PriorTalk-COST-Best------------------------------
select SubcontractorId as PriorTalkCOST_IdBest, Contractor_Display as PriorTalk_COST_Best_list,
PCC_SUB_SUM_PriorTalk as BestPriorTalk_COST,DENSE_RANK() over (order by PCC_SUB_SUM_PriorTalk) as PriorTalk_COST_RankBest
into #PriorTalk_COST_RankBest
from #rankAll_RPF
order by PriorTalk_COST_RankBest

SELECT * into #talk
from (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COUNT_RankBest) AS rn5 FROM #PriorTalk_COUNT_RankBest) AS t5
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COST_RankBest) AS rn7 FROM #PriorTalk_COST_RankBest) AS t7
ON t5.rn5 = t7.rn7

select SubcontractorId as ForemanCOUNT_IdBest, Contractor_Display as Foreman_COUNT_Best_list,
Foreman_NOT_Present_count as Best_ForemanCOUNT,DENSE_RANK() over (order by Foreman_NOT_Present_count) as ForemanCOUNT_RankBest
into #ForemanCOUNT_RankBest
from #rankAll_RPF
order by ForemanCOUNT_RankBest
-------------------------------top Foreman-COST-Best------------------------------
select SubcontractorId as ForemanCOST_IdBest, Contractor_Display as ForemanCOST_Best_list,
PCC_SUB_SUM_Foreman as Best_ForemanCOST,DENSE_RANK() over (order by PCC_SUB_SUM_Foreman) as ForemanCOST_RankBest
into #ForemanCOST_RankBest
from #rankAll_RPF
order by ForemanCOST_RankBest

SELECT * into #forman
FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOUNT_RankBest) AS rn9 FROM #ForemanCOUNT_RankBest) AS t9
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOST_RankBest) AS rn11 FROM #ForemanCOST_RankBest) AS t11
ON t9.rn9 = t11.rn11
------------------------------------------------------------------------------------------
--set @i = 'i' set @r = 'r' set @p = 'p' set @f = 'f' set @all = 'all'
--select * from #issue where @i = 'i' -- or @i is null
--select * from #repeat where @r = 'r'
--select * from #talk where @p = 'p'
--select * from #forman where @f = 'f'
IF (@i = 'i')
    select * from #issue 
ELSE if ( @i = 'r')
    select * from #repeat 
ELSE if ( @i = 'p')
    select * from #talk 
ELSE if ( @i = 'f')
    select * from #forman 
ELSE 
	select * from #issue 
	FULL OUTER JOIN #repeat on #issue.rn11 = #repeat.rn1
	FULL OUTER JOIN #talk on #issue.rn11 = #talk.rn5
	FULL OUTER JOIN #forman on #issue.rn11 = #forman.rn11
-----------------------------------------------------------------------------------------

drop table #rank
drop table #rankAll
drop table #icb
drop table #i_COST_b

drop table #rankAll_RPF
drop table #RepeatedCount_RankBest
drop table #RepeatedCOST_RankBest


drop table #PriorTalk_COUNT_RankBest
drop table #PriorTalk_COST_RankBest


drop table #ForemanCOUNT_RankBest
drop table #ForemanCOST_RankBest

drop table #issue
drop table #repeat
drop table #talk
drop table #forman

--exec [dbo].[DrillDownReport_Severity_Issue]'09', '20','2020-01-01','2022-01-01','','','','','','i'

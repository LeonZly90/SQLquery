--exec [dbo].[DrillDownReport_1] '05', '20','2020-01-01','2022-01-01'
declare @StartDate DATETIME,@EndDate DATETIME,@Div nvarchar(100),@SubDiv nvarchar(100),
@C_name1 nvarchar(100),@C_name2 nvarchar(100),@C_name3 nvarchar(100),@C_name4 nvarchar(100),@C_name5 nvarchar(100),
@Company nvarchar(100)


set @StartDate = '2020-01-01'
set @EndDate = '2022-01-01'
set @Div = '09'
set @SubDiv = '20'
set @Company = 'PCC'
set @C_name1 = 'Loch' set @C_name2 = 'SPG' set @C_name3 = 'PCC'set @C_name4 = 'Rockwell'set @C_name5 = ''
--exec dbo.[DrillDownReport_scpirtf] @Div,@SubDiv, @StartDate, @EndDate
--exec [dbo].[DrillDownReport_1] @Div,@SubDiv, @StartDate, @EndDate

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
exec dbo.[DrillDownReport_scpirtf] @Div,@SubDiv, @StartDate, @EndDate, @Company

select * into #rank from @drill; --select * from #rank


--------------------------------------------------------------------
--declare @var int
--set @var = (select SubcontractorId from #rank)
--print @var

select a.*,
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
		(Contractor_Display like '%'+@C_name1+'%')
		or (Contractor_Display like '%'+@C_name2+'%') 
		or (Contractor_Display like '%'+@C_name3+'%') 
		or (Contractor_Display like  '%'+@C_name4+'%') 
		or (Contractor_Display like '%'+@C_name5+'%')
		group by SubcontractorId, Contractor_Display
		
	)a
select SubcontractorId, Contractor_Display,
Items_Repeated, Items_Repeated_rank,
PCC_SUB_SUM_repeat,PCC_SUB_SUM_repeat_rank 
from #rankAll_RPF 
order by Items_Repeated_rank
---------------------------------top 5 RepeatedCount-Best------------------------------
--select top 5 SubcontractorId as RepeatedCount_IdBest, Contractor_Display as RepeatedCount_Best_list,
--Items_Repeated as Best_RepeatedCount, DENSE_RANK() over (order by Items_Repeated) as RepeatedCount_RankBest
--into #RepeatedCount_RankBest
--from #rankAll_RPF
--order by RepeatedCount_RankBest

---------------------------------top 5 RepeatedCount-Worst------------------------------
--select top 5 SubcontractorId as RepeatedCount_IdWorst, Contractor_Display as RepeatedCount_Worst_list,
--Items_Repeated as Worst_RepeatedCount, DENSE_RANK() over (order by Items_Repeated) as RepeatedCount_RankWorst
--into #RepeatedCount_RankWorst
--from #rankAll_RPF
--order by RepeatedCount_RankWorst desc

---------------------------------top 5 RepeatedCOST-Best------------------------------
--select top 5 SubcontractorId as RepeatedCOST_IdBest, Contractor_Display as RepeatedCOST_Best_list,
--PCC_SUB_SUM_repeat_rank as Best_RepeatedCOST, DENSE_RANK() over (order by PCC_SUB_SUM_repeat_rank) as RepeatedCOST_RankBest
--into #RepeatedCOST_RankBest
--from #rankAll_RPF
--order by RepeatedCOST_RankBest
---------------------------------top 5 RepeatedCOST-Worst------------------------------
--select top 5 SubcontractorId as RepeatedCOST_IdWorst, Contractor_Display as RepeatedCOST_Worst_list,
--PCC_SUB_SUM_repeat_rank as Worst_RepeatedCOST, DENSE_RANK() over (order by PCC_SUB_SUM_repeat_rank) as RepeatedCOST_RankWorst
--into #RepeatedCOST_RankWorst
--from #rankAll_RPF
--order by RepeatedCOST_RankWorst desc

---------------------------------top 5 PriorTalk-COUNT-Best------------------------------
--select top 5 SubcontractorId as PriorTalkCOUNT_IdBest, Contractor_Display as PriorTalk_COUNT_Best_list,
--Obs_PriorTalk_count as BestPriorTalk_COUNT,DENSE_RANK() over (order by Obs_PriorTalk_count) as PriorTalk_COUNT_RankBest
--into #PriorTalk_COUNT_RankBest
--from #rankAll_RPF
--order by PriorTalk_COUNT_RankBest

---------------------------------top 5 PriorTalk-COUNT-Worst------------------------------
--select top 5 SubcontractorId as PriorTalkCOUNT_IdWorst, Contractor_Display as PriorTalk_COUNT_Worst_list,
--Obs_PriorTalk_count as WorstPriorTalk_COUNT,DENSE_RANK() over (order by Obs_PriorTalk_count) as PriorTalk_COUNT_RankWorst
--into #PriorTalk_COUNT_RankWorst
--from #rankAll_RPF
--order by PriorTalk_COUNT_RankWorst desc

---------------------------------top 5 PriorTalk-COST-Best------------------------------
--select top 5 SubcontractorId as PriorTalkCOST_IdBest, Contractor_Display as PriorTalk_COST_Best_list,
--PCC_SUB_SUM_PriorTalk_rank as BestPriorTalk_COST,DENSE_RANK() over (order by PCC_SUB_SUM_PriorTalk_rank) as PriorTalk_COST_RankBest
--into #PriorTalk_COST_RankBest
--from #rankAll_RPF
--order by PriorTalk_COST_RankBest

---------------------------------top 5 PriorTalk-COST-Worst------------------------------
--select top 5 SubcontractorId as PriorTalkCOST_IdWorst, Contractor_Display as PriorTalk_COST_Worst_list,
--PCC_SUB_SUM_PriorTalk_rank as WorstPriorTalk_COST,DENSE_RANK() over (order by PCC_SUB_SUM_PriorTalk_rank) as PriorTalk_COST_RankWorst
--into #PriorTalk_COST_RankWorst
--from #rankAll_RPF
--order by PriorTalk_COST_RankWorst desc

---------------------------------top 5 Foreman-COUNT-Best------------------------------
--select top 5 SubcontractorId as ForemanCOUNT_IdBest, Contractor_Display as Foreman_COUNT_Best_list,
--Foreman_NOT_Present_count_rank as Best_ForemanCOUNT,DENSE_RANK() over (order by Foreman_NOT_Present_count_rank) as ForemanCOUNT_RankBest
--into #ForemanCOUNT_RankBest
--from #rankAll_RPF
--order by ForemanCOUNT_RankBest

---------------------------------top 5 Foreman-COUNT-Worst------------------------------
--select top 5 SubcontractorId as ForemanCOUNT_IdWorst, Contractor_Display as Foreman_COUNT_Worst_list,
--Foreman_NOT_Present_count_rank as Worst_ForemanCOUNT,DENSE_RANK() over (order by Foreman_NOT_Present_count_rank) as ForemanCOUNT_RankWorst
--into #ForemanCOUNT_RankWorst
--from #rankAll_RPF
--order by ForemanCOUNT_RankWorst desc

---------------------------------top 5 Foreman-COST-Best------------------------------
--select top 5 SubcontractorId as ForemanCOST_IdBest, Contractor_Display as ForemanCOST_Best_list,
--PCC_SUB_SUM_Foreman_rank as Best_ForemanCOST,DENSE_RANK() over (order by PCC_SUB_SUM_Foreman_rank) as ForemanCOST_RankBest
--into #ForemanCOST_RankBest
--from #rankAll_RPF
--order by ForemanCOST_RankBest

---------------------------------top 5 Foreman-COST-Worst------------------------------
--select top 5 SubcontractorId as ForemanCOST_IdWorst, Contractor_Display as ForemanCOST_Worst_list,
--PCC_SUB_SUM_Foreman_rank as Worst_ForemanCOST,DENSE_RANK() over (order by PCC_SUB_SUM_Foreman_rank) as ForemanCOST_RankWorst
--into #ForemanCOST_RankWorst
--from #rankAll_RPF
--order by ForemanCOST_RankWorst desc
--------------------------------------------------------------------------------------------

--SELECT *
--FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCount_RankBest) AS rn1 FROM #RepeatedCount_RankBest) AS t1
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCount_RankWorst) AS rn2 FROM #RepeatedCount_RankWorst) AS t2
--ON t1.rn1 = t2.rn2
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCOST_RankBest) AS rn3 FROM #RepeatedCOST_RankBest) AS t3
--ON t1.rn1 = t3.rn3
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY RepeatedCOST_RankWorst) AS rn4 FROM #RepeatedCOST_RankWorst) AS t4
--ON t1.rn1 = t4.rn4

--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COUNT_RankBest) AS rn5 FROM #PriorTalk_COUNT_RankBest) AS t5
--ON t1.rn1 = t5.rn5
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COUNT_RankWorst) AS rn6 FROM #PriorTalk_COUNT_RankWorst) AS t6
--ON t1.rn1 = t6.rn6
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COST_RankBest) AS rn7 FROM #PriorTalk_COST_RankBest) AS t7
--ON t1.rn1 = t7.rn7
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY PriorTalk_COST_RankWorst) AS rn8 FROM #PriorTalk_COST_RankWorst) AS t8
--ON t1.rn1 = t8.rn8

--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOUNT_RankBest) AS rn9 FROM #ForemanCOUNT_RankBest) AS t9
--ON t1.rn1 = t9.rn9
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOUNT_RankWorst) AS rn10 FROM #ForemanCOUNT_RankWorst) AS t10
--ON t1.rn1 = t10.rn10
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOST_RankBest) AS rn11 FROM #ForemanCOST_RankBest) AS t11
--ON t1.rn1 = t11.rn11
--FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOST_RankWorst) AS rn12 FROM #ForemanCOST_RankWorst) AS t12
--ON t1.rn1 = t12.rn12

drop table #rank
drop table #rankAll_RPF
--drop table #RepeatedCount_RankBest
--drop table #RepeatedCount_RankWorst
--drop table #RepeatedCOST_RankBest
--drop table #RepeatedCOST_RankWorst

--drop table #PriorTalk_COUNT_RankBest
--drop table #PriorTalk_COUNT_RankWorst
--drop table #PriorTalk_COST_RankBest
--drop table #PriorTalk_COST_RankWorst

--drop table #ForemanCOUNT_RankBest
--drop table #ForemanCOUNT_RankWorst
--drop table #ForemanCOST_RankBest
--drop table #ForemanCOST_RankWorst

--exec [dbo].[DrillDownReport_SeverityCount]'05', '20','2020-01-01','2022-01-01','rock','denk','','',''

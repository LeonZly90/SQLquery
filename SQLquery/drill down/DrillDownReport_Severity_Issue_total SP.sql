USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[DrillDownReport_Severity_Issue_total]    Script Date: 2/1/2022 8:21:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[DrillDownReport_Severity_Issue_total] 
	-- Add the parameters for the stored procedure here
	@Div nvarchar(100),@SubDiv nvarchar(100),
	@StartDate DATETIME,@EndDate DATETIME,@Company nvarchar(100),
	@C_name1 nvarchar(100),@C_name2 nvarchar(100),@C_name3 nvarchar(100),@C_name4 nvarchar(100),@C_name5 nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

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

select * into #rank from @drill; --select * from #rank




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
		(Contractor_Display like '%'+@C_name1+'%' )
		or (Contractor_Display like '%'+@C_name2+'%') 
		or (Contractor_Display like '%'+@C_name3+'%') 
		or (Contractor_Display like  '%'+@C_name4+'%') 
		or (Contractor_Display like '%'+@C_name5+'%')
		or 		
		(SubcontractorId like '%'+@C_name1+'%' )
		or (SubcontractorId like '%'+@C_name2+'%') 
		or (SubcontractorId like '%'+@C_name3+'%') 
		or (SubcontractorId like  '%'+@C_name4+'%') 
		or (SubcontractorId like '%'+@C_name5+'%')

		group by SubcontractorId, Contractor_Display
		)a group by SubcontractorId, Contractor_Display,severity_2,severity_3,severity_4,severity_5,PCC_SUB_SUM_severity_2,PCC_SUB_SUM_severity_3, PCC_SUB_SUM_severity_4,PCC_SUB_SUM_severity_5
	)b

--select * from #rankAll order by Total_2_5_count desc

-------------------------------top 5 * from #rankAll order by severity2_CountRank desc
select SubcontractorId as Issue_Count_IdBest, Contractor_Display as Issue_Count_Best,
Total_2_5_count as Best_2_5_count, DENSE_RANK() over (order by Total_2_5_count) as Issue_Count_RankBest--,
--Total_2_5_Cost,DENSE_RANK() over (order by Total_2_5_Cost_rank) as severity2_5_CostRank
into #icb
from #rankAll
order by Issue_Count_RankBest
-------------------------------top 5 Issue-Cost-Best------------------------------
select SubcontractorId as Issue_Cost_IdBest, Contractor_Display as Issue_Cost_Best,
Total_2_5_Cost as Best_2_5_cost,DENSE_RANK() over (order by Total_2_5_Cost) as Issue_Cost_RankBest
into #i_COST_b
from #rankAll
order by Issue_Cost_RankBest

SELECT *
FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY Best_2_5_count) AS rn1 FROM #icb) AS t1
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY Best_2_5_cost) AS rn3 FROM #i_COST_b) AS t3
ON t1.rn1 = t3.rn3


--select SubcontractorId, Contractor_Display, Total_2_5_count,Total_2_5_count_rank,Total_2_5_Cost,Total_2_5_Cost_rank from #rankAll order by Total_2_5_count_rank

--select * from #best
--select * from #worst

--insert into #best select * from #worst 
--select * from #best

drop table #rank
drop table #rankAll
drop table #icb
drop table #i_COST_b

--exec [dbo].[DrillDownReport_Severity_Issue_total]'09', '20','2020-01-01','2022-01-01','PCC','rock','denk','','',''
END

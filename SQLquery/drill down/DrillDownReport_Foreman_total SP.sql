USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[DrillDownReport_Foreman_total]    Script Date: 2/1/2022 8:39:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[DrillDownReport_Foreman_total] -- DrillDownReport_scpirtf --> DrillDownReport_1 --> rank --> issueTotal//-issue
																									 --> R-P-F//-RPF --9 total

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


--------------------------------------------------------------------

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
				or 		
		(SubcontractorId like '%'+@C_name1+'%' )
		or (SubcontractorId like '%'+@C_name2+'%') 
		or (SubcontractorId like '%'+@C_name3+'%') 
		or (SubcontractorId like  '%'+@C_name4+'%') 
		or (SubcontractorId like '%'+@C_name5+'%')
		group by SubcontractorId, Contractor_Display
		
	)a

--select SubcontractorId, Contractor_Display,
--Foreman_NOT_Present_count, Foreman_NOT_Present_count_rank,
--PCC_SUB_SUM_Foreman,PCC_SUB_SUM_Foreman_rank 
--from #rankAll_RPF 
--order by Foreman_NOT_Present_count_rank
-------------------------------top Foreman-COUNT-Best------------------------------
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

SELECT *
FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOUNT_RankBest) AS rn9 FROM #ForemanCOUNT_RankBest) AS t9
FULL OUTER JOIN  (SELECT *,ROW_NUMBER() OVER (ORDER BY ForemanCOST_RankBest) AS rn11 FROM #ForemanCOST_RankBest) AS t11
ON t9.rn9 = t11.rn11

drop table #rank
drop table #rankAll_RPF
drop table #ForemanCOUNT_RankBest
drop table #ForemanCOST_RankBest
END
--exec [dbo].[DrillDownReport_Foreman_total]'09', '20','2020-01-01','2022-01-01','PCC','rock','denk','','',''

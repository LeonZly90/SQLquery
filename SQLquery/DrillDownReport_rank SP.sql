USE [QualityAppDev]
GO
/****** Object:  StoredProcedure [dbo].[DrillDownReport_rank]    Script Date: 1/31/2022 10:31:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[DrillDownReport_rank]
	-- Add the parameters for the stored procedure here
	@Div nvarchar(100),@SubDiv nvarchar(100),
	@StartDate DATETIME,@EndDate DATETIME,
	@C_name1 nvarchar(100),@C_name2 nvarchar(100),@C_name3 nvarchar(100),@C_name4 nvarchar(100),@C_name5 nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
--exec [dbo].[DrillDownReport_1] @Div_SubDiv, @StartDate, @EndDate

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
exec dbo.[DrillDownReport_scpirtf] @Div,@SubDiv, @StartDate, @EndDate

select * into #rank from @drill; --select * from #rank

select SubcontractorId, Contractor_Display, 
isnull(sum(severity_2),0),
DENSE_RANK() over (order by severity_2) as severity2_CountRank,
isnull(sum(PCC_SUB_SUM_severity_2),0), 
DENSE_RANK() over (order by PCC_SUB_SUM_severity_2) as severity2_CostRank,

isnull(sum(severity_3),0),
DENSE_RANK() over (order by severity_3) as severity3_CountRank,
isnull(sum(PCC_SUB_SUM_severity_3),0), 
DENSE_RANK() over (order by PCC_SUB_SUM_severity_3) as severity3_CostRank,

isnull(sum(severity_4),0),
DENSE_RANK() over (order by severity_4) as severity4_CountRank,
isnull(sum(PCC_SUB_SUM_severity_4),0),
DENSE_RANK() over (order by PCC_SUB_SUM_severity_4) as severity4_CostRank,

isnull(sum(severity_5),0),
DENSE_RANK() over (order by severity_5) as severity5_CountRank,
isnull(sum(PCC_SUB_SUM_severity_5),0), 
DENSE_RANK() over (order by PCC_SUB_SUM_severity_5) as severity5_CostRank,

isnull(sum(Items_Repeated),0),
DENSE_RANK() over (order by Items_Repeated) as Items_Repeated_CountRank,
isnull(sum(PCC_SUB_SUM_repeat),0),
DENSE_RANK() over (order by PCC_SUB_SUM_repeat) as PCC_SUB_SUM_repeat_CostRank,

isnull(sum(Obs_PriorTalk_count),0),
DENSE_RANK() over (order by Obs_PriorTalk_count) as Obs_PriorTalkt_CountRank,
isnull(sum(PCC_SUB_SUM_PriorTalk),0),
DENSE_RANK() over (order by PCC_SUB_SUM_PriorTalk) as PCC_SUB_SUM_PriorTalk_CostRank,

isnull(sum(Foreman_NOT_Present_count),0),
DENSE_RANK() over (order by Foreman_NOT_Present_count) as Foreman_NOT_Present_countRank,
isnull(sum(PCC_SUB_SUM_Foreman),0),
DENSE_RANK() over (order by PCC_SUB_SUM_Foreman) as PCC_SUB_SUM_Foreman_CostRank

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

drop table #rank
END
-- exec [dbo].[DrillDownReport_rank]'09', '20','2020-01-01','2022-01-01','rock','denk','','',''
--exec dbo.[COST_Quality_table1]
-------------------------------------------------
declare 
@ProjectID nvarchar(50),@Company nvarchar(50),@StartDate DATETIME,@EndDate DATETIME,

@now date,@i int

--@ProjectStartDate date,@ProjectEndDate DATETIME, @ProjectNoName nvarchar(100), @Project_Company nvarchar(50)

set @ProjectID = '1108668'--1108668 2000592
set @Company = 'PCC'--'PCC'
set @StartDate = '2021-01-01'--'2021-01-01' 
set @EndDate = '2021-11-01'--'2022-01-01' --start + i week

set @now = GETDATE()
set @i = 1 --1 week

declare @COST_Quality table 

(Project_No nvarchar(50), ProjectNoName nvarchar(100), Project_Company nvarchar(50), Obs_date DATETIME, ObsComplianceDate DATETIME, ObsDurationDay int, 
ObsAverPerDay float, [PCC+SUB SUM] float,ProjectCost float, ProjectStartDate DATETIME, ProjectTotalWeek int, ProjectEndDate DATETIME, 
WeeksTillToday int, ObsWeeksFromStart int, CompletePercent float)
INSERT into @COST_Quality 
exec dbo.[COST_Quality_table1]

--select * from @COST_Quality

declare @InputWeekRange int,@ObsDayRange int, @Obs_week_calc int

select  IDENTITY(INT, 1, 1) AS id,*,@InputWeekRange as Weeks,@ObsDayRange as ObsWeeks, @Obs_week_calc as Obs_week_calc into #temp1 
from @COST_Quality where (ProjectNoName like  '%'+IsNull(@ProjectID,ProjectNoName)+'%') and (Project_Company = IsNull(@Company,Project_Company) or @Company='')

--select * from #temp1
--drop table #temp1

declare @RowCount int
set @RowCount = 0
select @RowCount = count(0) from #temp1

declare @PID int set @PID = 1 while @PID <= @RowCount
begin
set @InputWeekRange = 
	(SELECT DATEDIFF(ww,	
					CASE 
						WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0 
						WHEN @EndDate <= ProjectStartDate then 0
						WHEN @StartDate = '' then ProjectStartDate
						WHEN @StartDate <= ProjectStartDate then ProjectStartDate

						WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate and @StartDate >=ProjectStartDate then @StartDate
						WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate and @StartDate <=ProjectStartDate then ProjectStartDate
						WHEN ProjectEndDate >= @now  and @now >= @StartDate then @StartDate
					END ,	
						
					CASE 							 
						WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0
						WHEN @EndDate <= ProjectStartDate then 0
						WHEN ProjectEndDate <= @now and @EndDate = '' then ProjectEndDate
						WHEN ProjectEndDate >= @now and @EndDate = '' then @now

						WHEN ProjectEndDate <= @now and @EndDate <= ProjectEndDate and @EndDate >= ProjectStartDate then @EndDate
						WHEN ProjectEndDate <= @now and @EndDate >= ProjectEndDate then ProjectEndDate

						WHEN ProjectEndDate >= @now and @EndDate <= @now and @EndDate >= ProjectStartDate then @EndDate							
						WHEN ProjectEndDate >= @now and @StartDate>=ProjectStartDate and @EndDate >= @now then @now
					END
	)from #temp1 where (id=@PID))
	set @ObsDayRange = 
	(SELECT DATEDIFF(dd,	
					CASE 
						WHEN @StartDate >= @now or @StartDate >= ObsComplianceDate then 0 
						WHEN @EndDate <= Obs_date then 0						
						WHEN @StartDate = '' then Obs_date
						WHEN @StartDate <= Obs_date then Obs_date

						WHEN ObsComplianceDate <= @now  and @StartDate <= ObsComplianceDate and @StartDate >=Obs_date then @StartDate
						WHEN ObsComplianceDate <= @now  and @StartDate <= ObsComplianceDate and @StartDate <=Obs_date then Obs_date
						WHEN ObsComplianceDate >= @now  and @now >= @StartDate then @StartDate
					END ,	
						
					CASE 							 
						WHEN @StartDate >= @now or @StartDate >= ObsComplianceDate then 0
						WHEN @EndDate <= Obs_date then 0
						WHEN ObsComplianceDate <= @now and @EndDate = '' then ObsComplianceDate
						WHEN ObsComplianceDate >= @now and @EndDate = '' then @now

						WHEN ObsComplianceDate <= @now and @EndDate <= ObsComplianceDate and @EndDate >= Obs_date then @EndDate
						WHEN ObsComplianceDate <= @now and @EndDate >= ObsComplianceDate then ObsComplianceDate

						WHEN ObsComplianceDate >= @now and @EndDate <= @now and @EndDate >= Obs_date then @EndDate							
						WHEN ObsComplianceDate >= @now and @StartDate>=Obs_date and @EndDate >= @now then @now
					END
	)from #temp1 where (id=@PID))
update #temp1 set Weeks = (@InputWeekRange) where id = @PID
update #temp1 set ObsWeeks = case when (@ObsDayRange)%7>0 then (@ObsDayRange)/7+1 
							else (@ObsDayRange)/7 end where id = @PID
update #temp1 set Obs_week_calc = isnull([PCC+SUB SUM]/nullif(case when (@ObsDayRange)%7>0 then (@ObsDayRange)/7+1 
							else (@ObsDayRange)/7 end ,0),0) where id = @PID
update #temp1 set ObsWeeksFromStart = case when ObsWeeksFromStart>@InputWeekRange then @InputWeekRange else ObsWeeksFromStart end
				where id = @PID --no larger than the input week range
set @PID = @PID +1
end

--select * from #temp1
--drop table #temp1

--get weeks
DECLARE @maxV INT, @j INT
DECLARE @fieldName NVARCHAR(20)
DECLARE @alterSql NVARCHAR(256)

--SET @maxV = (SELECT MAX(Weeks) FROM #temp1)
--SET @j = 1;
--WHILE @j <= @maxV
--BEGIN
--	SET @fieldName = 'new' + CAST(@j AS NVARCHAR(20));
--	SET @alterSql = 'ALTER TABLE #temp1 ADD '+@fieldName+' INT';
--	EXEC(@alterSql);
--	SET @j += 1;
--END
-------------------------
DECLARE @maxObs INT, @z INT
DECLARE @obsFieldName NVARCHAR(20)
DECLARE @obsAlterSql NVARCHAR(256)

SET @maxV = (SELECT MAX(Weeks) FROM #temp1)
SET @maxObs = (SELECT MAX(ObsWeeks) FROM #temp1)
SET @z = 1;
WHILE @z <= @maxV
BEGIN
	SET @fieldName = 'new' + CAST(@z AS NVARCHAR(20));
	SET @obsFieldName = 'ObsNew' + CAST(@z AS NVARCHAR(20));
	SET @alterSql = 'ALTER TABLE #temp1 ADD '+@fieldName+' INT';
	SET @obsAlterSql = 'ALTER TABLE #temp1 ADD '+@obsFieldName+' INT';
	EXEC(@alterSql);
	EXEC(@obsAlterSql);
	SET @z += 1;
END
------------------------------
--select * from #temp1
--drop table #temp1

--Total_P_Cost_dvd_Total_Week
declare @Total_P_Cost_dvd_Total_Week int
set @Total_P_Cost_dvd_Total_Week = 0
select @Total_P_Cost_dvd_Total_Week = (select ProjectCost/Weeks) from #temp1
--print(@Total_P_Cost_dvd_Total_Week)
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------

-- cursor!!!
DECLARE @V_Tuple AS INT;
--DECLARE @fieldName NVARCHAR(20)
DECLARE @updateSql NVARCHAR(256);
DECLARE @ObsV_Tuple AS INT; --obs
DECLARE @ObsUpdateSql NVARCHAR(256);--obs
DECLARE @k AS INT;
DECLARE @ObsK AS INT;--obs
declare @PCC_SUB_SUM_per_week int--obs
DECLARE @kk AS INT;

DECLARE leon CURSOR FAST_FORWARD FOR
    SELECT Weeks,ObsWeeks FROM #temp1
    
OPEN leon;

FETCH NEXT FROM leon INTO @V_Tuple,@ObsV_Tuple;

WHILE @@FETCH_STATUS=0
BEGIN
	SET @k = 1;
	SET @kk = 1;
	WHILE @k <= @V_Tuple
		BEGIN
			SET @fieldName = 'new' + CAST(@k AS NVARCHAR(20));
			--SET @obsFieldName = 'ObsNew' + CAST(@k AS NVARCHAR(20));--obs
			SET @updateSql = 'UPDATE #temp1 SET '+@fieldName+' = ' + CAST(@k*@Total_P_Cost_dvd_Total_Week AS NVARCHAR(20)) + ' WHERE [Weeks] = ' + CAST(@V_Tuple AS NVARCHAR(20))+'';
			--SET @ObsUpdateSql = 'UPDATE #temp1 SET '+@obsFieldName+' = ' + CAST(@k AS NVARCHAR(20)) + ' WHERE [ObsWeeks] = ' + CAST(@ObsV_Tuple AS NVARCHAR(20))+'';
			EXEC(@updateSql);
			--EXEC(@ObsUpdateSql);
			SET @k += 1;
		END

	set @ObsK = 1;
	WHILE @ObsK <= @ObsV_Tuple --and @ObsK = (select ObsWeeksFromStart from #temp1 WHERE id = @ObsK) 
		--if @ObsK = (select ObsWeeksFromStart from #temp1 WHERE id = @ObsK) then
		BEGIN 
			SET @obsFieldName = 'ObsNew' + CAST(@ObsK AS NVARCHAR(20));--obs
			--SET @obsFieldName =  'ObsNew' + CAST((select ObsWeeksFromStart from #temp1 WHERE id = @kk) AS NVARCHAR(20));
			--SET @obsFieldName = 'ObsNew' + CAST(@ObsK-2+(select ObsWeeksFromStart from #temp1 WHERE id = @ObsK) AS NVARCHAR(20));--obs

			--set @PCC_SUB_SUM_per_week = (select Obs_week_calc from  #temp1 WHERE id = @ObsK)
			--set @PCC_SUB_SUM_per_week = (select ObsWeeksFromStart from  #temp1 WHERE id = @ObsK)

			SET @ObsUpdateSql = 'UPDATE #temp1 SET '+@obsFieldName+' = ' + CAST(@ObsK AS NVARCHAR(20)) + ' WHERE [ObsWeeks] = ' + CAST(@ObsV_Tuple AS NVARCHAR(20))+'' --+ ' and '+CAST(@ObsK AS NVARCHAR(20))+'='+ CAST((select ObsWeeksFromStart from #temp1 WHERE id = @ObsK) AS NVARCHAR(20));
			--SET @ObsUpdateSql = 'UPDATE #temp1 SET '+@obsFieldName+' = ' + CAST(@ObsK AS NVARCHAR(20)) + ' WHERE '+CAST(@ObsK AS NVARCHAR(20))+'= ' + CAST((select ObsWeeksFromStart from #temp1 WHERE id = @ObsK) AS NVARCHAR(20));

			EXEC(@ObsUpdateSql);
			--SET @kk = 1;
			SET @ObsK += 1; 
		END

    FETCH NEXT FROM leon INTO @V_Tuple,@ObsV_Tuple;
END

CLOSE leon;
DEALLOCATE leon;

select * from #temp1
drop table #temp1
--------------------------------------------------
--create table #a 
--DECLARE @Range INT = 10;
--with cte
--    as
--    (
--    select 1 as value
--    union all
--    select value + 1 from cte where value < @Range
--    )
--    select * from cte

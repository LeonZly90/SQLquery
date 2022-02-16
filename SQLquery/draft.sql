exec dbo.[COST_Quality_table1]
select * from #QTemp where Project_Company = 'PCCW' order by ProjectNoName
--drop table #temp1 #QTemp
select * from #temp1
select * from #temp2

create table #test (WeekCount int not null)
select * from #test
create table #test2 (ProjectNoName nvarchar(100), Project_Company nvarchar(50), Obs_date DATETIME, ObsComplianceDate DATETIME, ObsDurationDay int, ObsAverPerDay float, [PCC+SUB SUM] float,ProjectCost float, ProjectStartDate DATETIME, ProjectTotalWeek int, ProjectEndDate DATETIME, WeeksTillToday int, CompletePercent float, WeekCount int)
select * from #test2
select * from #test3

declare 
@ProjectID nvarchar(50),@Company nvarchar(50),@StartDate DATETIME,@EndDate DATETIME, 
@now date,@ProjectStartDate date,@ProjectEndDate DATETIME, @ProjectNoName nvarchar(100), @Project_Company nvarchar(50),
@i int, @InputWeekRange int, @RowCount int

set @i = 1 --1 week

set @RowCount = 0
set @ProjectID = ''--1801334
set @Company = 'PCC'
set @StartDate = '2021-01-01' 
set @EndDate = '2022-01-01' --start + i week
set @now = GETDATE()

declare @COST_Quality table (ProjectNoName nvarchar(100), Project_Company nvarchar(50), Obs_date DATETIME, ObsComplianceDate DATETIME, ObsDurationDay int, ObsAverPerDay float, [PCC+SUB SUM] float,ProjectCost float, ProjectStartDate DATETIME, ProjectTotalWeek int, ProjectEndDate DATETIME, WeeksTillToday int, CompletePercent float)
INSERT into @COST_Quality 
exec dbo.[COST_Quality_table1]
--set @ProjectNoName = (select top 1 ProjectNoName from @COST_Quality where (ProjectNoName like  '%'+IsNull(@ProjectID,ProjectNoName)+'%') and (Project_Company = IsNull(@Company,Project_Company) or @Company=''))


--create table #test2 
--(ProjectNoName nvarchar(100), Project_Company nvarchar(50), Obs_date DATETIME, ObsComplianceDate DATETIME, ObsDurationDay int, 
--ObsAverPerDay float, [PCC+SUB SUM] float,ProjectCost float, ProjectStartDate DATETIME, ProjectTotalWeek int, ProjectEndDate DATETIME, 
--WeeksTillToday int, CompletePercent float, 
--(WeekCount int)
select  IDENTITY(INT, 1, 1) AS id,*,@InputWeekRange as Weeks into #test2 from @COST_Quality where (ProjectNoName like  '%'+IsNull(@ProjectID,ProjectNoName)+'%') and (Project_Company = IsNull(@Company,Project_Company) or @Company='')
select @RowCount = count(0) from #test2
--print(@RowCount) -- row 477 for PCCW
--select @PID = min(id) from #test2 -- select * from #test2 -- drop table #test2

--print(@InputWeekRange)
declare @cmd varchar(100), @PID int
set @PID = 1
--while @PID is not null
while @PID <= @RowCount
begin

set @InputWeekRange = 
(SELECT DATEDIFF(ww,	
				CASE 
					WHEN @StartDate = '' then ProjectStartDate
					WHEN @StartDate <= ProjectStartDate then ProjectStartDate
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0 
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate and @StartDate >=ProjectStartDate then @StartDate
					WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate and @StartDate <=ProjectStartDate then ProjectStartDate
					WHEN ProjectEndDate >= @now  and @now >= @StartDate then @StartDate
				END ,	
						
				CASE 							 
					WHEN ProjectEndDate <= @now and @EndDate = '' then ProjectEndDate
					WHEN ProjectEndDate >= @now and @EndDate = '' then @now
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now and @EndDate <= ProjectEndDate and @EndDate >= ProjectStartDate then @EndDate
					WHEN ProjectEndDate <= @now and @EndDate >= ProjectEndDate then ProjectEndDate

					WHEN ProjectEndDate >= @now and @EndDate <= @now and @EndDate >= ProjectStartDate then @EndDate							
					WHEN ProjectEndDate >= @now and @StartDate>=ProjectStartDate and @EndDate >= @now then @now
				END
				)from #test2 where (id=@PID))
update #test2 set Weeks = (@InputWeekRange) where id = @PID --select * from #test2-- drop table #test2

	--while @i <= @InputWeekRange
	--SET @cmd= CONCAT('ALTER TABLE #test2 ADD WeekCount_', DATEDIFF(ww,@StartDate,@EndDate),' varchar(20)')
	--EXEC(@cmd)
	----begin
	--------PRINT 'The counter value is = ' + CONVERT(VARCHAR,@i)
	

	------SET @cmd= CONCAT('ALTER TABLE #test2 ADD WeekCount_',@i,' varchar(20)')
	----update #test2 set 
	------EXEC(@cmd)
	--------update #test2 set WeekCount_0 = @i
	--set @i=@i+1
	
--select @PID = min( id ) from #test2 where id > @PID
set @PID = @PID +1
end
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------


select * into #test3 from #test2 --select * from #test3-- drop table #test3
	while @i <= DATEDIFF(ww,@StartDate,@EndDate)
	begin
	SET @cmd= CONCAT('ALTER TABLE #test3 ADD WeekCount_', @i,' varchar(20)')
	EXEC(@cmd)
	set @i=@i+1	
	end


select * into #test4 from #test3 order by id --select * from #test4-- drop table #test4

declare @WeekPID int, @DateCount int, @j int, @WeekName nvarchar(20),@sql int
set @WeekPID =1
--set @DateCount =(select Weeks from #test4 where id = @WeekPID)
print(@DateCount)
set @j = 1
while @WeekPID <= (select count(*) from #test4)
begin
	if (select Weeks from #test4 where id = @WeekPID)>0 
		
		begin
		set @WeekName = 'WeekCount_'+ cast(@j as nvarchar(10))	
		set @sql = 'update #test4 set '+@WeekName+' = 0 where '+@WeekName+' is null'
		exec(@sql)
		--set @sql = N'update [#test4] set ['+@WeekName+'] =  '+@j+'where #test4.id = '+@WeekPID+''
		
		--exec(@sql)

			--while @j <= (select Weeks from #test4 where id = @WeekPID)
			--	begin
			--	set @name = ' WeekCount_'+ @j
			--	update #test4 set @name = '123' from #test4 where #test4.id = @WeekPID
			--	set @j=@j+1
			--	end
		end
set @WeekPID=@WeekPID+1		
end

select * from #test4
select * from #test2
select * from #test3

DROP TABLE #test2
DROP TABLE #test3
DROP TABLE #test4
-----
CREATE TABLE #TEMP_TABLE(ID INT PRIMARY KEY IDENTITY,ID_KILN VARCHAR(4))
DECLARE
  @I int=1,
  @JML_NO int=10,
  @cmd varchar(100)
WHILE @I <= @JML_NO
BEGIN
    SET @cmd=CONCAT('ALTER TABLE #TEMP_TABLE ADD NoUrut_',@I,' varchar(20)')

    EXEC(@cmd)

    SET @I += 1
END
SELECT *
FROM #TEMP_TABLE
DROP TABLE #TEMP_TABLE
----


declare 
@ProjectID nvarchar(50),@Company nvarchar(50),@StartDate DATE,@EndDate DATE,
@now date,@i int

set @i = 1 --1 week
set @now = GETDATE()

set @StartDate = '2021-01-01' 
set @EndDate = '2022-01-01' --start + i week
set @ProjectID = ''
set @Company = 'PCCW'

--Cost Quality formula

select 
--*
--,
ProjectNoName,Project_Company,
ObsAverPerDay,(select DATEDIFF(DAY,PccSubStart,PccSubEnd)) as InputDayRange,InputWeekRange,ProjectTotalWeek,
ObsAverPerDay*(select DATEDIFF(DAY,PccSubStart,PccSubEnd)) as PCCSUBSUM
, case when round(cast(InputWeekRange as float)/cast(ProjectTotalWeek as float),4)>1 then 1
else round(cast(InputWeekRange as float)/cast(ProjectTotalWeek as float),4) end as FirstPercent,
ProjectCost,

isnull(ObsAverPerDay*(select DATEDIFF(DAY,PccSubStart,PccSubEnd))/ nullif(( --PCC and sub cost during the input date range
(case when cast(InputWeekRange as float)/cast(ProjectTotalWeek as float)>1 then 1 -- project percent during the input date range if complete show 1
else cast(InputWeekRange as float)/cast(ProjectTotalWeek as float) end) -- project percent during the input date range
*ProjectCost),0), 0) as FirstLoop -- total project cost

from(
	select *,isnull([PCC+SUB SUM]/ nullif((CompletePercent *ProjectCost),0), 0) as CurrentQualityCost,	
				(SELECT DATEDIFF(ww,	
				CASE 
					WHEN @StartDate = '' then ProjectStartDate
					WHEN @StartDate <= ProjectStartDate then ProjectStartDate
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0 
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now  and @StartDate <= ProjectEndDate then @StartDate
					WHEN ProjectEndDate >= @now  and @now >= @StartDate then @StartDate
				END ,	
						
				CASE 							 
					WHEN ProjectEndDate <= @now and @EndDate = '' then ProjectEndDate
					WHEN ProjectEndDate >= @now and @EndDate = '' then @now
					WHEN @StartDate >= @now or @StartDate >= ProjectEndDate then 0
					WHEN @EndDate <= ProjectStartDate then 0

					WHEN ProjectEndDate <= @now and @EndDate <= ProjectEndDate and @EndDate >= ProjectStartDate then @EndDate
					WHEN ProjectEndDate <= @now and @EndDate >= ProjectEndDate and @StartDate >= ProjectStartDate then ProjectEndDate

					WHEN ProjectEndDate >= @now and @EndDate <= @now and @EndDate >= ProjectStartDate then @EndDate							
					WHEN ProjectEndDate >= @now and @StartDate>=ProjectStartDate and @EndDate >= @now then @now
				END
						)) AS InputWeekRange,

		case 
			when @StartDate > @EndDate then 0 
			when @StartDate<=Obs_Date or @StartDate = '' then Obs_Date
			when @StartDate>=Obs_Date and @StartDate<=ObsComplianceDate then @StartDate
			when @StartDate>=ObsComplianceDate then ObsComplianceDate
			end as PccSubStart, --edge case

		case 
			when @StartDate > @EndDate then 0 
			when @EndDate>=ObsComplianceDate or @EndDate = '' then ObsComplianceDate
			when @EndDate>=Obs_Date and @EndDate<=ObsComplianceDate then @EndDate
			when @EndDate<=Obs_Date then Obs_Date
			end as PccSubEnd --edge case

		from #QTemp 
		where 
		(ProjectNoName like  '%'+IsNull(@ProjectID,ProjectNoName)+'%') 
		and 
		(Project_Company = IsNull(@Company,Project_Company) or @Company='') 
) list1									
order by ProjectNoName



select * from #test2


DECLARE @Range INT = @InputWeekRange;
with cte
    as
    (
    select 1 as value
    union all
    select value + 1 from cte where value < @Range
    )
    select * from cte
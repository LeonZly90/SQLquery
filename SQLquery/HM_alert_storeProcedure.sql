exec HMexpireDate

--BEGIN
--  WAITFOR DELAY "30:00:00"
--  EXEC HM_alert
--END

USE [HealthyMaterial]
GO
/****** Object:  StoredProcedure [dbo].[HMexpireDate]    Script Date: 8/10/2021 9:44:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[HMexpireDate]
AS

declare @now date
declare @thirtyDaysLater date
set @now = GETDATE()
set @thirtyDaysLater = dateadd(day,30,@now)

select 
CSI, ManufactureName, ProductName, MaterialDescription, 

case 
	when
		convert(date, EPD_Expiration) > (convert(date,(Select @thirtyDaysLater)))
	then 'Good'
	when --Will expire in 30 days
		convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) 
	then concat('Will expire in ', convert(varchar(10), (SELECT (DATEDIFF(day, EPD_Expiration, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Expiration, GETDATE())))), '-day')
end as EPD_Status,

case 
	when
		convert(date, EPD_Option_Expires) > (convert(date,(Select @thirtyDaysLater)))
	then 'Good'
	when --Will expire in 30 days
		convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Option_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Option_Expires, GETDATE())))), '-day')
end as EPD_Option_Status,

case 
	when
		convert(date, MT_Expiration) > (convert(date,(Select @thirtyDaysLater)))
	then 'Good'

	when --Will expire in 30 days
		convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, MT_Expiration, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, MT_Expiration, GETDATE())))), '-day')
end as MT_Expiration_Status,

case 
	when
		convert(date, Mat_Opt_Expires) > (convert(date,(Select @thirtyDaysLater)))
	then 'Good'

	when --Will expire in 30 days
		convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, Mat_Opt_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, Mat_Opt_Expires, GETDATE())))), '-day')
end as Mat_Opt_Expires_Status,

case 
	when
		convert(date, LEM_Expires) > (convert(date,(Select @thirtyDaysLater)))
	then 'Good'

	when --Will expire in 30 days
		convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, LEM_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, LEM_Expires, GETDATE())))), '-day')
end as LEM_Expires_Status

into #ExpirationTable 
from 
HMDetails 
where 
convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))

or
convert(date, EPD_Expiration) <= (select @now) or
convert(date, EPD_Option_Expires) <= (select @now) or
convert(date, MT_Expiration) <= (select @now) or
convert(date, Mat_Opt_Expires) <= (select @now) or
convert(date, LEM_Expires) <= (select @now)


select CSI, ManufactureName, ProductName, MaterialDescription,
	case 
		when
			(EPD_Status like 'Expired%') or (EPD_Option_Status like 'Expired%') or (MT_Expiration_Status like 'Expired%') 
			or (Mat_Opt_Expires_Status like 'Expired%') or (LEM_Expires_Status like 'Expired%')	
		then 'Expired'

		else 'Will expire in 30 days'
	end as Expire_Status

from #ExpirationTable order by Expire_Status desc

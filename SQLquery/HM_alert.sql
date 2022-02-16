CREATE PROCEDURE HM_alert as

declare @now date
declare @thirtyDaysLater date
set @now = GETDATE()
set @thirtyDaysLater = dateadd(day,31,@now)

--IF OBJECT_ID('dbo.HM_alert','U') IS NOT NULL 
--DROP PROCEDURE  dbo.HM_alert


--select * 
----into AlertTable 
--from 
--HMDetails 
--where 
--convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
--convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
--convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
--convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
--convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))

--or
--convert(date, EPD_Expiration) <= (select @now) or
--convert(date, EPD_Option_Expires) <= (select @now) or
--convert(date, MT_Expiration) <= (select @now) or
--convert(date, Mat_Opt_Expires) <= (select @now) or
--convert(date, LEM_Expires) <= (select @now)


select *,
case 
	when --Will expire in 30 days
		convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
		convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
		convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
		convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
		convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) 
	then 'NO, Will expire in 30 days'
	else 'YES, Expired'
end as ExpireStatus
from
--(
--select * 
--into AlertTable 
--from 
HMDetails 
--AlertTable
where 
convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) or
convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))

or --Expired
convert(date, EPD_Expiration) <= (select @now) or
convert(date, EPD_Option_Expires) <= (select @now) or
convert(date, MT_Expiration) <= (select @now) or
convert(date, Mat_Opt_Expires) <= (select @now) or
convert(date, LEM_Expires) <= (select @now)
--) 

exec HM_alert
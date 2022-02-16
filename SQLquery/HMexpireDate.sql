declare @now date
declare @thirtyDaysLater date
set @now = GETDATE()
set @thirtyDaysLater = dateadd(day,30,@now)

IF OBJECT_ID('dbo.ExpirationTable','U') IS NOT NULL 
DROP TABLE dbo.ExpirationTable


select 
CSI, ManufactureName, ProductName, MaterialDescription, 
--EPD_Expiration,EPD_Option_Expires, MT_Expiration, Mat_Opt_EXpires,LEM_expires,

--case 
--	when --Will expire in 30 days
--		convert(date, EPD_Expiration) > (convert(date,(Select @thirtyDaysLater))) and
--		convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) and
--		--convert(date, EPD_Option_Expires) > (select @now) and
--		convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) and
--		--convert(date, MT_Expiration) > (select @now) and
--		convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) and
--		--convert(date, Mat_Opt_Expires) > (select @now) and
--		convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) and
--		--convert(date, LEM_Expires) > (select @now) and
--		convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater))) 
--	then 'NO, Will expire in 30 days'
--	else 'YES, Expired'
--end as ExpireStatus,

case 
	when
		convert(date, EPD_Expiration) > (convert(date,(Select @thirtyDaysLater))) or EPD_Expiration is null
	then 'Good'
	when --Will expire in 30 days
		convert(date, EPD_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater))) 
	then concat('Will expire in ', convert(varchar(10), (SELECT (DATEDIFF(day, EPD_Expiration, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Expiration, GETDATE())))), '-day')
end as EPD_Status,

case 
	when
		convert(date, EPD_Option_Expires) > (convert(date,(Select @thirtyDaysLater))) or EPD_Option_Expires is null
	then 'Good'
	when --Will expire in 30 days
		convert(date, EPD_Option_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Option_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, EPD_Option_Expires, GETDATE())))), '-day')
end as EPD_Option_Status,

case 
	when
		convert(date, MT_Expiration) > (convert(date,(Select @thirtyDaysLater))) or MT_Expiration is null
	then 'Good'

	when --Will expire in 30 days
		convert(date, MT_Expiration) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, MT_Expiration, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, MT_Expiration, GETDATE())))), '-day')
end as MT_Expiration_Status,

case 
	when
		convert(date, Mat_Opt_Expires) > (convert(date,(Select @thirtyDaysLater))) or Mat_Opt_Expires is null
	then 'Good'

	when --Will expire in 30 days
		convert(date, Mat_Opt_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, Mat_Opt_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, Mat_Opt_Expires, GETDATE())))), '-day')
end as Mat_Opt_Expires_Status,

case 
	when
		convert(date, LEM_Expires) > (convert(date,(Select @thirtyDaysLater))) or LEM_Expires is null
	then 'Good'

	when --Will expire in 30 days
		convert(date, LEM_Expires) between (select @now) and (convert(date,(Select @thirtyDaysLater)))
	then concat('Will expire in ', convert(varchar(10), (SELECT abs(DATEDIFF(day, LEM_Expires, GETDATE())))), '-day')
	else concat('Expired ', convert(varchar(10), (SELECT abs(DATEDIFF(day, LEM_Expires, GETDATE())))), '-day')
end as LEM_Expires_Status


into ExpirationTable 
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



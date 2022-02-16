select * from HealthyMaterial.dbo.HMDetails where 
HealthyMaterial.dbo.HMDetails.EPD_Option1_Expires <= (select GETDATE()) or
HealthyMaterial.dbo.HMDetails.EPD_Option2_Expires <= (select GETDATE()) or
HealthyMaterial.dbo.HMDetails.MI_Option1_Expires <= (select GETDATE()) or
HealthyMaterial.dbo.HMDetails.MI_Option2_Expires <= (select GETDATE()) or
HealthyMaterial.dbo.HMDetails.LEM_Expires <= (select GETDATE())
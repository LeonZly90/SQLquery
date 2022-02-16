/* CREATE TABLE HealthyMaterial.dbo.test like HealthyMaterial.dbo.HMDetail_RAW 


update HealthyMaterial.dbo.HMDetails, HealthyMaterial.dbo.HMDetails_RAW 
set HealthyMaterial.dbo.HMDetails.CSI = HealthyMaterial.dbo.HMDetails_RAW.CSI 
where HealthyMaterial.dbo.HMDetails.CSI = HealthyMaterial.dbo.HMDetails_RAW.CSI

insert into HealthyMaterial.dbo.test(CSI) 
select CSI from HealthyMaterial.dbo.HMDetails_RAW */


/*Select * Into HealthyMaterial.dbo.test From HealthyMaterial.dbo.HMDetails Where 1 = 2
insert into HealthyMaterial.dbo.HMDetails(CategoryID, CertificationId) 
select CategoryID, CertificationID from HealthyMaterial.dbo.HMDetails_RAW*/

insert into HealthyMaterial.dbo.HMDetails(CategoryID, CertificationId ,[CSI]
      ,[ManufactureName]
      ,[ProductName]
      ,[EPD_Option1]
      ,[EPD_Option2]
      ,[EPD_Option1_Expires]
      ,[EPD_Option2_Expires]
      ,[MI_Type_Reporting]
      ,[CertificationProgram]
      ,[MI_Option2]
      ,[MI_Option1_Expires]
      ,[MI_Option2_Expires]
      ,[MaterialDescription]
      ,[Link]
      ,[Location]
      ,[Notes]
      ,[LEM_Expires]
      ,[EPR_Program])
select CategoryID, CertificationId ,[CSI]
      ,[ManufactureName]
      ,[ProductName]
      ,[EPD_Option1]
      ,[EPD_Option2]
      ,CAST([EPD_Option1_Expires]as datetime2(7))
      ,CAST([EPD_Option2_Expires]as datetime2(7))
      ,[MI_Type_Reporting]
      ,[CertificationProgram]
      ,[MI_Option2]
      ,CAST([MI_Option1_Expires]as datetime2(7))
      ,CAST([MI_Option2_Expires]as datetime2(7))
      ,[Material_Description]
      ,[Link]
      ,[Location]
      ,[Notes]
      ,CAST([LEM_Expires]as datetime2(7))
      ,[EPR_Program]
       from HealthyMaterial.dbo.HMDetails_RAW

delete from HealthyMaterial.dbo.HMDetails

 ALTER TABLE HMDetails ALTER COLUMN EPD_Id [int] NULL
  ALTER TABLE HMDetails ALTER COLUMN EPD_LCA_Optimization_Id [int] NULL
   ALTER TABLE HMDetails ALTER COLUMN Materials_Transparency_Id [int] NULL
    ALTER TABLE HMDetails ALTER COLUMN Threshold_Level_Id [int] NULL
	 ALTER TABLE HMDetails ALTER COLUMN Materials_Optimization_Id [int] NULL
	  ALTER TABLE HMDetails ALTER COLUMN LEED_MI_Opt2_Id [int] NULL
	   ALTER TABLE HMDetails ALTER COLUMN CategoryId [int] NULL
	    ALTER TABLE HMDetails ALTER COLUMN CertificationId [int] NULL

 ALTER TABLE HMDetails ALTER COLUMN EPD_Id [int] not NULL
  ALTER TABLE HMDetails ALTER COLUMN EPD_LCA_Optimization_Id [int] not NULL
   ALTER TABLE HMDetails ALTER COLUMN Materials_Transparency_Id [int] not NULL
    ALTER TABLE HMDetails ALTER COLUMN Threshold_Level_Id [int] not NULL
	 ALTER TABLE HMDetails ALTER COLUMN Materials_Optimization_Id [int] not NULL
	  ALTER TABLE HMDetails ALTER COLUMN LEED_MI_Opt2_Id [int] not NULL
	   ALTER TABLE HMDetails ALTER COLUMN CategoryId [int] not NULL
	    ALTER TABLE HMDetails ALTER COLUMN CertificationId [int] not NULL

update HMDetails
	set HMDetails.EPD_Id = 4
	where HMDetails.EPD_Id is null

update HMDetails
	set HMDetails.EPD_LCA_Optimization_Id = 5
	where HMDetails.EPD_LCA_Optimization_Id is null

update HMDetails
	set HMDetails.Materials_Transparency_Id = 17
	where HMDetails.Materials_Transparency_Id is null

update HMDetails
	set HMDetails.Threshold_Level_Id = 3
	where HMDetails.Threshold_Level_Id is null

update HMDetails
	set HMDetails.Materials_Optimization_Id = 13
	where HMDetails.Materials_Optimization_Id is null

update HMDetails
	set HMDetails.LEED_MI_Opt2_Id = 4
	where HMDetails.LEED_MI_Opt2_Id is null

update HMDetails
	set HMDetails.CategoryId = 9
	where HMDetails.CategoryId is null

update HMDetails
	set HMDetails.CertificationId = 26
	where HMDetails.CertificationId is null


	ALTER TABLE HMDetails
	DROP COLUMN [Location];
	ALTER TABLE HMDetails
	DROP COLUMN Notes;

Insert into HealthyMaterial.dbo.HMDetails
([CSI]
      ,[ManufactureName]
      ,[ProductName]
      ,[MaterialDescription]
      ,[VerifiedForLEED]
      ,[EPD_Id]--1
      ,[EPD_Expiration]
      ,[EPD_Link]
      ,[EPD_LCA_Optimization_Id]--2
      ,[EPD_Option_Expires]
      ,[EPD_Op_Link]
      ,[Materials_Transparency_Id]--3
      ,[Threshold_Level_Id]--4
      ,[MT_Link]
      ,[MT_Expiration]
      ,[Materials_Optimization_Id]--5
      ,[LEED_MI_Opt2_Id]--6
      ,[Mat_Opt_Link]
      ,[Mat_Opt_Expires]
      --,[MI_Opt_Link]------------miss?
      ,[CategoryId]--7
	  ,[CertificationId]--8
      ,[LEM_Expires]
      ,[LEM_Link2]
      ,[VOC_Content]
      ,[VOC_Link]
      ,[EprProgram]
      ,[PreConsumerContent]
      ,[PostConsumerContent]
      ,[RecycledContentLink] --end
      --,[CreatedBy]--
      --,[CreatedOn]--
      --,[Location]--
      --,[Notes]--
	  ) 
select 

[CSI]
      ,[Manuf_Name]
      ,[Product_Name]
      ,[Material_Description]
      ,[Verified_for_LEED]
      ,[EPD]--1
      ,[EPD_Expiration]
      ,[EPD_Link]
      ,[EPD_LCA_Optimization]--2
      ,[EPD_Opt_Expires]
      ,[EPD_Op_Link]
      ,[Materials_Transparency]--3
      ,[Threshold_Level]--4
      ,[MT_Link]
      ,[MT_Expiration]
      ,[Materials_Optimization]--5
      ,[LEED_MI_Opt_2]--6
      ,[Mat_Opt_Link]
      ,[Mat_Opt_Expires]
      ,[Product_Category]--7
      ,[Certification]--8
      ,[LEM_Expires]
      ,[LEM_Link]
      ,[VOC_Content]
      ,[VOC_Link]
      ,[EPR_Program]
      ,[Pre_Consumer_Content]
      ,[Post_Consumer_Content]
      ,[Recycled_Content_Link]

from HPHealthyMaterial.dbo.backup_081021






	update b --1 EPD
	set b.EPD = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join EPD a 
	on b.EPD = a.EPD_Name

	update b --2 EPD_LCA_Optimization
	set b.EPD_LCA_Optimization = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join EPD_LCA_Optimization a 
	on b.EPD_LCA_Optimization = a.EPD_LCA_Name

	update b --3 Materials_Transparency
	set b.Materials_Transparency = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join Materials_Transparency a 
	on b.Materials_Transparency = a.Materials_Transparency_Name

	update b --4 Threshold_Level
	set b.Threshold_Level = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join Threshold_Level a 
	on b.Threshold_Level = a.Threshold_Level_Name

	update b --5 Materials_Optimization
	set b.Materials_Optimization = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join Materials_Optimization a 
	on b.Materials_Optimization = a.Materials_Optimization_Name

	update b --6 LEED_MI_Opt_2
	set b.LEED_MI_Opt_2 = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join LEED_MI_Opt2 a 
	on b.LEED_MI_Opt_2 = a.LEED_MI_Opt2_Name

	update b --7 Product_Category
	set b.Product_Category = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join Categories a 
	on b.Product_Category = a.CategoryName

	update b --8 [Certification]
	set b.Certification = a.Id
	from
	HPHealthyMaterial.dbo.backup_081021 b left join Certifications a 
	on b.Certification = a.CertificationName


--delete from HealthyMaterial.dbo.HMDetails_RAW   
--insert into HPHealthyMaterial.dbo.backup_081021 select * from HPHealthyMaterial.dbo.Jim_import_dates




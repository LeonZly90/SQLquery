
ALTER TABLE HMDetails DROP CONSTRAINT FK_HMDetail_Category

--1
create table Categories (
Id int identity(1,1) primary key,
CategoryName nvarchar(255),
CreatedBy nvarchar(255),
CreatedOn datetime2(7)
)

--2
insert into Categories
values ('Paints & Coatings', null, null)
insert into Categories
values ('Adhesives & Sealants', null, null)
insert into Categories
values ('Flooring', null, null)
insert into Categories
values ('Wall Panels', null, null)
insert into Categories
values ('Ceilings ', null, null)
insert into Categories
values ('Insulation', null, null)
insert into Categories
values ('Composite Wood', null, null)
insert into Categories
values ('Furniture', null, null)
insert into Materials_Optimization
values ('N/A')




--3 drop the old column
alter table HMDetails
drop column EPD_Id

--4 add new foreign key column (int 
alter table HMDetails
add EPD_Id int

update HMDetails
set Materials_Optimization_Id  =13

--5 nut NULL
alter table HMdetails
alter column Materials_Optimization_Id int not null


--6 make FK
Alter table HMDetails
add constraint FK_HMDetail_Category
foreign key (CategoryId) references Categories(Id)




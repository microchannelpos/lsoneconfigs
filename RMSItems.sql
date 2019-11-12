USE [master]
GO

/****** Object:  LinkedServer [localhost\ls1]    Script Date: 3/11/2019 7:17:32 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'localhost\ls1', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'localhost\ls1',@useself=N'False',@locallogin=NULL,@rmtuser=N'sa',@rmtpassword='$(pass)'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'localhost\ls1', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

USE [$(dbname)]

DELETE FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT
WHERE DEPARTMENTID like 'RMS%'

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT(DEPARTMENTID,NAME,NAMEALIAS,DIVISIONID,DIVISIONMASTERID,MASTERID,DELETED,CREATED,MODIFIED)
SELECT 'RMS000'+RIGHT((SELECT MAX(DEPARTMENTID) FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT)+ROW_NUMBER() OVER(ORDER BY D.name ASC),7),
D.NAME,'','',NULL,NEWID(),0,GETDATE(),GETDATE()
FROM DEPARTMENT D
WHERE D.NAME NOT IN (SELECT NAME FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT)
END
GO

DELETE FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILGROUP
WHERE GROUPID like 'S%' OR GROUPID like 'RMS%'

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.RETAILGROUP(MASTERID,GROUPID,NAME,DEPARTMENTID,SALESTAXITEMGROUP,DEFAULTPROFIT,POSPERIODICID,DIVISIONMASTERID,DELETED,DEPARTMENTMASTERID,CREATED,MODIFIED,TAREWEIGHT)
SELECT NEWID(),
'RMS'+RIGHT( (SELECT MAX(GROUPID) FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILGROUP)+CAST(ROW_NUMBER() OVER(ORDER BY C.name ASC) AS NVARCHAR(2)),7),
C.NAME,
(SELECT TOP 1 DEPARTMENTID FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT WHERE NAME = D.NAME),
'',0,'',NULL,0,
(SELECT TOP 1 MASTERID FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT WHERE NAME = D.NAME),
GETDATE(),
GETDATE(),
C.ID
FROM Category C
INNER JOIN Department D on D.ID = C.DepartmentID
WHERE C.ID IN (SELECT CATEGORYID FROM Item where ItemLookupCode not in (select itembarcode from [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE) ) 
END
GO

DELETE FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM
WHERE ITEMID like 'S%' or ITEMID like 'RMS%'

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM(MASTERID,ITEMID,HEADERITEMID,ITEMNAME,VARIANTNAME,ITEMTYPE,DEFAULTVENDORID,NAMEALIAS,EXTENDEDDESCRIPTION,RETAILGROUPMASTERID,
ZEROPRICEVALID,QTYBECOMESNEGATIVE,NODISCOUNTALLOWED,KEYINPRICE,SCALEITEM,KEYINQTY,BLOCKEDONPOS,BARCODESETUPID,PRINTVARIANTSSHELFLABELS,FUELITEM,GRADEID,MUSTKEYINCOMMENT,DATETOBEBLOCKED,
DATETOACTIVATEITEM,PROFITMARGIN,VALIDATIONPERIODID,MUSTSELECTUOM,INVENTORYUNITID,PURCHASEUNITID,SALESUNITID,PURCHASEPRICE,SALESPRICE,SALESPRICEINCLTAX,SALESMARKUP,SALESLINEDISC,SALESALLOWTOTALDISCOUNT,
SALESTAXITEMGROUPID,DELETED,RETURNABLE,KEYINSERIALNUMBER,DATECREATED,CREATED,TAREWEIGHT)
--select * from retailitem
SELECT NEWID(),'RMS0'+RIGHT((SELECT MAX(ITEMID) FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM)+CAST(ROW_NUMBER() OVER(ORDER BY itemlookupcode ASC) AS NVARCHAR(10)),6),
NULL,Description,'',0,SUPPLIERID,ITEMLOOKUPCODE,ExtendedDescription,
CASE WHEN Categoryid = '0' THEN NULL ELSE CAST((SELECT TOP 1 MASTERID FROM [localhost\ls1].[LSONE_CTC].dbo.RETAILGROUP WHERE TAREWEIGHT = CATEGORYID) AS NVARCHAR(50)) END,
0,0,0,0,0,0,0,'',0,0,'',0,'1900-01-01 00:00:00.000','1900-01-01 00:00:00.000',
0,'',0,'U00001','U00001','U00001',COST,COST*1.1,PRICE,0,'',1,'001',0,1,0,GETDATE(),GETDATE(),0
FROM Item 
where inactive = 0  AND ItemLookupCode not in (select itembarcode from [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE) 
END
GO

DELETE FROM [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE
WHERE ITEMID like 'S%' or ITEMID like 'RMS%'

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE
SELECT ITEMLOOKUPCODE,ITEMID,'','00000001',0,0,'',0,'','',1,0,'1900-01-01 00:00:00.000',0,'?','LSR',ItemLookupCode,0
FROM Item i
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM RI ON RI.NAMEALIAS = i.ItemLookupCode
where i.inactive = 0  AND i.ItemLookupCode not in (select itembarcode from [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE) 
END
GO

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE
SELECT a.Alias,ri.ITEMID,'','00000001',0,0,'',0,'','',1,0,'1900-01-01 00:00:00.000',0,'?','LSR',a.Alias,0
FROM Item i
INNER JOIN Alias a on i.ID = a.ItemID
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM RI ON RI.NAMEALIAS = i.ItemLookupCode
where i.inactive = 0  AND a.alias not in (select itembarcode from [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE) and ri.namealias <> ''
END
GO

DELETE FROM [localhost\ls1].[LSONE_CTC].dbo.VENDORITEMS
WHERE RETAILITEMID like 'S%' or RETAILITEMID like 'RMS%'

BEGIN
INSERT INTO [localhost\ls1].[LSONE_CTC].dbo.VENDORITEMS
SELECT 'S000'+RIGHT((SELECT MAX(INTERNALID) FROM [localhost\ls1].[LSONE_CTC].dbo.VENDORITEMS)+ROW_NUMBER() OVER(ORDER BY itemlookupcode ASC),6),'00002820'+ROW_NUMBER() OVER(ORDER BY itemlookupcode ASC),
ITEMID,'U00001',(SELECT ACCOUNTNUM FROM [localhost\ls1].[LSONE_CTC].dbo.VENDTABLE WHERE NAME = S.SUPPLIERNAME),'LSR',I.COST,'1900-01-01 00:00:00.000',I.COST
FROM Supplier S
INNER JOIN Item I on I.SupplierID = S.ID
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM RI on i.ItemLookupCode = Ri.NAMEALIAS
WHERE i.inactive = 0 and i.CATEGORYID <> 0 and i.Departmentid NOT IN (14,15,16,17) and RI.ITEMID NOT IN (SELECT ITEMID FROM [localhost\ls1].[LSONE_CTC].dbo.VENDORITEMS)
END
GO

BEGIN
UPDATE [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM SET SALESPRICEINCLTAX = i.price
FROM Item i
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.INVENTITEMBARCODE iib on i.itemlookupcode = iib.ITEMBARCODE
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILITEM ri on iib.ITEMID = ri.ITEMID
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILGROUP rg on ri.RETAILGROUPMASTERID = rg.MASTERID
INNER JOIN [localhost\ls1].[LSONE_CTC].dbo.RETAILDEPARTMENT rd on rg.DEPARTMENTMASTERID = rd. MASTERID
WHERE rd.NAME = 'Tobacco Accessories' and i.price > 0
END
GO

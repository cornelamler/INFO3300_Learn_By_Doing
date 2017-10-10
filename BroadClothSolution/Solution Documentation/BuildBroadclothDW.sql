--Created by Raleigh, Sydney, Aleksandra, and Cornel
--Version 1
--Build Broadcloth Production Batch Data Mart
--Created October 5th, 2017

use master
--Creating the Data Warehouse
IF NOT EXISTS(SELECT * FROM sys.databases  --only adds if it doesn't exist
	WHERE name = N'BroadclothDW')
	CREATE DATABASE BroadclothDW
GO
USE BroadclothDW
GO

--Checking for Existing Tables
IF EXISTS( --removes a table if it exists
	SELECT *
	FROM sys.tables
	WHERE name = N'FactBatch'
	)
	DROP TABLE FactBatch;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimDate'
	)
	DROP TABLE DimDate;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimShipment'
	)
	DROP TABLE DimShipment;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimCompliance'
	)
	DROP TABLE DimCompliance;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimOrder'
	)
	DROP TABLE DimOrder;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimItem'
	)
	DROP TABLE DimItem;

	
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'DimFactory'
	)
	DROP TABLE DimFactory;
	
CREATE TABLE DimShipment
	(Shipment_SK INT IDENTITY(1,1) CONSTRAINT pk_Shipment_SK PRIMARY KEY,
	Shipment_AK INT,
	Nation NVARCHAR (50),
	[State] NVARCHAR(20),
	City NVARCHAR(30),
	ShippingCurrency NVARCHAR(5)
	);

CREATE TABLE DimCompliance
	(Compliance_SK INT IDENTITY(1, 1) CONSTRAINT pk_Compliance_SK PRIMARY KEY,
	Compliance_AK INT,
	ConditionCategory NVARCHAR(50),
	OverallComplianceRating DECIMAL(18, 0),
	Age DECIMAL(18, 0),
	AgeDocuments NVARCHAR(20),
	Gender NVARCHAR(7)
	);

CREATE TABLE DimFactory
	(Factory_SK INT IDENTITY(1, 1) CONSTRAINT pk_Factory_SK PRIMARY KEY,
	Factory_AK INT,
	Nation NVARCHAR(50),
	[STATE] NVARCHAR(50),
	City NVARCHAR(30),
	GMTDifference DECIMAL(18, 0),
	MaxWorkers INT,
	BaseCurrency NVARCHAR(5)
	);

CREATE TABLE DimItem
	(Item_SK INT IDENTITY(1, 1) CONSTRAINT pk_Item_SK PRIMARY KEY,
	Item_AK NVARCHAR(60) NOT NULL,
	ModelDescription NVARCHAR(250) NOT NULL,
	BasePrice DECIMAL(9, 4),
	ListPrice DECIMAL(38,4),
	Color NVARCHAR(20),
	ItemSize DECIMAL(18, 0)
	);

CREATE TABLE DimOrder
	(Order_SK INT IDENTITY(1, 1) CONSTRAINT pk_Order_SK PRIMARY KEY,
	Order_AK INT,
	DeliveryNation NVARCHAR(50),
	DeliveryState NVARCHAR(20),
	DeliveryCity NVARCHAR(30),
	PriceAdjustment DECIMAL(38, 4),
	Currency NVARCHAR(5)
	);
	
CREATE TABLE DimDate
	(	
		Date_SK INT PRIMARY KEY, 
		Date DATETIME,
		FullDate CHAR(10),-- Date in MM-dd-yyyy format
		DayOfMonth INT, -- Field will hold day number of Month
		DayName VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		DayOfWeek INT,-- First Day Sunday=1 and Saturday=7
		DayOfWeekInMonth INT, -- 1st Monday or 2nd Monday in Month
		DayOfWeekInYear INT,
		DayOfQuarter INT,
		DayOfYear INT,
		WeekOfMonth INT,-- Week Number of Month 
		WeekOfQuarter INT, -- Week Number of the Quarter
		WeekOfYear INT,-- Week Number of the Year
		Month INT, -- Number of the Month 1 to 12{}
		MonthName VARCHAR(9),-- January, February etc
		MonthOfQuarter INT,-- Month Number belongs to Quarter
		Quarter CHAR(2),
		QuarterName VARCHAR(9),-- First,Second..
		Year INT,-- Year value of Date stored in Row
		YearName CHAR(7), -- CY 2015,CY 2016
		MonthYear CHAR(10), -- Jan-2016,Feb-2016
		MMYYYY INT,
		FirstDayOfMonth DATE,
		LastDayOfMonth DATE,
		FirstDayOfQuarter DATE,
		LastDayOfQuarter DATE,
		FirstDayOfYear DATE,
		LastDayOfYear DATE,
		IsHoliday BIT,-- Flag 1=National Holiday, 0-No National Holiday
		IsWeekday BIT,-- 0=Week End ,1=Week Day
		Holiday VARCHAR(50),--Name of Holiday in US
		Season VARCHAR(10)--Name of Season
	);


	CREATE TABLE FactBatch
(QuantityProduced INT,
QualityRating INT,
StartDate INT,
EstimatedEndTime INT,
ActualEndTime INT,
ShippingDate INT,
ProoductionCost INT,
ShippingCost INT,
QuantityShipped INT,
OrderQuantity INT,
OrderSalePrice INT,
Order_SK INT NOT NULL CONSTRAINT Fk_Order_SK FOREIGN KEY REFERENCES DimOrder(Order_SK),
Compliance_SK INT NOT NULL CONSTRAINT FK_Compliance_SK FOREIGN KEY REFERENCES DimCompliance(Compliance_SK),
Factory_SK INT CONSTRAINT FK_Factory_SK FOREIGN KEY REFERENCES DimFactory(Factory_SK),
Item_SK INT CONSTRAINT FK_Item_SK FOREIGN KEY REFERENCES DimItem(Item_SK),
Shipment_SK INT CONSTRAINT FK_Shipment_SK FOREIGN KEY REFERENCES DimShipment(Shipment_SK),
Date_SK INT CONSTRAINT FK_Date_SK FOREIGN KEY REFERENCES DimDate(Date_SK),
CONSTRAINT pk_FactBatch PRIMARY KEY (Order_SK, Compliance_SK, Factory_SK, Item_SK, Shipment_SK, Date_SK)
);
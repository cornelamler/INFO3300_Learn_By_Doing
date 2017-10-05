-- BioGeneTechnologyLabs database developed and written by Cornel Amler
-- ****
-- Replace <data_path> with the full path to this file 
-- Ensure it ends with a backslash. 
-- E.g., C:\MyDatabases\ See line 17
-- ****

-- make the database if it doesn't exist yet (BTL is short for Biogene Technology Labs, which would be inefficient to type out each time a reference to db is made)
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE name = N'')
	CREATE DATABASE 
GO
USE BTL_DB


--change the path below to where the files are located on your machine
DECLARE
	@data_path NVARCHAR(256);
SELECT @data_path = 'C:\Users\Cornel Amler\OneDrive\DU Q 3\INFO 3240\Phase 1\Phase 1 Final\';

-- delete existing tables (in effect, wipe the slate)(leaves down, wipe references to primary keys before wiping those keys)

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Spend'
       )
	DROP TABLE Spend;

	
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Study'
       )
	DROP TABLE Study;


IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'SpendType'
       )
	DROP TABLE SpendType;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Scientist'
       )
	DROP TABLE Scientist;

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Department'
       )
	DROP TABLE Department;

	

	

	
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Molecule'
       )
	DROP TABLE Molecule;
	
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'CancerType'
       )
	DROP TABLE CancerType;

	
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'PhaseCost'
       )
	DROP TABLE PhaseCost;

	
-- Now that the database is clean, create the tables(roots up, primary keys need to exist for foreign keys to reference them)

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
	
--fill(load) the tables (same order as creation)


--Table 1 Phasecost

EXECUTE (N'BULK INSERT PhaseCost FROM ''' + @data_path + N'PhaseCost.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

--table 2 Cancer type

EXECUTE (N'BULK INSERT CancerType FROM ''' + @data_path + N'CancerType.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

--table 3 molecule
EXECUTE (N'BULK INSERT Molecule FROM ''' + @data_path + N'Molecule.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

--table 4 department

EXECUTE (N'BULK INSERT Department FROM ''' + @data_path + N'Department.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

-- table 5 scientist
EXECUTE (N'BULK INSERT Scientist FROM ''' + @data_path + N'Scientist.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

-- table 6 Spendtype
EXECUTE (N'BULK INSERT SpendType FROM ''' + @data_path + N'SpendType.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

--table 7 study NOTE: tab-delimited
EXECUTE (N'BULK INSERT Study FROM ''' + @data_path + N'Study.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');

--Table 8 Spend
EXECUTE (N'BULK INSERT Spend FROM ''' + @data_path + N'Spend.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK
	);
');


--Confirm Creation via Output


GO
SET NOCOUNT ON
SELECT 'PhaseCost' "Table",     COUNT(*) "Rows"	FROM PhaseCost	UNION
SELECT 'CancerType',		    COUNT(*)		FROM CancerType	UNION
SELECT 'Spend',                 COUNT(*)		FROM Spend		UNION
SELECT 'SpendType',             COUNT(*)		FROM SpendType	UNION
SELECT 'Study',		    COUNT(*)		FROM Study           UNION
SELECT 'Molecule',              COUNT(*)		FROM Molecule        UNION
SELECT 'Department',            COUNT(*)		FROM Department      UNION
SELECT 'Scientist',             COUNT(*)		FROM Scientist       
ORDER BY 1;
SET NOCOUNT OFF
GO
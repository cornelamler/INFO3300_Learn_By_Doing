-- BioGeneTechnologyLabs database developed and written by Cornel Amler
-- ****
-- Replace <data_path> with the full path to this file 
-- Ensure it ends with a backslash. 
-- E.g., C:\MyDatabases\ See line 17
-- ****

-- make the database if it doesn't exist yet (BTL is short for Biogene Technology Labs, which would be inefficient to type out each time a reference to db is made)
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE name = N'BTL_DB')
	CREATE DATABASE BTL_DB
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

CREATE TABLE PhaseCost
	(PhaseCostID INT IDENTITY(1,1) CONSTRAINT pk_phasecost PRIMARY KEY,
	PhaseBudget MONEY NOT NULL
	);

CREATE TABLE CancerType
	(CancerTypeID INT IDENTITY(1, 1) CONSTRAINT pk_cancertype PRIMARY KEY,
	CancerName NVARCHAR(25) NOT NULL
	);

CREATE TABLE Molecule
	(MoleculeID INT IDENTITY(1, 1) CONSTRAINT pk_molecule PRIMARY KEY,
	MoleculeName NVARCHAR(25) NOT NULL,
	MoleculeDrugName NVARCHAR(25) 
	);

CREATE TABLE Department
	(DepartmentID INT IDENTITY(1, 1) CONSTRAINT pk_department PRIMARY KEY,
	DepartmentName NVARCHAR(60) NOT NULL,
	DepartmentLeader NVARCHAR(50) NOT NULL
	);

CREATE TABLE SCIENTIST
	(ScientistID INT IDENTITY(1, 1) CONSTRAINT pk_scientist PRIMARY KEY,
	DepartmentID INT CONSTRAINT fk_department FOREIGN KEY REFERENCES Department(DepartmentID),
	ScientistLastName NVARCHAR(20) NOT NULL,
	ScientistFirstName NVARCHAR(20) NOT NULL,
	ScientistDOB DATETIME NOT NULL,
	ScientistHireDate DATETIME NOT NULL,
	ScientistTitle NVARCHAR(40) NOT NULL
	
	);

CREATE TABLE SpendType
	(SpendTypeID INT IDENTITY(0, 1) CONSTRAINT pk_spendtype PRIMARY KEY,
	SpendType NVARCHAR(70)
	)

CREATE TABLE Study
	(StudyID INT IDENTITY(1, 1) CONSTRAINT pk_study PRIMARY KEY,
	ScientistID INT CONSTRAINT fk_scientist FOREIGN KEY REFERENCES Scientist(ScientistID),
	MoleculeID INT CONSTRAINT fk_molecule FOREIGN KEY REFERENCES Molecule(MoleculeID),
	StudyName NVARCHAR(50) NOT NULL,
	StudyDescription NVARCHAR(256) NOT NULL,
	StudyPhase INT CONSTRAINT fk_phasecost FOREIGN KEY REFERENCES PhaseCost(PhaseCostID),
	StudyStartDate DATETIME NOT NULL,
	StudyEndGoal NVARCHAR(256) NOT NULL,
	CancerTypeID INT CONSTRAINT fk_cancertype FOREIGN KEY REFERENCES CancerType(CancertypeID)
	);

CREATE TABLE Spend
	(SpendID INT IDENTITY(1, 1) CONSTRAINT pk_spend PRIMARY KEY,
	StudyID INT CONSTRAINT fk_study FOREIGN KEY REFERENCES Study(StudyID),
	SpendMonth DATETIME NOT NULL,
	SpendAmount MONEY NOT NULL,
	SpendTypeID INT CONSTRAINT fk_spendtype FOREIGN KEY REFERENCES SpendType(SpendTypeID)
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
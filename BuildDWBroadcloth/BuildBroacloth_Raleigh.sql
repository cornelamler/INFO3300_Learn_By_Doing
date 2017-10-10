--Created by Raleigh, Sydney, Aleksandra, and Cornel
--Version 1
--Build Broadcloth Production Batch Data Mart
--Created October 5th, 2017

--Creating the Data Warehouse
IF NOT EXISTS(SELECT * FROM sys.databases  --only adds if it doesn't exist
	WHERE name = N'DWBroadcloth')
	CREATE DATABASE DWBroadcloth
GO
USE DWBroadcloth
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

--BroadclothDW ETL Scripts to load all tables
--Created by Raleigh, Sydney, Cornel, and Aleksandra

--DimShipment
SELECT 
	ShipmentAK = CAST(ShipmentID AS INT),
	Nation = CAST(ShipNation AS NVARCHAR(50)),
	State = CAST(ShipState AS NVARCHAR(20)),
	City = CAST(ShipCity AS NVARCHAR(30)),
	ShippingCurrency = CAST(ShipCurrency AS NVARCHAR(5))
FROM Broadcloth.dbo.Shipment;

--DimCompliance
SELECT
	ComplianceAK = Compliance.ComplianceID,
	--WorkingConditions.ConditionCategory,
	OverallComplianceRating = CAST(AVG(Compliance.OverallRating) AS DECIMAL(18,0)),
	AverageAge = CAST(AVG(WorkerCheck.Age) AS DECIMAL(18,0)),
	--WorkerCheck.AgeDocuments,
	PercentFemale = CAST((CAST(SUM(CASE WHEN WorkerCheck.Gender LIKE 'FEMALE' THEN 1 ELSE 0 END) AS DECIMAL) / CAST(COUNT(WorkerCheck.Gender) AS DECIMAL)) AS DECIMAL(9,6))
FROM Broadcloth.dbo.Compliance
INNER JOIN Broadcloth.dbo.WorkerCheck
	ON Compliance.ComplianceID = WorkerCheck.ComplianceID
INNER JOIN Broadcloth.dbo.WorkingConditions
	ON WorkerCheck.ComplianceID = WorkingConditions.ComplianceID
GROUP BY Compliance.ComplianceID;

--DimFactory
SELECT
	Factory_AK = CAST (FactoryID AS INT),
	Nation = CAST (Nation AS NVARCHAR(50)),
	[State] = CAST ([State] AS NVARCHAR (50)),
	City = CAST (City AS NVARCHAR (30)),
	GMTDifference = CAST (GMTDifference AS DECIMAL(18,0)),
	MaxWorkers = CAST (MaxWorkers AS INT),
	BaseCurrency = CAST (BaseCurrency AS NVARCHAR(5))
FROM Broadcloth.dbo.Factory;

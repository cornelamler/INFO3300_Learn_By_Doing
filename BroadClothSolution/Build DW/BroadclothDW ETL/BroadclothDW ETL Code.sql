--BroadclothDW ETL Scripts to load all tables
--Created by Raleigh, Sydney, Cornel, and Aleksandra

--DimShipment
SELECT 
	Shipment_AK = CAST(ShipmentID AS INT),
	Nation = CAST(ShipNation AS NVARCHAR(50)),
	State = CAST(ShipState AS NVARCHAR(20)),
	City = CAST(ShipCity AS NVARCHAR(30)),
	ShippingCurrency = CAST(ShipCurrency AS NVARCHAR(5))
FROM Broadcloth.dbo.Shipment;

--DimCompliance
SELECT
	Compliance_AK = Compliance.ComplianceID,
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
	City = CAST (City AS NVARCHAR (30)),
	GMTDifference = CAST (GMTDifference AS DECIMAL(18,0)),
	MaxWorkers = CAST (MaxWorkers AS INT),
	BaseCurrency = CAST (BaseCurrency AS NVARCHAR(5))
FROM Broadcloth.dbo.Factory;

--DimItem
SELECT
	Item_AK = CAST(Item.ItemID AS NVARCHAR(60)),
	ModelDescription = CAST(Model.ModelID AS NVARCHAR(250)),
	BasePrice = CAST( BasePrice AS DECIMAL (9,4)),
	ListPrice = CAST(ListPrice AS NUMERIC(38,4)),
	Color = CAST( Color AS NVARCHAR (20)),
	ItemSize = CAST( ItemSize AS NUMERIC(18,0))
FROM Broadcloth.dbo.Item
INNER JOIN Broadcloth.dbo.Model
ON Model.ModelID = Item.ModelID;

--DimOrder
SELECT
	Order_AK = CAST(CustomerOrder.OrderID as INT),
	DeliveryNation = CAST(DeliveryNation as NVARCHAR(50)),
	DeliveryState = CAST(DeliveryState as NVARCHAR(20)),
	DeliveryCity = CAST(DeliveryCity as NVARCHAR(30)),
	PriceAdjustment = CAST(PriceAdjustment as Decimal(38, 4)),
	Currency = CAST(OrderCurrency as NVARCHAR(5))
FROM Broadcloth.dbo.CustomerOrder;

--FactBatch
SELECT
	--keys
	Order_SK = DimOrder.Order_SK,
	Compliance_SK = DimCompliance.Compliance_SK,
	Factory_SK = DimFactory.Factory_SK,
	Item_SK = DimItem.Item_SK,
	Shipment_SK = DimShipment.Shipment_SK,
	StartDate = DimDate.Date_SK,
	EstimatedEndTime= EETDW.Date_SK,
	ActualEndTime = AETDW.Date_SK,
	ShippingDate = SDDW.Date_SK,

	--measures
	QuantityProduced = Productionbatch.quantityproduced,
	QualityRating = Productionbatch.qualityrating,
	ProductionCost = CAST(ProductionBatch.ProductionCost AS DECIMAL(38,4)),
	ShippingCost = Shipment.ShipCost,
	QuantityShipped = ShipmentItem.QuantityShipped,
	OrderQuantity = SUM(OrderItem.OrderQuantity),
	OrderSalePrice = AVG(OrderItem.SalePrice)
	
FROM Broadcloth.dbo.ProductionBatch
INNER JOIN Broadcloth.dbo.OrderItem
	ON OrderItem.OrderID = ProductionBatch.OrderID

--Order Joins
INNER JOIN CustomerOrder
	ON CustomerOrder.OrderID = ProductionBatch.OrderID
JOIN BroadclothDW.dbo.DimOrder
	ON  CustomerOrder.OrderID = DimOrder.Order_AK

--Factory Joins
JOIN Broadcloth.dbo.Factory
	ON Factory.FactoryID = ProductionBatch.FactoryID
JOIN BroadclothDW.dbo.DimFactory
	ON Factory.FactoryID = DimFactory.Factory_AK

--Compliance Joins
LEFT OUTER JOIN Broadcloth.dbo.compliance
	ON Compliance.FactoryID = Factory.FactoryID
LEFT OUTER JOIN broadclothdw.dbo.DimCompliance
	ON Compliance.ComplianceID = DimCompliance.Compliance_AK

--Item Joins
JOIN Broadcloth.dbo.Item 
	ON Item.ItemID = ProductionBatch.ItemID
JOIN Broadclothdw.dbo.DimItem
	ON ProductionBatch.ItemID = DimItem.Item_AK

--Shipment Join
INNER JOIN ShipmentItem
	ON Item.ItemID = ShipmentItem.ItemID
INNER JOIN Shipment
	ON Shipment.ShipmentID = ShipmentItem.ShipmentID
JOIN BroadclothDW.dbo.DimShipment
	ON Shipment.ShipmentID = DimShipment.Shipment_AK

--Date Join
JOIN BroadclothDW.dbo.DimDate AS DimDate
	ON CAST(ProductionBatch.StartDateTime as DATE) = Dimdate.Date
JOIN BroadclothDW.dbo.DimDate AS EETDW
	ON CAST(ProductionBatch.EstEndTime as DATE) = EETDW.Date
JOIN BroadclothDW.dbo.DimDate AS AETDW
	ON CAST(productionbatch.ActualEndTime as DATE) =  AETDW.Date
JOIN BroadclothDW.dbo.Dimdate AS SDDW
	ON CAST(Shipment.ShipDate AS DATE) = SDDW.Date
	
GROUP BY 
	DimOrder.Order_SK,
	DimCompliance.Compliance_SK,
	DimFactory.Factory_SK,
	DimItem.Item_SK,
	DimShipment.Shipment_SK,
	DimDate.Date_SK,
	EETDW.Date_SK,
	AETDW.Date_SK,
	SDDW.Date_SK,
	Productionbatch.quantityproduced,
	Productionbatch.qualityrating,
	CAST(ProductionBatch.ProductionCost AS DECIMAL(38,4)),
	Shipment.ShipCost,
	Shipmentitem.QuantityShipped
ORDER BY Shipment_SK;
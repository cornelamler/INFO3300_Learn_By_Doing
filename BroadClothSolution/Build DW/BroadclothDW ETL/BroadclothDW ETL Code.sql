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
	City = CAST (City AS NVARCHAR (30)),
	GMTDifference = CAST (GMTDifference AS DECIMAL(18,0)),
	MaxWorkers = CAST (MaxWorkers AS INT),
	BaseCurrency = CAST (BaseCurrency AS NVARCHAR(5))
FROM Broadcloth.dbo.Factory;

--DimItem
SELECT
	Item_AK = CAST(ItemID AS NVARCHAR(60)),
	ModelDescription = CAST(ModelID AS NVARCHAR(250)),
	BasePrice = CAST( BasePrice AS DECIMAL (9,4)),
	ListPrice = CAST(ListPrice AS NUMERIC(338,4)),
	Color = CAST( Color AS NVARCHAR (20)),
	ItemSize = CAST( ItemSize AS NUMERIC(18,0))
FROM Broadcloth.dbo.Item
INNER JOIN Broadcloth.dbo.Model
ON Item.ItemID = Model.ItemID;

--DimOrder
SELECT
	OrderAK = CAST(Order.OrderID as INT),
	DeliveryNation = CAST(DeliveryNation as NVARCHAR(50)),
	DeliveryState = CAST(DeliveryState as NVARCHAR(50)),
	DeliveryCity = CAST(DeliveryCity as NVARCHAR(50)),
	PriceAdjustment = CAST(PriceAdjustment as Decimal(38, 4),
	Currency = CAST(OrderCurrency as NVARCHAR(5))
FROM Broadcloth.dbo.CustomerOrder;

--FactBatch
SELECT
	Order_SK = DimOrder.Order_SK,
	Compliance_SK = DimCompliance.Compliance_SK,
	Factory_SK = DimFactory.Factory_SK,
	Item_SK = DimItem.Item_SK,
	Shipment_SK = DimShipment.Shipment_SK,
	StartDate = DimDate.Date_SK,
	EstimatedEndTime= EETDW.date_SK,
	ActualEndTime = AETDW.date_SK,
	ShippingDate = SDDW.date_SK,
	QuantityProduced = Productionbatch.quantityproduced,
	QualityRating = Productionbatch.qualityrating,
	ProductionCost = broadcloth.dbo.productionbatch.productioncost,
	ShippingCost = shipment.shipcost,
	QuantityShipped = Shipmentitem.quantityshipped ,
	OrderQuantity = Orderitem.orderquantity,
	OrderSalePrice = orderitem.saleprice
	
FROM Broadcloth.dbo.productionbatch
JOIN Broadcloth.dbo.orderitem
	ON orderitem.orderID = productionbatch.orderID
JOIN Broadcloth.dbo.CustomerOrder
	ON customerorder.orderID = orderitem.orderID
	
JOIN BroadclothDW.dbo.DimOrder
	ON  orderitem.orderid = dimorder.order_AK
	
JOIN broadcloth.dbo.factory
	ON factory.factoryID = productionbatch.factoryID
JOIN broadclothdw.dbo.dimfactory
	ON factory.factoryID = dimfactory.factory_AK
JOIN Broadcloth.dbo.compliance
	ON compliance.factoryid = factory.factoryID
JOIN broadclothdw.dbo.DimCompliance
	ON broadcloth.dbo.compliance.complianceID = dimcompliance.compliance_AK
JOIN broadcloth.dbo.item
	ON item.ItemID = productionbatch.ItemID
JOIN Broadclothdw.dbo.DimItem
	ON Item.ItemID = DimItem.item_AK
JOIN Broadcloth.dbo.shipmentItem
	ON customerorder.orderID = shipmentitem.orderID
JOIN Broadcloth.dbo.Shipment
	ON shipment.shipmentID = ShipmentItem.ShipmentID
JOIN BroadclothDW.dbo.DimShipment
	ON shipment.shipmentID = DimShipment.Shipment_AK
JOIN BroadclothDW.dbo.DimDate AS DimDate
	ON cast(productionbatch.startdatetime as DATE) = Dimdate.Date
JOIN BroadclothDW.dbo.DimDate AS EETDW
	ON cast(productionbatch.estendTime as DATE) = EETDW.Date
JOIN BroadclothDW.dbo.DimDate AS AETDW
	ON cast(productionbatch.ActualEndTime as DATE) =  AETDW.Date
JOIN BroadclothDW.dbo.Dimdate AS SDDW
	ON cast(Shipment.ShipDate AS DATE) = SDDW.Date;
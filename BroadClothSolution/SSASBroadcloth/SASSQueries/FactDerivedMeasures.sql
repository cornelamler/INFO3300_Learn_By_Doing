SELECT AVG(QualityRating) AS AverageQualityRating
FROM FactBatch
GROUP BY QuantityProduced, EstimatedEndTime, ActualEndTime, ShippingDate, ProductionCost, ShippingCost, QuantityShipped, OrderQuantity, OrderSalePrice, Order_SK, Compliance_SK, Factory_SK, Item_SK, Shipment_SK, StartDate;

SELECT DISTINCT IsHoliday
FROM DimDate;

SELECT [Date]
FROM FactBatch
INNER JOIN DimDate
	ON DimDate.Date_SK = FactBatch.StartDate;

SELECT 
	--Original Measures
	QuantityProduced, 
	QualityRating, 
	EstimatedEndTime, 
	ActualEndTime, 
	ShippingDate, 
	ProductionCost, 
	ShippingCost, 
	QuantityShipped, 
	OrderQuantity, 
	OrderSalePrice, 
	Order_SK, 
	Compliance_SK, 
	Factory_SK, 
	Item_SK, 
    Shipment_SK, 
	StartDate,
	--Derived Measures
	EstimatedCompletionTime = (DATEDIFF(D,SD.Date, EET.Date) + 1),
	ActualCompletionTime = (DATEDIFF(D,SD.Date, AET.DATE) + 1),
	TotalCompletionTime = 
		CASE
			WHEN (DATEDIFF(D,SD.Date, ShD.Date)) >0  THEN (DATEDIFF(D,SD.Date, ShD.Date) + 1)
			ELSE NULL
		END
FROM FactBatch
INNER JOIN DimDate AS SD
	ON SD.Date_SK = FactBatch.StartDate
INNER JOIN DimDate AS EET
	ON EET.Date_SK = FactBatch.EstimatedEndTime
INNER JOIN DimDate AS AET
	ON AET.Date_SK = FactBatch.ActualEndTime
INNER JOIN DimDate AS ShD
	ON ShD.Date_SK = FactBatch.ShippingDate;
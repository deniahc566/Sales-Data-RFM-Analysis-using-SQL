--- Inspecting Data
SELECT TOP 20 * 
FROM dbo.SalesData;

--- Checking unique values
SELECT DISTINCT STATUS FROM dbo.SalesData;
SELECT DISTINCT YEAR_ID FROM dbo.SalesData;
SELECT DISTINCT PRODUCTLINE FROM dbo.SalesData;
SELECT DISTINCT COUNTRY FROM dbo.SalesData;
SELECT DISTINCT DEALSIZE FROM dbo.SalesData;
SELECT DISTINCT TERRITORY FROM dbo.SalesData;

--- GENERAL ANALYSIS
---- Sales by Product Line
SELECT PRODUCTLINE, COUNT(ORDERNUMBER) NumberOfOrders, ROUND(SUM(Sales),2) SALES
FROM dbo.SalesData
GROUP BY PRODUCTLINE;

---- Sales ranked by Products within ProductLine
SELECT 
	PRODUCTLINE,
	RANK() OVER (PARTITION BY PRODUCTLINE ORDER BY SUM(SALES) DESC) RANK,
	PRODUCTCODE, 
	COUNT(ORDERNUMBER) NumberOfOrders,
	ROUND(SUM(SALES),2) SALES
FROM dbo.SalesData
GROUP BY PRODUCTLINE, PRODUCTCODE
ORDER BY PRODUCTLINE

---- Sales by Year
SELECT YEAR_ID, COUNT(ORDERNUMBER) NumberOfOrders, ROUND(SUM(Sales),2) Sales
FROM dbo.SalesData
GROUP BY YEAR_ID
ORDER BY YEAR_ID;

---- Sales by Dealsize
SELECT DEALSIZE, COUNT(ORDERNUMBER) NumberOfOrders, ROUND(SUM(Sales),2) SALES
FROM dbo.SalesData
GROUP BY DEALSIZE
ORDER BY DEALSIZE;

--- RFM Analysis
WITH rfm AS (
	SELECT
		CUSTOMERNAME,
		SUM(SALES) MonetaryValue,
		AVG(SALES) AvgMonetaryValue,
		COUNT(ORDERNUMBER) FrequencyValue,
		MAX(ORDERDATE) LastOrderDate,
		(SELECT MAX(ORDERDATE) FROM dbo.SalesData) MaxOrderDate,
		DATEDIFF(DAY, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM dbo.SalesData)) RecencyValue
	FROM 
		dbo.SalesData
	GROUP BY 
		CUSTOMERNAME
	),
rfm_calc AS (
	SELECT 
		CUSTOMERNAME,
		NTILE(4) OVER (ORDER BY RecencyValue DESC) rfm_recency,
		NTILE(4) OVER (ORDER BY FrequencyValue) rfm_frequency,
		NTILE(4) OVER (ORDER BY AvgMonetaryValue) rfm_monetary
	FROM rfm
	),
#rfm AS (
SELECT 
	*,
	rfm_recency + rfm_frequency + rfm_monetary rfm_cell,
	CAST(rfm_recency AS varchar) + CAST(rfm_frequency AS varchar) + CAST(rfm_monetary AS varchar) rfm_cell_string
FROM rfm_calc
)

SELECT 
	CUSTOMERNAME, rfm_cell_string, 
	CASE 
		WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141, 113, 131, 142) THEN 'Lost Customer'
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 314, 214, 224, 234) THEN 'High Value, Slipping Away'
		WHEN rfm_cell_string IN (311, 411, 421, 414) THEN 'New Customers'
		WHEN rfm_cell_string IN (222, 223, 233, 241, 221, 231, 242) THEN 'Slipping Away'
		WHEN rfm_cell_string IN (323, 333, 321, 422, 332, 432, 424, 341, 441, 331, 342, 312, 322) THEN 'Active'
		WHEN rfm_cell_string IN (433, 434, 443, 444, 442) THEN 'Loyal'
	END rfm_segment
FROM #rfm	


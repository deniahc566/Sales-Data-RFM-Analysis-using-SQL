CREATE TABLE SalesData (
	ORDERNUMBER Int,
	QUANTITYORDERED Int,
	PRICEEACH Int,
	ORDERLINENUMBER Int, 
	SALES Int,
	ORDERDATE Date, 
	STATUS Varchar(20),
	QTRID Int,
	MONTHID Int,
	YEARID Int,
	PRODUCTLINE Varchar(50),
	MSPR Int, 
	PRODUCTCODE Varchar(50),
	CUSTOMERNAME Varchar(50),
	PHONE Varchar(50),
	ADDRESSLINE1 Varchar(50),
	ADDRESSLINE2 Varchar(50),
	CITY Varchar(40),
	STATE Varchar(20),
	POSTALCODE Varchar(50),
	COUNTRY Varchar(20),
	TERRITORY Varchar(10),
	CONTACTLASTNAME Varchar(30),
	CONTACTFIRSTNAME Varchar(30),
	DEALSIZE Varchar(20)
	);

BULK INSERT Sales_RFM_Analysis.SalesData
	FROM 'D:\Projects\Car Sales Data RFM Analysis\sales_data_sample.csv'
	WITH (
       DATAFILETYPE    = 'char', 
       FIELDTERMINATOR = ',', 
       ROWTERMINATOR   = '\n'
    );
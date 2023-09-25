--SQL Advance Case Study
Use db_SQLCaseStudies

--Q1--BEGIN 
SELECT L.STATE
FROM FACT_TRANSACTIONS AS T
JOIN DIM_LOCATION AS L
ON T.IDLocation=L.IDLocation
WHERE 
DATEPART(YEAR, DATE)  > = 2005
GROUP BY L.State;





--Q1--END

--Q2--BEGIN
SELECT TOP 1 L.COUNTRY,L.STATE,
COUNT(T.IDLOCATION) AS NO_USERS
FROM DIM_LOCATION AS L
JOIN FACT_TRANSACTIONS AS T
ON L.IDLocation=T.IDLocation
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE COUNTRY = 'US' AND MANUFACTURER_NAME= 'SAMSUNG'
GROUP BY L.COUNTRY,L.STATE
ORDER BY  NO_USERS DESC
;










--Q2--END

--Q3--BEGIN      
SELECT  M.MODEL_NAME,L.STATE, L.ZipCode,
COUNT(T.IDCUSTOMER) AS NO_TRANSACTIONS
FROM DIM_LOCATION AS L
JOIN FACT_TRANSACTIONS AS T
ON L.IDLocation=T.IDLocation
JOIN DIM_MODEL AS M
ON T.IDModel=M.IDModel
GROUP BY M.Model_Name, L.ZipCode,L.STATE
ORDER BY M.MODEL_NAME,L.STATE, L.ZipCode
;




--Q3--END

--Q4--BEGIN
SELECT TOP 1 MODEL_NAME, UNIT_PRICE
FROM DIM_MODEL 
GROUP BY MODEL_NAME, UNIT_PRICE
ORDER BY UNIT_PRICE;






--Q4--END

--Q5--BEGIN

SELECT MU.MANUFACTURER_NAME,MO.MODEL_NAME,AVG(T.TOTALPRICE) AS AVG_PRICE,
SUM(T.QUANTITY) AS TOTAL_QTY 
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE MANUFACTURER_NAME IN (SELECT  TOP 5  MU.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
GROUP BY MU.Manufacturer_Name
ORDER BY SUM(T.TOTALPRICE) DESC)
GROUP BY MU.Manufacturer_Name,MO.MODEL_NAME
ORDER BY AVG_PRICE DESC, TOTAL_QTY
;












--Q5--END

--Q6--BEGIN
SELECT C.Customer_Name, 
AVG(T.TOTALPRICE) AS AVG_PRICE
FROM FACT_TRANSACTIONS AS T
JOIN DIM_CUSTOMER AS C
ON T.IDCustomer=C.IDCustomer
WHERE 
DATEPART(YEAR, DATE) = 2009
GROUP BY C.Customer_Name
HAVING AVG(T.TotalPrice) > 500
;











--Q6--END
	
--Q7--BEGIN  
SELECT * FROM (
SELECT TOP 5 M.MODEL_NAME, M.IDMODEL
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS M
ON T.IDModel=M.IDModel
WHERE 
YEAR (DATE) = 2008
GROUP BY M.MODEL_NAME,M.IDMODEL
ORDER BY SUM(T.QUANTITY) DESC ) AS T1
INTERSECT
SELECT * FROM (
SELECT TOP 5 M.MODEL_NAME,M.IDMODEL
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS M
ON T.IDModel=M.IDModel
WHERE 
YEAR (DATE) = 2009
GROUP BY M.MODEL_NAME,M.IDMODEL
ORDER BY SUM(T.QUANTITY) DESC ) AS T2
INTERSECT
SELECT * FROM (
SELECT TOP 5 M.MODEL_NAME,M.IDMODEL
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS M
ON T.IDModel=M.IDModel
WHERE 
YEAR (DATE) = 2010
GROUP BY M.MODEL_NAME,M.IDMODEL
ORDER BY SUM(T.QUANTITY) DESC ) AS T3
;
	
















--Q7--END	
--Q8--BEGIN
SELECT * FROM (
SELECT TOP 1* FROM (
SELECT TOP 2  MU.Manufacturer_Name,SUM(T.TotalPrice) AS SALES
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE
YEAR( DATE) = 2009  
GROUP BY MU.Manufacturer_Name
ORDER BY  SALES DESC ) AS T1
ORDER BY SALES ) AS A
UNION ALL 
SELECT * FROM (
SELECT TOP 1* FROM (
SELECT TOP 2  MU.Manufacturer_Name,SUM(T.TotalPrice) AS SALES
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE
YEAR( DATE) = 2010
GROUP BY MU.Manufacturer_Name
ORDER BY  SALES DESC ) AS T1
ORDER BY SALES) AS B;


















--Q8--END
--Q9--BEGIN
SELECT MU.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE 
YEAR(DATE) = 2010
GROUP BY MU.Manufacturer_NamE
EXCEPT
SELECT MU.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T
JOIN DIM_MODEL AS MO
ON T.IDModel=MO.IDModel
JOIN DIM_MANUFACTURER AS MU
ON MO.IDManufacturer=MU.IDManufacturer
WHERE 
YEAR(DATE) = 2009
GROUP BY MU.Manufacturer_Name

















--Q9--END

--Q10--BEGIN
SELECT *, ((AVG_SPEND-CHANGE_SPEND)/CHANGE_SPEND) AS PERCENT_CHANGE FROM (
SELECT *, LAG(AVG_SPEND, 1) OVER ( PARTITION BY IDCUSTOMER ORDER BY _YEAR) AS CHANGE_SPEND FROM (
SELECT   IDCUSTOMER,  DATEPART(YEAR, DATE) AS _YEAR,
AVG(TOTALPRICE) AS AVG_SPEND,
AVG(QUANTITY) AS AVG_QTY
FROM FACT_TRANSACTIONS 
WHERE IDCUSTOMER IN (SELECT TOP 10 IDCUSTOMER
                             FROM FACT_TRANSACTIONS 
                             GROUP BY IDCUSTOMER
                             ORDER BY SUM(TOTALPRICE) DESC) 
GROUP BY IDCUSTOMER, DATEPART(YEAR, DATE) ) AS T1 ) T2
;



















--Q10--END



SELECT *
FROM DIM_MANUFACTURER;

SELECT *
FROM DIM_CUSTOMER;

SELECT *
FROM DIM_DATE;

SELECT *
FROM DIM_LOCATION;

SELECT *
FROM DIM_MODEL;

SELECT *
FROM FACT_TRANSACTIONS;
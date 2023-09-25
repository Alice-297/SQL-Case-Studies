CREATE DATABASE RETAIL_AS
USE RETAIL_AS;

SELECT *
FROM TRANSACTIONS;

SELECT *
FROM PROD_CAT_INFO;

SELECT *
FROM CUSTOMER;   

--DATA PREPARATION AND UNDERSTANDING
--Q1
SELECT 
COUNT(*) AS NO_ROWS
FROM CUSTOMER
Union all
SELECT 
COUNT(*) AS NO_ROWS
FROM PROD_CAT_INFO
union all
SELECT
COUNT(*) AS NO_ROWS
FROM TRANSACTIONS;




--Q2

SELECT 
COUNT(DISTINCT TRANSACTION_ID) AS TOTAL_RETURN_TRANS
FROM TRANSACTIONS
WHERE
QTY < 0
;

--Q3

SELECT *,
CAST(TRAN_DATE AS DATE)
FROM TRANSACTIONS;

--Q4 

SELECT 
DATEDIFF(DAY,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS TIME_IN_DAYS,
DATEDIFF(MONTH, MIN(TRAN_DATE),MAX(TRAN_DATE)) AS TIME_IN_MONTHS,
DATEDIFF(YEAR, MIN(TRAN_DATE),MAX(TRAN_DATE)) AS TIME_IN_YEARS
FROM TRANSACTIONS
;

--Q5

SELECT 
PROD_CAT
FROM PROD_CAT_INFO
WHERE
PROD_SUBCAT = 'DIY'
;

--DATA ANALYSIS
--Q1

SELECT TOP 1 STORE_TYPE,
COUNT(TRANSACTION_ID) AS _FREQ
FROM TRANSACTIONS
GROUP BY STORE_TYPE
ORDER BY _FREQ DESC
;


--Q2
 SELECT GENDER,
 COUNT(CUSTOMER_ID) AS _COUNT
 FROM CUSTOMER
 WHERE GENDER IS NOT NULL
 GROUP BY GENDER 
 ;
 

 --Q3
 SELECT TOP 1  CITY_CODE,
 COUNT(CUSTOMER_ID) AS _MAXCUST
 FROM CUSTOMER
 GROUP BY CITY_CODE
 ORDER BY _MAXCUST DESC
 ;

 --Q4
 SELECT 
 COUNT(PROD_SUBCAT) AS CAT_UNDER_BOOKS
 FROM PROD_CAT_INFO
 WHERE
 PROD_CAT='BOOKS'
 ;

 --Q5
 SELECT 
 MAX(QTY) AS _MAXTRAN
 FROM TRANSACTIONS
 ;

 --Q6
 SELECT 
 SUM(TOTAL_AMT) AS NET_TOTAL_REVENUE
 FROM TRANSACTIONS AS T
 JOIN 
 PROD_CAT_INFO AS P
 ON T.prod_cat_code=P.prod_cat_code AND T.prod_subcat_code=P.prod_sub_cat_code
 WHERE
 PROD_CAT IN ('ELECTRONICS','BOOKS')
 ;

 --Q7
 SELECT COUNT(CUST_ID) AS NO_CUSTOMERS FROM (
 SELECT CUST_ID,
 COUNT(TRANSACTION_ID) AS NO_CUST
 FROM TRANSACTIONS
 WHERE QTY > 0
 GROUP BY CUST_ID 
 HAVING COUNT(TRANSACTION_ID) > 10 ) AS T
 ;

 --Q8
 SELECT  
 SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE
 FROM PROD_CAT_INFO AS PC
 JOIN
 TRANSACTIONS AS T
 ON PC.prod_cat_code=T.prod_cat_code AND PC.prod_sub_cat_code=T.prod_subcat_code
 WHERE 
 PROD_CAT LIKE 'Electronics' AND PROD_CAT LIKE 'Clothing' OR STORE_TYPE = 'Flagship store' 
 ;

 --Q9
 SELECT prod_subcat ,SUM(CAST(t.TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE
 FROM Customer AS C
 JOIN TRANSACTIONS AS T
 ON C.customer_Id = T.cust_id
 JOIN PROD_CAT_INFO AS PC
 ON T.prod_cat_code=PC.prod_cat_code  AND T.prod_subcat_code=PC.prod_sub_cat_code
 WHERE Gender  LIKE 'M' AND prod_cat  LIKE 'Electronics'
 GROUP BY prod_subcat
 ;


 --Q10
 SELECT T1.PROD_SUBCAT, T1.SALES_PERCENTAGE,T2.RETURN_PERCENTAGE FROM (
 SELECT TOP 5 PC.prod_subcat, (SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES FROM TRANSACTIONS WHERE QTY > 0)) * 100   AS SALES_PERCENTAGE 
 FROM TRANSACTIONS AS T
 JOIN
 PROD_CAT_INFO AS PC
 ON T.prod_cat_code=PC.prod_cat_code AND T.prod_subcat_code=PC.prod_sub_cat_code
 WHERE QTY > 0 
 GROUP BY PC.prod_subcat
 ORDER BY SALES_PERCENTAGE DESC ) AS T1
 LEFT JOIN (SELECT PC.prod_subcat, (SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES FROM TRANSACTIONS WHERE QTY < 0)) * 100   AS RETURN_PERCENTAGE 
 FROM TRANSACTIONS AS T
 JOIN
 PROD_CAT_INFO AS PC
 ON T.prod_cat_code=PC.prod_cat_code AND T.prod_subcat_code=PC.prod_sub_cat_code
 WHERE QTY < 0
 GROUP BY PC.prod_subcat ) AS T2
 ON T1.prod_subcat = T2.prod_subcat
 ;

 --Q11

 
 select * from (
select cust_id,age,Net_revenue from (
 SELECT t.cust_id,DOB,max(cast(tran_date as date)) as max_tran_date, 
 sum (cast(total_amt as float )) as Net_revenue,
 DATEDIFF(year,DOB,getdate()) as age
 FROM Customer as c 
 join Transactions as t 
 on c.customer_Id=t.cust_id 
 where qty > 0
 group by cust_id,DOB ) as P
 where age between 25 and 35
 ) as A
 join
 (select cust_id, cast(tran_date as date) as trans_date 
 from Transactions
 group by cust_id, cast(tran_date as date)
 having cast(tran_date as date) >= (select dateadd(day,-30, max(cast(tran_date as date))) as cut_off from Transactions ) ) as B
 on a.cust_id=b.cust_id
 ;


 --Q12
 select top 1 prod_cat, sum(returns_) as total_returns from (
 select  prod_cat, cast(tran_date as date) as trans_date , sum(qty) as returns_
 from Transactions as t
 join prod_cat_info as p
 on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
 where qty < 0
 group by prod_cat, cast(tran_date as date)
 having cast(tran_date as date) >= (select dateadd(month,-3, max(cast(tran_date as date))) as cut_off from Transactions)) as T1
 group by prod_cat
 order by total_returns
 




 --Q13
 SELECT TOP 1 STORE_TYPE,SUM(TOTAL_AMT) AS _SOLDPRODUCTS, COUNT(QTY) as qty_sold
 FROM TRANSACTIONS
 where qty > 0
 GROUP BY STORE_TYPE
 ORDER BY  _SOLDPRODUCTS DESC ,COUNT(QTY)DESC;

 --Q14
 SELECT PROD_CAT_CODE, AVG(TOTAL_AMT) AS _AVGCAT
 FROM Transactions
 where Qty > 0
 GROUP BY prod_cat_code
 HAVING AVG(TOTAL_AMT) > (SELECT AVG(TOTAL_AMT) AS _AVG FROM TRANSACTIONS)
 ;

 --Q15
 SELECT PROD_SUBCAT_CODE, AVG(total_amt) AS _AVG, sum(total_amt) AS _TOTALREVENUE
 FROM Transactions
 where prod_cat_code in (SELECT TOP 5 prod_cat_code
 FROM TRANSACTIONS
 GROUP BY prod_cat_code
 ORDER BY SUM(QTY) DESC) 
 GROUP BY PROD_SUBCAT_CODE
 ;
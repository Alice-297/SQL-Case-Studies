/* 
a)
Use sql_casestudy

b)
delete from Transactions 
where mcn is null 
or Store_ID is null
or Cash_Memo_No is null;

c)
select * into final_data from Transactions as t
left join Customer as c
on t.MCN = c.CustID; */

select * from final_data;



--Q1. Count the number of observations having any of the variables having null value/missing values?
SELECT COUNT(*)
FROM FINAL_DATA
WHERE ITEMCOUNT IS NULL
OR TRANSACTIONDATE IS NULL 
OR TOTALAMOUNT IS NULL
OR SALEAMOUNT IS NULL
OR SALEPERCENT IS NULL
OR CASH_MEMO_NO IS NULL
OR DEP1AMOUNT IS NULL
OR DEP2AMOUNT IS NULL
 OR DEP3AMOUNT IS NULL
OR DEP4AMOUNT IS NULL
OR Store_ID IS NULL
OR MCN IS NULL
OR CUSTID IS NULL 
OR GENDER IS NULL 
OR [LOCATION] IS NULL 
OR AGE IS NULL 
OR CUST_SEG IS NULL 
OR SAMPLE_FLAG IS NULL;

--Q2. How many customers have shopped? (Hint: Distinct Customers)
SELECT COUNT(DISTINCT CustID) AS NO_SHOPPERS
FROM FINAL_DATA;

--Q3.  How many shoppers (customers) visiting more than 1 store?
SELECT COUNT(MCN) as no_shoppers
FROM (SELECT MCN FROM FINAL_DATA
GROUP BY MCN
HAVING COUNT(DISTINCT Store_ID) > 1 ) AS T --one customer can visit one store many times so distinct is used to find one customer visiting more than 1 store
;

--Q4.What is the distribution of shoppers by day of the week? How the customer shopping behavior on each day of week? (Hint: You are required to calculate number of customers, number of transactions, total sale amount, total quantity etc.. by each week day)
SELECT DATENAME(WEEKDAY,TRANSACTIONDATE) AS DAY_WEEK,COUNT(DISTINCT MCN) AS NO_CUST,COUNT(*) AS NO_TRANS, SUM(TOTALAMOUNT) AS TOTAL_AMT, SUM(ITEMCOUNT) AS TOTAL_QTY
FROM FINAL_DATA
GROUP BY DATENAME(WEEKDAY,TRANSACTIONDATE)
ORDER BY DAY_WEEK ;
 

--Q5.  What is the average revenue per customer/average revenue per customer by each location?
SELECT [LOCATION], MCN, AVG(TOTALAMOUNT) AS AVG_REVENUE
FROM FINAL_DATA
GROUP BY [LOCATION], MCN
;

--Q6.  Average revenue per customer by each store etc?
SELECT Store_ID, MCN, AVG(TOTALAMOUNT) AS AVG_REVENUE
FROM FINAL_DATA
GROUP BY Store_ID ,MCN
ORDER BY Store_ID
;

--Q7. Find the department spend by store wise?
SELECT Store_ID, SUM(DEP1AMOUNT + DEP2AMOUNT + DEP3AMOUNT + DEP4AMOUNT) AS DEPT_SPEND --adding amounts in all dep into a column named dept_spend
FROM FINAL_DATA
GROUP BY Store_ID;

--Q8. What is the Latest transaction date and Oldest Transaction date? (Finding the minimum and maximum transaction dates)
SELECT MAX(TRANSACTIONDATE) AS LATEST_TRANSDATE,
MIN(TRANSACTIONDATE) AS OLDEST_TRANSDATE
FROM FINAL_DATA;


--Q9. How many months of data provided for the analysis?
SELECT DATEDIFF(MONTH,MIN(TRANSACTIONDATE),MAX(TRANSACTIONDATE)) AS NO_MONTHS--it will give difference of two dates in terms of months
FROM FINAL_DATA;

--Q10. Find the top 3 locations interms of spend and total contribution of sales out of total sales?
SELECT TOP 3 [Location],SUM(TOTALAMOUNT) AS TOTAL_AMT,SalePercent
FROM FINAL_DATA
GROUP BY [Location], SalePercent
ORDER BY 2 DESC , 3
;



--Q11. Find the customer count and Total Sales by Gender?
SELECT GENDER, COUNT(MCN) AS CUST_COUNT, SUM(TOTALAMOUNT) AS TOTAL_AMT
FROM FINAL_DATA
GROUP BY GENDER
;



--Q12. What is total  discount and percentage of discount given by each location?
SELECT [LOCATION], SUM(TOTALAMOUNT - SALEAMOUNT) AS TOTAL_DISCOUNT,
( SUM(TOTALAMOUNT - SALEAMOUNT) / SUM(TOTALAMOUNT)) * 100 AS PERCENTAGE_DISCOUNT
FROM FINAL_DATA
GROUP BY [LOCATION]
;


--Q13. Which segment of customers contributing maximum sales?
SELECT TOP 1 CUST_SEG, MAX(TOTALAMOUNT) AS TOTAL_AMT
FROM final_data
GROUP BY Cust_seg
ORDER BY TOTAL_AMT
;


--Q14. What is the average transaction value by location, gender, segment?
SELECT [LOCATION], GENDER, CUST_SEG, AVG(TOTALAMOUNT) AS AVG_VAL
FROM final_data
GROUP BY [Location], Gender, Cust_seg
;



/*Q15. Create Customer_360 Table with below columns.
Customer_id,
Gender,
Location,
Age,
Cust_seg,
No_of_transactions,
No_of_items,
Total_sale_amount,
Average_transaction_value,
TotalSpend_Dep1,
TotalSpend_Dep2,
TotalSpend_Dep3,
TotalSpend_Dep4,
No_Transactions_Dep1,
No_Transactions_Dep2,
No_Transactions_Dep3,
No_Transactions_Dep4,
No_Transactions_Weekdays,
No_Transactions_Weekends,
Rank_based_on_Spend,
Decile */


SELECT 
mcn as Customer_id, 
Gender, 
[Location],
Age,
COUNT(*) as No_of_transactions, 
sum(ItemCount) as No_of_Items, 
 Total_sale_amount, 
Total_sale_amount/count(*) as Average_transaction_value, 
sum(Dep1Amount) as TotalSpend_Dep1, 
sum(Dep2Amount) as TotalSpend_Dep2,
sum(Dep3Amount) as TotalSpend_Dep3,
sum(Dep4Amount) as TotalSpend_Dep4,
sum(case when Dep1Amount > 0 then 1 else 0 end) as No_Transactions_Dep1,--Using case when, finding the value which is greater than 1 and thus adding all to find total transactions
sum(case when Dep2Amount > 0 then 1 else 0 end) as No_Transactions_Dep2,
sum(case when Dep3Amount > 0 then 1 else 0 end) as No_Transactions_Dep3,
sum(case when Dep4Amount > 0 then 1 else 0 end) as No_Transactions_Dep4,
sum(case when datepart(weekday, transactiondate) in (1,2,3,4,5) then 1 else 0 end) as No_Transactions_Weekdays,--if weekday is either of the list provided then value is 1 and adding values to find no of transactions
sum(case when datepart(weekday, transactiondate) in (6,7) then 1 else 0 end) as No_Transactions_Weekends,--same as above just list contains weekends numbers 6 or 7
DENSE_RANK() over (order by Total_sale_amount desc) as Rank_based_on_Spend,
NTILE(10) over (order by Total_sale_amount) as Decile --ntile divides the whole range into equal parts as we provide 10 so it will divide into 10 equal parts to get decile
into Customer_360         --adding  all above columns into customer_360 table
from  (
  select 
     mcn,
	 Gender,
	 [Location],
	 Age,
	 TotalAmount as Total_sale_amount,
	 ItemCount,
	 Dep1Amount,
	 Dep2Amount,
	 Dep3Amount,
	 Dep4Amount,
	 TransactionDate
     from final_data) as T2
group by
      MCN,
	  Gender,
	  [Location],
	  Age,
	  Total_sale_amount
;

/* Select * from Customer_360;
 --d)
 select * from final_data
 where Sample_flag = '1'
 ;

 select * into sample_data from final_data
 where Sample_flag = '1'
 ;

 */
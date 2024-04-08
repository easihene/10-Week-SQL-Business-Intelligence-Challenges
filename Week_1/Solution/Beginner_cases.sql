--Business Case 1 
--===============================================================================================
-- Identify the top 2 most popular clothing categories (by total units sold) in the past quarter.
--==============================================================================================

select ProductCategory, TotalQuantitySold,TopQuantitySold
from 
(
	select p.ProductCategory,sum(t.Quantity) as TotalQuantitySold,
	DENSE_RANK() over (order by sum(t.Quantity) desc) as TopQuantitySold
	from [clothing].[SalesTransactions] as t
	inner join [clothing].[Products] as p on t.ProductID = p.ProductID
	WHERE TransactionDate >= DATEADD(quarter, -1, GETDATE()) --filter previous quarter
	group by p.ProductCategory
) as Subquery
where TopQuantitySold <=2


--Business Case 2
--===============================================================================================
-- Calculate the average order value (total revenue per transaction) for the past month.
--==============================================================================================

-- Calculate average order value
select format(avg(RevenuePerTransaction),'C') as Average_Revenue_PastMonth
from 
(	-- Filter transactions for the past month
	select t.Quantity*p.UnitPrice*(1-t.Discount) as RevenuePerTransaction
	from [clothing].[SalesTransactions] as t
	inner join [clothing].[Products] as p on t.ProductID = p.ProductID
	WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE()) --filter past month
) as Subquery


--Business Case 3
--===============================================================================================
-- Find the city with the highest average customer spending.
--==============================================================================================

WITH CustomerSpending AS (
    SELECT
        c.CustomerID,
        c.City,
        SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) AS TotalSpending -- Calculates total spending per customer
    FROM Clothing.SalesTransactions st
    JOIN Clothing.Customers c ON st.CustomerID = c.CustomerID
    JOIN Clothing.Products p ON st.ProductID = p.ProductID
    GROUP BY c.CustomerID, c.City
), AverageCitySpending AS (
    SELECT
        City,
        AVG(TotalSpending) AS AverageSpending,
        DENSE_RANK() OVER (ORDER BY AVG(TotalSpending) DESC) AS SpendingRank -- Ranks cities by average spending
    FROM CustomerSpending
    GROUP BY City
)
SELECT 
    City, 
    AverageSpending,
    SpendingRank
FROM AverageCitySpending
WHERE SpendingRank = 1; -- Selects the top-ranked city/cities in terms of average spending

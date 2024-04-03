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

select City, CustomerName,format(avgSpendingPerTransaction,'C') as avgSpendingPerTransaction,avgSpendingRank from
(
select c.CustomerID, CONCAT_WS(', ',upper(c.LasttName),c.FirstName) as CustomerName,c.City,
avg(t.Quantity*p.UnitPrice*(1-t.Discount)) as avgSpendingPerTransaction,
DENSE_RANK() over (order by avg(t.Quantity*p.UnitPrice*(1-t.Discount)) desc) as avgSpendingRank
from [clothing].[SalesTransactions] as t
inner join [clothing].[Products] as p on t.ProductID = p.ProductID
inner join [clothing].[Customers] as c on t.CustomerID=c.CustomerID
group by c.CustomerID, CONCAT_WS(', ',upper(c.LasttName),c.FirstName),c.City
) as Subquery
where avgSpendingRank <=1

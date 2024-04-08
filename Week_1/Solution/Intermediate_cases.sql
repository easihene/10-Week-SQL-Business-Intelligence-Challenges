--Business case 4
--===============================================================
-- Analyzes sales trends by product category over the past year
--===============================================================
SELECT
    p.ProductCategory,
    DATEPART(MONTH, st.TransactionDate) AS SaleMonth,
    DATEPART(YEAR, st.TransactionDate) AS SaleYear,
    SUM(st.Quantity) AS TotalUnitsSold,
    COUNT(DISTINCT st.TransactionID) AS NumberOfTransactions
FROM Clothing.SalesTransactions st
JOIN Clothing.Products p ON st.ProductID = p.ProductID
WHERE st.TransactionDate >= DATEADD(YEAR, -1, GETDATE()) -- Filters transactions to the past year
GROUP BY p.ProductCategory, DATEPART(YEAR, st.TransactionDate), DATEPART(MONTH, st.TransactionDate)
ORDER BY p.ProductCategory, SaleYear, SaleMonth;

--Business Case 5
--===============================================================
-- Segments customers based on their purchase frequency
--===============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LasttName,
    c.Email,
    PurchaseFrequency,
    CASE
        WHEN PurchaseFrequency = 1 THEN 'One-time buyer'
        WHEN PurchaseFrequency BETWEEN 2 AND 5 THEN 'Occasional buyer'
        WHEN PurchaseFrequency > 5 THEN 'Frequent buyer'
        ELSE 'Unknown' -- Covers edge cases, just in case
    END AS CustomerSegment
FROM
    (
        -- Subquery to count transactions per customer
        SELECT
            CustomerID,
            COUNT(*) AS PurchaseFrequency -- Counts the number of transactions for each customer
        FROM Clothing.SalesTransactions
        GROUP BY CustomerID
    ) AS TransactionCount
INNER JOIN Clothing.Customers c ON TransactionCount.CustomerID = c.CustomerID
ORDER BY PurchaseFrequency DESC; -- Orders results by purchase frequency to easily see distribution

--Business case 6
--========================================================================
/*
Calculates the contribution margin for each product category. 
Assumes variable costs are 60% of the revenue, calculated as 60% of 
the product's unit price times the quantity sold, adjusted for discounts
*/
--=======================================================================
SELECT
    p.ProductCategory,
    SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) AS TotalRevenue, -- Total revenue per category
    SUM(p.UnitPrice * st.Quantity * (1 - st.Discount) * 0.6) AS TotalVariableCosts, -- Total variable costs (60% of revenue)
    (SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) - SUM(p.UnitPrice * st.Quantity * (1 - st.Discount) * 0.6)) AS TotalContributionMargin,
    ((SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) - SUM(p.UnitPrice * st.Quantity * (1 - st.Discount) * 0.6)) / SUM(p.UnitPrice * st.Quantity * (1 - st.Discount))) * 100 AS ContributionMarginPercentage
FROM Clothing.SalesTransactions st
JOIN Clothing.Products p ON st.ProductID = p.ProductID
GROUP BY p.ProductCategory
ORDER BY ContributionMarginPercentage DESC; -- Orders the categories by their contribution margin percentage

--Business case 7
--===============================================================
-- Calculates the customer churn rate
--===============================================================
WITH LastPurchase AS (
    SELECT 
        CustomerID, 
        MAX(TransactionDate) AS LastTransactionDate -- Finds the last transaction date for each customer
    FROM Clothing.SalesTransactions
    GROUP BY CustomerID
), ActiveCustomers AS (
    SELECT 
        COUNT(*) AS ActiveCustomerCount -- Counts customers who have made a purchase in the last 6 months
    FROM LastPurchase
    WHERE LastTransactionDate >= DATEADD(MONTH, -6, GETDATE())
), TotalCustomers AS (
    SELECT 
        COUNT(*) AS TotalCustomerCount -- Counts the total number of customers
    FROM Clothing.Customers
)
SELECT 
    (1 - CAST(ActiveCustomerCount AS FLOAT) / CAST(TotalCustomerCount AS FLOAT)) * 100 AS ChurnRatePercentage
FROM ActiveCustomers, TotalCustomers;

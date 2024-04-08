--Business Case 8
--===================================================================
-- Creates a stored procedure for generating a weekly sales report
--=================================================================
CREATE OR ALTER PROCEDURE Clothing.GenerateWeeklySalesReport
AS
BEGIN
    SET NOCOUNT ON;

    -- Total Revenue for the week
    SELECT 
        SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) AS TotalRevenue
    FROM Clothing.SalesTransactions st
    JOIN Clothing.Products p ON st.ProductID = p.ProductID
    WHERE st.TransactionDate >= DATEADD(WEEK, -1, GETDATE()); -- Filters to the last week

    -- Average Order Value for the week
    SELECT 
        AVG(OrderValue) AS AverageOrderValue
    FROM 
        (
            SELECT 
                st.TransactionID, 
                SUM(p.UnitPrice * st.Quantity * (1 - st.Discount)) AS OrderValue
            FROM Clothing.SalesTransactions st
            JOIN Clothing.Products p ON st.ProductID = p.ProductID
            WHERE st.TransactionDate >= DATEADD(WEEK, -1, GETDATE())
            GROUP BY st.TransactionID
        ) AS WeeklyOrders;

    -- Best-Selling Products for the week using DENSE_RANK
    ;WITH RankedProducts AS (
        SELECT 
            p.ProductName,
            SUM(st.Quantity) AS TotalUnitsSold,
            DENSE_RANK() OVER (ORDER BY SUM(st.Quantity) DESC) AS SalesRank
        FROM Clothing.SalesTransactions st
        JOIN Clothing.Products p ON st.ProductID = p.ProductID
        WHERE st.TransactionDate >= DATEADD(WEEK, -1, GETDATE())
        GROUP BY p.ProductName
    )
    SELECT ProductName, TotalUnitsSold
    FROM RankedProducts
    WHERE SalesRank <= 1; -- Filter the best seller

END;

--=======================================================================
--To execute this stored procedure and generate the weekly sales report
--========================================================================
EXEC Clothing.GenerateWeeklySalesReport;

--Business Case 9
--==========================================================================
-- Identifies product co-purchasing patterns for upselling recommendations
--========================================================================
WITH ProductPairs AS (
    SELECT
        st1.ProductID AS ProductID1,
        st2.ProductID AS ProductID2,
        COUNT(*) AS TimesBoughtTogether
    FROM Clothing.SalesTransactions st1
    JOIN Clothing.SalesTransactions st2 ON st1.TransactionID = st2.TransactionID
        AND st1.ProductID < st2.ProductID -- Ensures different products and avoids duplicate pairs in reverse order
    GROUP BY st1.ProductID, st2.ProductID
)
SELECT
    p1.ProductName AS Product1,
    p2.ProductName AS Product2,
    pp.TimesBoughtTogether
FROM ProductPairs pp
JOIN Clothing.Products p1 ON pp.ProductID1 = p1.ProductID
JOIN Clothing.Products p2 ON pp.ProductID2 = p2.ProductID
ORDER BY pp.TimesBoughtTogether DESC; -- Orders the result by the most frequently bought pairs

--Business Case 10
--=========================================================
-- Identifies products with missing categories
--======================================================
SELECT 
    ProductID, 
    ProductName 
FROM Clothing.Products 
WHERE ProductCategory IS NULL OR ProductCategory = '';

--===============================================================
-- Identifies customers with potentially invalid email addresses
--==========================================================
SELECT 
    CustomerID, 
    FirstName, 
    LasttName, 
    Email 
FROM Clothing.Customers 
WHERE Email NOT LIKE '%@%';

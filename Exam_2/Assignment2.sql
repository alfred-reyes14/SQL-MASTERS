/** Problem 1 **/
WITH CTETotalOrders as (
    SELECT
     T4.ProductName,
     SUM(T3.Quantity) as TotalQuantity
    FROM [dbo].[Order] T1
    INNER JOIN [dbo].[Store] T2 ON T2.StoreId = T1.StoreId
    INNER JOIN [dbo].[OrderItem] T3 ON T3.OrderId = T1.OrderId
    INNER JOIN [dbo].[Product] T4 ON T4.ProductId = T3.ProductId
    WHERE T2.State = 'TX'
    GROUP BY T4.ProductName, T3.Quantity
)

SELECT * FROM CTETotalOrders WHERE TotalQuantity > 10 ORDER BY TotalQuantity DESC

/** Problem 2 **/

WITH CTETotalCategoryQuantity as (
    SELECT
         REPLACE(T3.CategoryName, 'Bikes', 'Bicycles') as CategoryName,
         SUM(T2.CategoryId) as TotalQuantity
    FROM [dbo].[OrderItem] T1
    INNER JOIN [dbo].[Product] T2 ON T2.ProductId = T1.ProductId
    INNER JOIN [dbo].[Category] T3 ON T3.CategoryId = T2.CategoryId
    GROUP BY T3.CategoryName, T2.CategoryId
)

SELECT * FROM CTETotalCategoryQuantity ORDER BY TotalQuantity DESC;

/** Problem 3 **/
SELECT
     T4.ProductName as CategoryName,
     SUM(T3.Quantity) as TotalQuantity
    FROM [dbo].[Order] T1
    INNER JOIN [dbo].[Store] T2 ON T2.StoreId = T1.StoreId
    INNER JOIN [dbo].[OrderItem] T3 ON T3.OrderId = T1.OrderId
    INNER JOIN [dbo].[Product] T4 ON T4.ProductId = T3.ProductId
    WHERE T2.State = 'TX'
    GROUP BY T4.ProductName, T3.Quantity
    HAVING SUM(T3.Quantity) > 10
UNION ALL
SELECT
    REPLACE(T3.CategoryName, 'Bikes', 'Bicycles') as CategoryName,
    SUM(T2.CategoryId) as TotalQuantity
FROM [dbo].[OrderItem] T1
INNER JOIN [dbo].[Product] T2 ON T2.ProductId = T1.ProductId
INNER JOIN [dbo].[Category] T3 ON T3.CategoryId = T2.CategoryId
GROUP BY T3.CategoryName, T2.CategoryId

/** Problem 4 **/
;WITH CTE AS (
    SELECT
        T1.ProductName,
        YEAR(T3.OrderDate) as OrderYear,
        DATENAME(MONTH, T3.OrderDate) [OrderMonth],
        MONTH(T3.OrderDate) as MonthOrder,
        SUM(T2.Quantity) as TotalQuantity
    FROM [dbo].[Product] T1
    INNER JOIN [dbo].[OrderItem] T2 ON T2.ProductId = T1.ProductId
    INNER JOIN [dbo].[Order] T3 ON T3.OrderId = T2.OrderId
    GROUP BY YEAR(T3.OrderDate), MONTH(T3.OrderDate), T1.ProductName, DATENAME(MONTH, T3.OrderDate)
), CTE2 AS (
    SELECT RANK() OVER (PARTITION BY TotalQuantity ORDER BY TotalQuantity) AS RankId, *
    FROM CTE 
)


SELECT [outter].OrderYear, [outter].OrderMonth, [outter].ProductName, [outter].TotalQuantity 
FROM CTE2 [outter]
WHERE [outter].RankId = 1 AND TotalQuantity IN (SELECT MAX([inner].TotalQuantity) FROM CTE [inner] WHERE [inner].OrderYear = [outter].OrderYear and [inner].MonthOrder = [outter].MonthOrder)
ORDER BY OrderYear, MonthOrder


/** Problem 1 **/

SELECT TOP (1000) 
	 [StoreId]
	,[StoreName]
FROM [SQL4Devsdb].[dbo].[Store]
WHERE StoreId NOT IN (SELECT StoreId FROM [SQL4Devsdb].[dbo].[Order])

/** Problem 2 **/

SELECT
 T3.ProductId,
 T3.ProductName,
 T5.BrandName,
 T4.CategoryName,
 T2.Quantity
FROM [dbo].[Store] T1
LEFT JOIN [dbo].[Stock] T2 ON T2.StoreId = T1.StoreId
LEFT JOIN [dbo].[Product] T3 ON T3.ProductId = T2.ProductId
LEFT JOIN [dbo].[Category] T4 ON T4.CategoryId = T3.CategoryId
LEFT JOIN [dbo].[Brand] T5 ON T5.BrandId = T3.BrandId
WHERE T2.StoreId = 2 AND (T3.ModelYear BETWEEN 2017 AND 2018)
ORDER BY T2.Quantity Desc, T3.ProductName, T5.BrandName, T4.CategoryName

/** Problem 3 **/

SELECT
 T1.Storename,
 YEAR(T2.OrderDate) as OrderYear,
 COUNT(*) as OrderCount
FROM [dbo].[Store] T1
INNER JOIN [dbo].[Order] T2 ON T2.StoreId = T1.StoreId
GROUP BY T1.StoreName, YEAR(T2.OrderDate)
ORDER BY T1.Storename, OrderYear DESC

/** Problem 4 **/

;WITH CTERankProduct as (
 SELECT
	RANK() OVER(PARTITION BY T1.BrandId ORDER BY T1.ListPrice DESC) as RankNo,
	T2.BrandName,
	T1.ProductId,
	T1.ProductName,
	T1.ListPrice
FROM Product T1
INNER JOIN [dbo].[Brand] T2 ON T2.BrandId = T1.BrandId
)

Select * FROM CTERankProduct WHERE RankNo <= 5

/** Problem 5 **/

DECLARE
@storeName varchar(500),
@orderYear INT,
@orderCount INT

DECLARE product_cursor CURSOR FOR 
SELECT
 T1.Storename,
 YEAR(T2.OrderDate) as OrderYear,
 COUNT(*) as OrderCount
FROM [dbo].[Store] T1
INNER JOIN [dbo].[Order] T2 ON T2.StoreId = T1.StoreId
GROUP BY T1.StoreName, YEAR(T2.OrderDate)
ORDER BY T1.Storename, OrderYear DESC

OPEN product_cursor

FETCH NEXT FROM product_cursor   
INTO @storeName, @orderYear, @orderCount

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT CONCAT(@storeName, ' ', @orderYear, ' ', @orderCount)
	FETCH NEXT FROM product_cursor INTO @storeName, @orderYear, @orderCount
END
CLOSE product_cursor  
DEALLOCATE product_cursor


/** Problem 6 **/ 
DECLARE @Var1 INT = 1
DECLARE @Var2 INT

WHILE @Var1 <= 10
BEGIN
	SET @Var2 = 1
	WHILE @Var2 <= 10
	BEGIN
		PRINT CONCAT(@Var1, ' ', '* ', @Var2, ' ', '=', ' ', @Var1 * @Var2)
		SET @Var2 += 1;
	END
    SET @Var1 += 1;
END


/** Problem 7 **/
SELECT
 ISNULL([January], 0.00) as January,
 ISNULL([February], 0.00) as May,
 ISNULL([March], 0.00) as May,
 ISNULL([April], 0.00) as May,
 ISNULL([May], 0.00) as May,
 ISNULL([June], 0.00) as May,
 ISNULL([July], 0.00) as May,
 ISNULL([August], 0.00) as May,
 ISNULL([September], 0.00) as May,
 ISNULL([October], 0.00) as May,
 ISNULL([November], 0.00) as May,
 ISNULL([December], 0.00) as May
FROM (
 SELECT
	YEAR(T1.OrderDate) as SalesYear,
	DATENAME(MONTH, T1.OrderDate) as Month,
	T2.ListPrice
 FROM [dbo].[Order] T1
 INNER JOIN [dbo].[OrderItem] T2 ON T2.OrderId = T1.OrderId
) as T3
PIVOT(
 SUM(ListPrice) FOR [Month] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December])
) as pivot_query
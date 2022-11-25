/** Problem 1 **/
SELECT
	CustomerId,
	COUNT(CustomerId) as OrderCount 
FROM [SQL4Devsdb].[dbo].[Order]
WHERE (YEAR(OrderDate) between 2017 and 2018) AND ShippedDate is NULL
GROUP BY CustomerId
HAVING COUNT(CustomerId) >=2


/** Problem 2 **/

SELECT * INTO Product_20221125
FROM [dbo].[Product]
WHERE ModelYear != 2016

UPDATE [SQL4Devsdb].[dbo].[Product_20221125]
SET ListPrice = (ListPrice * 0.2) + ListPrice
WHERE productname LIKE 'Heller%' or productname LIKE 'Sun Bicycles%'

UPDATE [SQL4Devsdb].[dbo].[Product_20221125]
SET ListPrice = (ListPrice * 0.1) + ListPrice
WHERE productname NOT LIKE 'Heller%' AND productname NOT LIKE 'Sun Bicycles%'
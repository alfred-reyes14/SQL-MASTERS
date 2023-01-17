	/* Problem 1 */
	CREATE PROCEDURE dbo.uspModifyBrand
	@NEW_BRAND_NAME VARCHAR(250), @OLD_BRAND_ID INT
	AS
		BEGIN TRANSACTION [ADD_BRAND]
			BEGIN TRY  
				INSERT INTO [dbo].[Brand]
					([BrandName])
				VALUES
						(@NEW_BRAND_NAME)

				UPDATE [dbo].[Product]
				SET [BrandId] = @@IDENTITY
				WHERE BrandId = @OLD_BRAND_ID


				DELETE FROM [dbo].[Brand] WHERE BrandId = @OLD_BRAND_ID
			COMMIT TRANSACTION [ADD_BRAND]
			END TRY  
			BEGIN CATCH  
					ROLLBACK TRANSACTION [ADD_BRAND]
			END CATCH
	GO 

	EXEC dbo.uspModifyBrand @NEW_BRAND_NAME = 'Tims',  @OLD_BRAND_ID = 9

	DROP PROCEDURE dbo.uspModifyBrand

	/* Problem 2 */

	CREATE PROCEDURE dbo.filteredProducts
	@PRODUCT_NAME VARCHAR(250) = NULL,
	@PRODUCT_BRAND_ID INT = NULL,
	@PRODUCT_CATEGORY_ID INT = NULL,
	@PRODUCT_MODEL_YEAR INT = NULL,
	@PAGE INT = 1,
	@LIMIT INT = 10
	AS
		SELECT
			ProductId,
			ProductName,
			BrandId,
			CategoryId,
			ModelYear,
			ListPrice
		FROM Product
		WHERE ProductName = COALESCE(@PRODUCT_NAME, ProductName) AND
		BrandId = COALESCE(@PRODUCT_BRAND_ID, BrandId) AND
		CategoryId = COALESCE(@PRODUCT_CATEGORY_ID, CategoryId) AND
		ModelYear = COALESCE(@PRODUCT_MODEL_YEAR, ModelYear)
		ORDER BY ModelYear DESC, ListPrice DESC, ProductName
		OFFSET (@PAGE * @LIMIT) - @LIMIT ROWS
		FETCH NEXT @LIMIT ROWS ONLY
	GO 

	EXEC dbo.filteredProducts
	GO
	DROP PROCEDURE dbo.filteredProducts


	/* Problem 3 */

	DECLARE @CategoryId INT
	DECLARE @CategoryName VARCHAR(255)

	DROP TABLE IF EXISTS dbo.tmpProduct
	BEGIN
		SELECT * INTO dbo.tmpProduct FROM [dbo].[Product]
	END

	DECLARE @Counter INT
	DECLARE @TOTAL_ROWCOUNT INT

	DROP TABLE IF EXISTS #tmpCategory
	BEGIN
		SELECT 
			CategoryId, 
			CategoryName, 
			ROW_NUMBER() OVER (ORDER BY CategoryId) AS 'RowNumber' 
		INTO #tmpCategory 
		FROM [dbo].[Category]
	END

	SET @Counter = 1
	SET @TOTAL_ROWCOUNT = (SELECT COUNT(CategoryId) FROM #tmpCategory)
	PRINT(@TOTAL_ROWCOUNT)
	WHILE(@Counter <=  @TOTAL_ROWCOUNT)
		BEGIN
			SET @CategoryId = (
				SELECT TOP(1) 
					CategoryId
				FROM #tmpCategory 
				WHERE RowNumber = @Counter
			)
			SET @CategoryName = (
				SELECT TOP(1) 
					CategoryName
				FROM #tmpCategory 
				WHERE RowNumber = @Counter
			)

			IF(@CategoryName = 'Children Bicycles'
			OR @CategoryName = 'Cyclocross Bicycles'
			OR @CategoryName = 'Road Bikes')
		BEGIN
			UPDATE dbo.tmpProduct
			SET ListPrice = (ListPrice * 1.2)
			WHERE CategoryId = @CategoryId;
		END;
			IF(@CategoryName = 'Comfort Bicycles'
			OR @CategoryName = 'Cruisers Bicycles'
			OR @CategoryName = 'Electric Bikes')
		BEGIN
			UPDATE dbo.tmpProduct
			SET ListPrice = (ListPrice * 1.7)
			WHERE CategoryId = @CategoryId;
		END;
		IF(@CategoryName = 'Mountain Bikes')
		BEGIN
			UPDATE dbo.tmpProduct
			SET ListPrice = (ListPrice * 1.4)
			WHERE CategoryId = @CategoryId;
		END;
		SET @Counter = @Counter  + 1
	END;

	select * FROM Product
	select * FROM dbo.tmpProduct


	/* Problem 4 */
	--A
	CREATE TABLE [dbo].[Ranking] (
		Id INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
		Description NVARCHAR(250),
	);
	GO

	--B
	INSERT INTO [dbo].[Ranking] (Description) VALUES ('Inactive')
	INSERT INTO [dbo].[Ranking] (Description) VALUES ('Bronze')
	INSERT INTO [dbo].[Ranking] (Description) VALUES ('Silver')
	INSERT INTO [dbo].[Ranking] (Description) VALUES ('Gold')
	INSERT INTO [dbo].[Ranking] (Description) VALUES ('Platinum')

	--C
	ALTER TABLE [dbo].[Customer]
	ADD RankingId INT
	FOREIGN KEY(RankingId) REFERENCES Ranking(Id);
	GO

	--D
	CREATE PROCEDURE uspRankCustomers
	AS
	SET NOCOUNT ON;
	DECLARE @TotalAmount DECIMAL
	DECLARE @CustomerId INT

	DECLARE cursor_pointer CURSOR FOR
		SELECT 
			T3.CustomerId,
			SUM((T2.Quantity * T2.ListPrice) / (1 + T2.Discount)) AS TotalAmount
		FROM [dbo].[Order] T1
		INNER JOIN [dbo].[OrderItem] T2
			ON T2.OrderId = T1.OrderId
		INNER JOIN [dbo].Customer T3
			ON T3.CustomerId = T1.CustomerId
		GROUP BY T3.CustomerId
		ORDER BY T3.CustomerId

	OPEN cursor_pointer;
	FETCH NEXT FROM cursor_pointer INTO @CustomerId, @TotalAmount;

	WHILE @@FETCH_STATUS = 0

	BEGIN
		UPDATE 
			dbo.[Customer] 
		SET RankingId = (
			CASE  
				WHEN (@TotalAmount = 0) THEN 1
				WHEN (@TotalAmount > 0 AND @TotalAmount < 1000) THEN 2
				WHEN (@TotalAmount > 1000 AND @TotalAmount < 2000) THEN 3
				WHEN (@TotalAmount > 2000 AND @TotalAmount < 3000) THEN 4 
				ELSE 5
					END 
		) 
		WHERE CustomerId = @CustomerId
		FETCH NEXT FROM cursor_pointer INTO @CustomerId, @TotalAmount;
	END;

	CLOSE cursor_pointer;
	DEALLOCATE cursor_pointer;
	GO

	EXEC dbo.uspRankCustomers

	-- E
	CREATE VIEW vwCustomerOrders AS
	SELECT 
		T2.CustomerId, 
		T2.FirstName,
		T2.LastName,
		SUM((T3.Quantity * T3.ListPrice) / (1 + T3.Discount)) AS TotalAmount, 
		(SELECT [Description] FROM dbo.Ranking WHERE Id = T2.RankingId) AS CustomerRanking
	FROM [dbo].[Order] T1
	INNER JOIN [dbo].Customer T2
		ON T2.CustomerId = T1.CustomerId
	INNER JOIN [dbo].[OrderItem] T3
		ON T3.OrderId = T1.OrderId
	GROUP BY T2.CustomerId, T2.FirstName, T2.LastName, T2.RankingId
	GO

	SELECT * FROM vwCustomerOrders


	/* Problem 5*/

	;WITH CTE AS (
		SELECT 
			CONCAT(FirstName, ' ', LastName) as Fullname, 
			ManagerId, 
			StaffId 
		FROM Staff
		UNION ALL
		SELECT 
			CONCAT(s.FirstName, ' ', s.LastName) as Fullname, 
			s.ManagerId, 
			s.StaffId 
		FROM CTE c
		JOIN Staff s ON s.StaffId = c.ManagerId
	)

	select DISTINCT
		m.StaffId,
		m.Fullname,
		CONCAT_WS(', ', m.Fullname, z.Fullname, y.Fullname, w.Fullname) as EmployeeHierarchy
	from CTE m 
	LEFT JOIN CTE z ON z.StaffId = m.ManagerId
	LEFT JOIN CTE y ON y.StaffId = z.ManagerId
	LEFT JOIN CTE w ON w.StaffId = y.ManagerId

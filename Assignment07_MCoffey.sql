--*************************************************************************--
-- Title: Assignment07
-- Author: MCoffey
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,MCoffey,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_MCoffey')
	 Begin 
	  Alter Database [Assignment07DB_MCoffey] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_MCoffey;
	 End
	Create Database Assignment07DB_MCoffey;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_MCoffey;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go



Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go
--Select
--	Products.ProductName,
--	Inventories.InventoryDate
--	FROM Products
--	Inner Join Inventories on Inventories.ProductID=Products.ProductID
--	ORDER by Products.ProductName, Inventories.InventoryDate
Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
--Select * From vCategories;
--go
--Select * From vProducts;
--go
--Select * From vEmployees;
--go
--Select * From vInventories;
--go

--/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

--Function converts
Select 
	vProducts.ProductName,
	--converts the UnitPrice to VARCHAR and adds the dollar sign to display as USD
	'$'+CONVERT(VARCHAR(255),UnitPrice, 01) AS UnitPrice 
	FROM vProducts
	Order by vProducts.ProductName

go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

Select 
	vCategories.CategoryName,
	vProducts.ProductName,
	--converts the UnitPrice to VARCHAR and adds the dollar sign to display as USD
	'$'+CONVERT(VARCHAR(255),UnitPrice, 01) AS UnitPrice 
	FROM vProducts
	--Joins the two views that contain the data
	Inner Join vCategories on vCategories.CategoryID=vProducts.CategoryID
	Order by vCategories.CategoryName, vProducts.ProductName

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Select
	vProducts.ProductName,
	-- Formats the date as requested
	FORMAT(vInventories.InventoryDate,'MMMM, yyyy') AS [Inventory Date],
	vInventories.Count
	FROM vProducts
	--Joins the required tables
	Inner Join vInventories on vInventories.ProductID=vProducts.ProductID
	Order by vProducts.ProductName, vInventories.InventoryDate
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

CREATE VIEW vProductInventories AS
	Select TOP 500
		vProducts.ProductName,
		-- Formats the date as requested
		FORMAT(vInventories.InventoryDate,'MMMM, yyyy') AS [Inventory Date],
		vInventories.Count
		FROM vProducts
		--Joins the required tables
		Inner Join vInventories on vInventories.ProductID=vProducts.ProductID
		Order by vProducts.ProductName, vInventories.InventoryDate

go
 
Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- Creates a view used to synthesize the desired ordered view
CREATE VIEW vCategoryInventoryInput AS
--Gets distinct values
	SELECT DISTINCT
		vCategories.CategoryName,
		--Formats the date as requested
		FORMAT(vInventories.InventoryDate,'MMMM, yyyy') AS [InventoryDates],
		--grabs sum of inventory count filtered by category and date
		SUM(vInventories.Count)
			OVER (Partition by vCategories.CategoryName, vInventories.InventoryDate)
				AS InventoryCountByCategory
		FROM vCategories
		Inner Join vProducts on vProducts.CategoryID=vCategories.CategoryID
		Inner Join vInventories on vInventories.ProductID=vProducts.ProductID

go

Create View vCategoryInventories AS
	Select TOP 500
		vCategoryInventoryInput.CategoryName,
		vCategoryInventoryInput.InventoryDates,
		vCategoryInventoryInput.InventoryCountByCategory
		FROM vCategoryInventoryInput
		Order by vCategoryInventoryInput.CategoryName, datepart(mm,vCategoryInventoryInput.InventoryDates);
go
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

CREATE VIEW vProductInventoriesWithPreviousMonthCounts AS
	SELECT TOP 500
		vProductInventories.ProductName,
		vProductInventories.[Inventory Date],
		vProductInventories.Count,
		-- Lags the previous month count by 1 month, default to 0
		LAG(vProductInventories.Count,1,0)
			OVER (
				Partition By
					vProductInventories.ProductName
				Order By
				--sets the increment of ordering to a month
					MONTH(vProductInventories.[Inventory Date]))
		PreviousMonthCount
		From vProductInventories
		Order BY vProductInventories.ProductName, DATEPART(mm,vProductInventories.[Inventory Date])--, vProductInventories.Count

go

Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs AS
	SELECT
		vProductInventoriesWithPreviousMonthCounts.ProductName,
		vProductInventoriesWithPreviousMonthCounts.[Inventory Date],
		vProductInventoriesWithPreviousMonthCounts.Count,
		vProductInventoriesWithPreviousMonthCounts.PreviousMonthCount,
		--Performs checks for inventory count increase, decrease, or static condition and returns KPI 1, -1, or 0
		IIF(
			vProductInventoriesWithPreviousMonthCounts.Count-vProductInventoriesWithPreviousMonthCounts.PreviousMonthCount>0, 
			1,
			IIF(
				vProductInventoriesWithPreviousMonthCounts.Count-vProductInventoriesWithPreviousMonthCounts.PreviousMonthCount=0, 
				0,
				-1))
				CountVsPreviousCountKPI
		FROM vProductInventoriesWithPreviousMonthCounts

go		

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.


--Creates the Function to return the specified data given @KPI
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
	RETURNS Table
	As
		Return(
				Select TOP 500
					vProductInventoriesWithPreviousMonthCountsWithKPIs.ProductName,
					vProductInventoriesWithPreviousMonthCountsWithKPIs.[Inventory Date],
					vProductInventoriesWithPreviousMonthCountsWithKPIs.[Count],
					vProductInventoriesWithPreviousMonthCountsWithKPIs.PreviousMonthCount,
					vProductInventoriesWithPreviousMonthCountsWithKPIs.CountVsPreviousCountKPI
					FROM
						vProductInventoriesWithPreviousMonthCountsWithKPIs
					WHERE
					--Returns only values for the specified KPI
						vProductInventoriesWithPreviousMonthCountsWithKPIs.CountVsPreviousCountKPI=@KPI
					Order By
						vProductInventoriesWithPreviousMonthCountsWithKPIs.ProductName,MONTH(vProductInventoriesWithPreviousMonthCountsWithKPIs.[Inventory Date])
			)

go


Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/
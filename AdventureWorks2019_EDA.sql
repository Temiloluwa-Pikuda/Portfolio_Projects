/*
AdventureWorks 2019
Exploratory Data Analysis
Temiloluwa Pikuda
*/

/*Q1
Retrieve information about the products with colour values except null, red, silver/black, white and list price between
£75 and £750. Rename the column StandardCost to Price. Also, sort the results in descending order by list price */

SELECT ProductID, Name, ProductNumber ,Color, StandardCost AS Price, ListPrice, ProductSubcategoryID
FROM Production.Product
WHERE Color <> 'red' AND Color <> 'silver/black' AND Color <> 'white' AND Color IS NOT NULL 
AND ListPrice BETWEEN 75 AND 750
ORDER BY ListPrice DESC

/*Q2
Find all the male employees born between 1962 to 1970 and with hire date greater than 2001 and female employees 
born between 1972 and 1975 and hire date between 2001 and 2002 */

SELECT * 
FROM HumanResources.Employee 
WHERE Gender ='M' AND BirthDate BETWEEN '1962' AND '1970' AND HireDate > '2001'
OR Gender ='F' AND BirthDate BETWEEN '1972' AND '1975' AND HireDate BETWEEN '2001' AND '2002'

/*Q3
Create a list of 10 most expensive products that have a product number beginning with ‘BK’. 
Include only the product ID, Name and colour */

SELECT TOP 10 ProductID, Name, Color
FROM Production.Product
WHERE ProductNumber LIKE 'BK%'
ORDER BY ListPrice DESC

/*Q4
Create a list of all contact persons, where the first 4 characters of the last name are the same as the first four 
characters of the email address. Also, for all contacts whose first name and the last name begin with the same characters,
create a new column called full name combining first name and the last name only. Also provide the length of the new column
full name */

SELECT P.BusinessEntityID, P.FirstName,P.LastName,E.EmailAddress
FROM Person.Person P
JOIN Person.EmailAddress E
ON P.BusinessEntityID = E.BusinessEntityID
WHERE E.EmailAddress LIKE SUBSTRING (LastName, 1, 4) + '%'

SELECT BusinessEntityID, FirstName, LastName, CONCAT(FirstName,' ',LastName) AS FullName,
LEN (CONCAT(FirstName,' ',LastName)) AS FullNameLength
FROM Person.Person
WHERE SUBSTRING(FirstName,1,1) = SUBSTRING(LastName,1,1)

/*Q5
Return all product subcategories that take an average of 3 days or longer to manufacture */

SELECT ProductSubcategoryID
FROM Production.Product
GROUP BY ProductSubcategoryID
HAVING AVG(DaysToManufacture) >= 3

/*Q6
Create a list of product segmentation by defining criteria that places each item in a predefined segment as follows. 
If price gets less than £200 then low value. If price is between £201 and £750 then mid value. 
If between £750 and £1250 then mid to high value else higher value. Filter the results only for black, 
silver and red color products */

SELECT ProductID, Name, Color, ListPrice, 
(CASE WHEN ListPrice < 200 THEN 'low value'
	 WHEN ListPrice BETWEEN 201 AND 750 THEN 'mid value'
	 WHEN ListPrice BETWEEN 751 AND 1250 THEN 'mid to high value'
	 ELSE 'higher value'
	 END) AS ProductSegmentation
FROM Production.Product
WHERE Color = 'black' OR Color = 'silver' OR Color = 'red'

/*Q7
How many Distinct Job title is present in the Employee table? */

SELECT COUNT (DISTINCT(JobTitle))
FROM HumanResources.Employee

/*Q8
Use employee table and calculate the ages of each employee at the time of hiring */

SELECT E.BusinessEntityID, P.FirstName, P.LastName, DATEDIFF (year, E.BirthDate, E.HireDate) AS AgeAtTimeOfHire
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID 

/*Q9
How many employees will be due a long service award in the next 5 years, if long service is 20 years? */

SELECT E.BusinessEntityID, P.FirstName, P.LastName, DATEDIFF (year, E.HireDate, CAST (GETDATE() AS date)) AS YearsInService
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID 
WHERE DATEDIFF (year, HireDate, CAST (GETDATE() AS date)) >= 15

/*Q10
How many more years does each employee have to work before reaching sentiment, if sentiment age is 65? */

SELECT E.BusinessEntityID, P.FirstName, P.LastName, DATEDIFF (year, E.BirthDate, CAST (GETDATE() AS date)) AS Age, 
65 - DATEDIFF (year, E.BirthDate, CAST (GETDATE() AS date)) AS YearsTillSentiment
FROM HumanResources.Employee E
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID 

/*Q11
Implement new price policy on the product table base on the colour of the item.
If white increase price by 8%, If yellow reduce price by 7.5%, If black increase price by 17.2%. 
If multi, silver, silver/black or blue take the square root of the price and double the value. 
Column should be called Newprice. For each item, also calculate commission as 37.5% of newly computed list price */

SELECT ProductID, Name, Color, ListPrice, (CASE WHEN Color = 'white' THEN (ListPrice * 1.08)
					 WHEN Color = 'yellow' THEN (ListPrice * 0.925)
					 WHEN Color = 'black' THEN (ListPrice * 1.172)
					 ELSE 2 * SQRT(ListPrice)
					 END) AS NewPrice, 0.375 * (CASE WHEN Color = 'white' THEN (ListPrice * 1.08)
					 WHEN Color = 'yellow' THEN (ListPrice * 0.925)
					 WHEN Color = 'black' THEN (ListPrice * 1.172)
					 ELSE 2 * SQRT(ListPrice)
					 END) AS Commission
FROM Production.Product

/*Q12
Print the information about all the Sales.Person and their sales quota. 
For every Sales person you should provide their FirstName, LastName, HireDate, SickLeaveHours and Region where they work */

SELECT SP.BusinessEntityID, P.FirstName, P.LastName, E.HireDate, E.SickLeaveHours, ST.CountryRegionCode, SP.SalesQuota
FROM Sales.SalesPerson SP
JOIN HumanResources.Employee E
ON E.BusinessEntityID = SP.BusinessEntityID
JOIN Sales.SalesTerritory ST
ON ST.TerritoryID = SP.TerritoryID
JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID 
AND P.BusinessEntityID = SP.BusinessEntityID

/*Q13
Using adventure works, write a query to extract the following information.
Product name, Product category name, Product subcategory name, Sales person, Revenue, Month of transaction, 
Quarter of transaction */

CREATE TABLE #TempTable (
							ProductID  int,
							ProductName  nvarchar(50),
							ProductCategoryName nvarchar(50),
							ProductSubcategoryName nvarchar(50),
							MonthOfTransaction nvarchar(50),
							QuarterOfTransaction nchar(1)
							)
INSERT INTO #TempTable
SELECT P.ProductID,P.Name AS ProductName,PC.Name AS ProductCategoryName,PSC.Name AS ProductSubcategoryName,
DATENAME( month,TH.TransactionDate) AS MonthOfTransaction, DATEPART(quarter,TH.TransactionDate) AS QuarterOfTransaction
FROM Production.Product P
JOIN Production.ProductSubcategory PSC
ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
JOIN Production.ProductCategory PC
ON PC.ProductCategoryID = PSC.ProductCategoryID
JOIN Production.TransactionHistory TH
ON P.ProductID = TH.ProductID

SELECT T.ProductName,T.ProductCategoryName,T.ProductSubcategoryName,T.MonthOfTransaction,T.QuarterOfTransaction,
SOH.SalesPersonID,SUM(SOH.TotalDue) AS Revenue
FROM #TempTable T
JOIN Sales.SalesOrderDetail SOD
ON SOD.ProductID = T.ProductID
JOIN Sales.SalesOrderHeader SOH
ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY T.ProductName,T.ProductCategoryName,T.ProductSubcategoryName,T.MonthOfTransaction,
T.QuarterOfTransaction,SOH.SalesPersonID
ORDER BY T.ProductName, T.ProductCategoryName,T.ProductSubcategoryName,SOH.SalesPersonID


/*Q14
Display the information about the details of an order i.e. order number, order date, amount of order, 
which customer gives the order and which salesman works for that customer and how much commission he gets for an order */

SELECT SOH.SalesOrderID, SOH.CustomerID, SOH.SalesPersonID, CAST (SOH.OrderDate AS date) AS OrderDate, 
SOH.TotalDue AS AmountOfOrder,SP.CommissionPct, SP.CommissionPct * SOH.TotalDue AS Commission
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesPerson SP
ON SOH.SalesPersonID = SP.BusinessEntityID

/*Q15
For all the products calculate
-Commission as 14.790% of standard cost,
-Margin, if standard cost is increased or decreased as follows: Black: +22%, Red: -12%, Silver: +15%, Multi: +5%,
White: Two times original cost divided by the square root of cost For other colours, standard cost remains the same*/

SELECT ProductID, Name, Color,StandardCost ,(0.14790*StandardCost) AS Commissioin,
			   (CASE WHEN Color = 'white' THEN ((StandardCost * 2)/SQRT(StandardCost))
					 WHEN Color = 'silver' THEN (StandardCost * 1.15)
					 WHEN Color = 'multi' THEN (StandardCost * 1.05)
					 WHEN Color = 'red' THEN (StandardCost * 0.88)
					 WHEN Color = 'black' THEN (StandardCost * 1.22)
					 ELSE StandardCost
					 END) AS NewStandardCost, ((CASE WHEN Color = 'white' THEN ((StandardCost * 2)/SQRT(StandardCost))
					 WHEN Color = 'silver' THEN (StandardCost * 1.15)
					 WHEN Color = 'multi' THEN (StandardCost * 1.05)
					 WHEN Color = 'red' THEN (StandardCost * 0.88)
					 WHEN Color = 'black' THEN (StandardCost * 1.22)
					 ELSE StandardCost
					 END)-StandardCost)/NULLIF (StandardCost,0) AS Margin
FROM Production.Product
 
/*Q16 
Create a view to find out the top 5 most expensive products for each colour */

CREATE VIEW Top5ExpensiveBlackProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='black'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveBlueProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='blue'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveGreyProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='grey'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveMultiProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='multi'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveRedProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='red'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveSilverProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='silver'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveSilver_BlackProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='silver/black'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveWhiteProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='white'
ORDER BY StandardCost DESC

CREATE VIEW Top5ExpensiveYellowProducts AS
SELECT TOP 5 Name, StandardCost
FROM Production.Product
WHERE Color ='yellow'
ORDER BY StandardCost DESC



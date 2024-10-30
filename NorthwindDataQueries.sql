
--1- overview Report :
--Net Sales
go
CREATE VIEW NetSales AS
SELECT SUM(UnitPrice * Quantity * (1 - Discount)) AS NetSales
FROM [Order Details];
go
SELECT * FROM NetSales

--Count of Customers
CREATE VIEW CountofCustomers AS
SELECT COUNT(DISTINCT CustomerID) AS CustomerCount
FROM Customers;
go
SELECT * FROM CountofCustomers
--Count of Orders
CREATE VIEW CountofOrders AS
SELECT COUNT(OrderID) AS OrderCount
FROM Orders;
go
SELECT * FROM CountofOrders
--Average Days to Ship the Order
CREATE VIEW AverageDaystoShiptheOrder AS
SELECT AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS AvgDaysToShip
FROM Orders

--Chart
go
CREATE VIEW Net_Sales_Over_Time_Months AS
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    [Order Details] od
JOIN 
    Orders o ON od.OrderID = o.OrderID
GROUP BY 
    YEAR(OrderDate), MONTH(OrderDate);

go
--Top 5 Customers by Net Sales
CREATE VIEW Top5CustomersByNetSales AS
SELECT TOP 5 
    c.CustomerID,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    c.CustomerID, c.CompanyName
ORDER BY 
    NetSales DESC;

SELECT * FROM Top5CustomersByNetSales
go
--Top 5 Products by Net Sales
go
CREATE VIEW ProductsbyNetSales AS
SELECT TOP 5
    p.ProductID, 
    p.ProductName, 
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Products p
JOIN 
    [Order Details] od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    NetSales DESC

SELECT * FROM ProductsbyNetSales
go
--Net Sales by Countries
CREATE VIEW NetSalesByCountries AS
SELECT TOP 100 PERCENT
    o.ShipCountry,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    o.ShipCountry
ORDER BY 
    NetSales DESC;

SELECT * FROM NetSalesByCountries
go


-----------------------------------------------------------------------------------
--2-Revenue Report:

--1 Net Profit
CREATE VIEW NetProfitView AS
SELECT SUM(Profit) AS NetProfit
FROM OrderProfit;



--2. Total Discounts
CREATE VIEW TotalDiscountsView AS
SELECT SUM(Discount * UnitPrice * Quantity) AS TotalDiscounts
FROM [Order Details];

--3. Shipping Cost
CREATE VIEW ShippingCostView AS
SELECT SUM(Freight) AS ShippingCost
FROM Orders;

--Charts

--Top 5 Countries by Net Sales
CREATE VIEW Top5CountriesByNetSalesView AS
SELECT TOP 5 
    o.ShipCountry, 
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    o.ShipCountry
ORDER BY 
    NetSales DESC;


--Net Sales, Profits, and Discounts Over Time

CREATE VIEW NetSalesProfitsDiscountsOverTimeView AS
SELECT 
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales,
    SUM(op.Profit) AS Profits,
    SUM(od.UnitPrice * od.Quantity * od.Discount) AS TotalDiscounts
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    OrderProfit op ON o.OrderID = op.OrderID AND od.ProductID = op.ProductID
GROUP BY 
    YEAR(o.OrderDate), 
    MONTH(o.OrderDate);

--Top 5 Countries by Discounts
CREATE VIEW Top5CountriesByDiscountsView AS
SELECT TOP 5 
    o.ShipCountry, 
    SUM(od.UnitPrice * od.Quantity * od.Discount) AS TotalDiscounts
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    o.ShipCountry
ORDER BY 
    TotalDiscounts DESC;

--YOY   for each countries 
DROP VIEW IF EXISTS YoYAnalysisByCountryView;
CREATE VIEW YoYAnalysisByCountryView AS
SELECT 
    o.ShipCountry,
    YEAR(o.OrderDate) AS OrderYear, 
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales,
    SUM(op.Profit) AS NetProfit
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    OrderProfit op ON o.OrderID = op.OrderID AND od.ProductID = op.ProductID
GROUP BY 
    o.ShipCountry, 
    YEAR(o.OrderDate);


---------------------------------------------------------------------------------
--3  Customers Report :
-- 1 avg net sales  per customer 
CREATE VIEW AvgNetSalesPerCustomerView AS
WITH CustomerNetSales AS (
    SELECT 
        c.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
    FROM Orders AS o
    JOIN [Order Details] AS od ON o.OrderID = od.OrderID
    JOIN Customers AS c ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerID
)
SELECT 
    AVG(NetSales) AS AvgNetSalesPerCustomer
FROM CustomerNetSales;

--2. Average Profit per Customer

CREATE VIEW AvgProfitPerCustomerView AS
WITH CustomerProfits AS (
    SELECT 
        c.CustomerID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount) * 0.07) AS Profit
    FROM Orders AS o
    JOIN [Order Details] AS od ON o.OrderID = od.OrderID
    JOIN Customers AS c ON o.CustomerID = c.CustomerID
    WHERE o.Freight IS NOT NULL
    GROUP BY c.CustomerID
)
SELECT 
    AVG(Profit) AS AvgProfitPerCustomer
FROM CustomerProfits;


--3. Average Shipping Cost per Customer
CREATE VIEW AvgShippingCostPerCustomerView AS
WITH CustomerShippingCosts AS (
    SELECT 
        c.CustomerID,
        SUM(o.Freight) AS ShippingCost
    FROM Orders AS o
    JOIN Customers AS c ON o.CustomerID = c.CustomerID
    WHERE o.Freight IS NOT NULL
    GROUP BY c.CustomerID
)
SELECT 
    AVG(ShippingCost) AS AvgShippingCostPerCustomer
FROM CustomerShippingCosts;

--Chart
--Count of Customers Over Time
CREATE VIEW CustomerCountOverTimeView AS
SELECT 
    YEAR(o.OrderDate) AS OrderYear,
    COUNT(DISTINCT o.CustomerID) AS CustomerCount
FROM 
    Orders o
GROUP BY 
    YEAR(o.OrderDate)

--Count of Customers by Countries
CREATE VIEW CustomerCountByCountryView AS
SELECT 
    o.ShipCountry,
    COUNT(DISTINCT o.CustomerID) AS CustomerCount
FROM 
    Orders o
GROUP BY 
    o.ShipCountry;

--Count of New Customers and Repeated Customers
CREATE VIEW CustomerCountsView AS
WITH CustomerOrders AS (
    SELECT 
        o.CustomerID,
        MIN(YEAR(o.OrderDate)) AS FirstPurchaseYear,
        MAX(YEAR(o.OrderDate)) AS LastPurchaseYear
    FROM 
        Orders o
    GROUP BY 
        o.CustomerID
)
SELECT
    SUM(CASE WHEN FirstPurchaseYear = 1998 THEN 1 ELSE 0 END) AS NewCustomersCount,
    SUM(CASE WHEN FirstPurchaseYear < 1998 AND LastPurchaseYear = 1998 THEN 1 ELSE 0 END) AS RepeatedCustomersCount
FROM 
    CustomerOrders;

SELECT * 
FROM Orders 
WHERE OrderDate > '1997-12-31';

-----------------------------------------------------------------
--4  Products report : 
--1. Net Profit per Order
CREATE VIEW NetProfitPerOrderView AS
SELECT 
    OrderID,
    SUM(Profit) AS NetProfit
FROM 
    OrderProfit
GROUP BY 
    OrderID;

--Profit per Order
CREATE VIEW ProfitperOrder AS
SELECT 
    AVG(NetProfit) AS AvgNetProfitPerOrder
FROM (
    SELECT 
        OrderID,
        SUM(Profit) AS NetProfit
    FROM 
        OrderProfit
    GROUP BY 
        OrderID
) AS OrderProfits;


--2. Shipping Cost per Order
CREATE VIEW ShippingCostPerOrderView AS
SELECT 
    OrderID,
    Freight AS ShippingCost
FROM 
    Orders;
--avg Shipping Cost per Order
CREATE VIEW AvgShippingCostperOrder AS
SELECT 
    AVG(Freight) AS AvgShippingCostPerOrder
FROM 
    Orders;


--3. Net Sales per Order
CREATE VIEW NetSalesPerOrderView AS
SELECT 
    OrderID,
    SUM(UnitPrice * Quantity * (1 - Discount)) AS NetSales
FROM 
    [Order Details]
GROUP BY 
    OrderID;

-- NetSalesPerOrder
CREATE VIEW AvgNetSalesPerOrderView AS
SELECT 
    AVG(NetSales) AS AvgNetSalesPerOrder
FROM (
    SELECT 
        OrderID,
        SUM(UnitPrice * Quantity * (1 - Discount)) AS NetSales
    FROM 
        [Order Details]
    GROUP BY 
        OrderID
) AS OrderNetSales;


CREATE VIEW OrderSummaryView AS
SELECT 
    np.OrderID,
    np.NetProfit,
    sc.ShippingCost,
    ns.NetSales
FROM 
    NetProfitPerOrderView np
JOIN 
    ShippingCostPerOrderView sc ON np.OrderID = sc.OrderID
JOIN 
    NetSalesPerOrderView ns ON np.OrderID = ns.OrderID;

-- Query to select from the combined view
SELECT * FROM OrderSummaryView;


--4 Count of Products
CREATE VIEW ProductCountView AS
SELECT COUNT(*) AS ProductCount
FROM Products;

--5 Count of Categories
CREATE VIEW CategoryCountView AS
SELECT COUNT(*) AS CategoryCount
FROM Categories;


--6 Percentage of Discontinued Products and Products that are Selling
CREATE VIEW ProductStatusPercentageView AS
WITH ProductStatus AS (
    SELECT 
        ProductID,
        CASE 
            WHEN Discontinued = 1 THEN 'Discontinued'
            ELSE 'Selling'
        END AS Status
    FROM Products
),
ProductCounts AS (
    SELECT 
        Status,
        COUNT(*) AS Count
    FROM ProductStatus
    GROUP BY Status
),
TotalProducts AS (
    SELECT SUM(Count) AS TotalCount
    FROM ProductCounts
)
SELECT 
    p.Status,
    p.Count,
    (p.Count * 100.0 / t.TotalCount) AS Percentage
FROM ProductCounts AS p
CROSS JOIN TotalProducts AS t;

--charts
--Top 5 Products by Net Sales
CREATE VIEW Top5ProductsByNetSalesView AS
SELECT TOP 5 
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    [Order Details] od
JOIN 
    Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    NetSales DESC;


--Net Sales and Profits by Categories
CREATE VIEW NetSalesAndProfitsByCategoriesView AS
SELECT
    c.CategoryName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales,
    SUM(op.Profit) AS TotalProfit
FROM 
    [Order Details] od
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
JOIN 
    OrderProfit op ON od.OrderID = op.OrderID AND od.ProductID = op.ProductID
GROUP BY 
    c.CategoryName

-------------------------------------------------------------------------------------

----ProductPerformanceMatrix
--Net Sales (LY):
CREATE VIEW NetSalesLYByProduct AS
SELECT 
    p.ProductName AS Product,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSalesLY
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) <= 5
GROUP BY 
    p.ProductName;
select SUM(NetSales) from NetSalesByProduct
--Net Sales:
CREATE VIEW NetSalesByProduct AS
SELECT 
    p.ProductName AS Product,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    p.ProductName;

--Net Sales YoY%:
CREATE VIEW NetSalesYoYByProduct AS
SELECT 
    ns.Product,
    (ns.NetSales - nsl.NetSalesLY) / nsl.NetSalesLY * 100 AS NetSalesYoYPercent
FROM 
    NetSalesByProduct ns
JOIN 
    NetSalesLYByProduct nsl ON ns.Product = nsl.Product;

--NS% (Net Sales Percentage):
CREATE VIEW NetSalesPercentageByProduct AS
SELECT 
    ns.Product,
    ns.NetSales / (SELECT SUM(NetSales) FROM NetSalesByProduct) * 100 AS NetSalesPercentage
FROM 
    NetSalesByProduct ns;

--Net Sales/Order

CREATE VIEW NetSalesPerOrderByProduct AS

SELECT 
    p.ProductName AS Product,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) / COUNT(DISTINCT o.OrderID) AS NetSalesPerOrder
FROM 
    [Order Details] od
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Orders o ON od.OrderID = o.OrderID
WHERE
	YEAR(o.OrderDate)= 1998
GROUP BY 
    p.ProductName;


--Unit Price
CREATE VIEW UnitPriceByProduct AS
SELECT 
    p.ProductName AS Product,
    p.UnitPrice
FROM 
    Products p;

--Discount %:
CREATE VIEW DiscountPercentageByProduct AS
SELECT 
    p.ProductName AS Product,
    sum(od.Discount) AS DiscountPercentage
FROM 
    [Order Details] od
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Orders o ON od.OrderID = o.OrderID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    p.ProductName;
DROP VIEW IF EXISTS ProductPerformanceMatrix;
--ProductPerformanceMatrix
CREATE VIEW ProductPerformanceMatrix AS
SELECT 
    p.ProductName AS Product,
    COALESCE(nsl.NetSalesLY, 0) AS NetSalesLY,
    COALESCE(ns.NetSales, 0) AS NetSales,
    COALESCE(FORMAT(nsy.NetSalesYoYPercent, 'N2') + '%', '0.00%') AS NetSalesYoYPercent, 
    COALESCE(FORMAT(nsp.NetSalesPercentage, 'N2') + '%', '0.00%') AS NetSalesPercentage, 
    COALESCE(nspo.NetSalesPerOrder, 0) AS NetSalesPerOrder,
    COALESCE(up.UnitPrice, 0) AS UnitPrice,
    COALESCE(FORMAT(dp.DiscountPercentage, 'N2') + '%', '0.00%') AS DiscountPercentage 
FROM 
    Products p
LEFT JOIN 
    NetSalesLYByProduct nsl ON p.ProductName = nsl.Product
LEFT JOIN 
    NetSalesByProduct ns ON p.ProductName = ns.Product
LEFT JOIN  
    NetSalesYoYByProduct nsy ON p.ProductName = nsy.Product
LEFT JOIN 
    NetSalesPercentageByProduct nsp ON p.ProductName = nsp.Product
LEFT JOIN 
    NetSalesPerOrderByProduct nspo ON p.ProductName = nspo.Product
LEFT JOIN 
    UnitPriceByProduct up ON p.ProductName = up.Product
LEFT JOIN 
    DiscountPercentageByProduct dp ON p.ProductName = dp.Product
WHERE 
    ns.NetSales IS NOT NULL OR nsl.NetSalesLY IS NOT NULL;

----------------------------------------------------------------------------------
---- Category Performance Matrix 
--Net Sales (LY) by Category:
CREATE VIEW NetSalesLYByCategory AS
SELECT 
    c.CategoryName AS Category,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSalesLY
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) <= 5
GROUP BY 
    c.CategoryName;


--Net Sales by Category:
CREATE VIEW NetSalesByCategory AS
SELECT 
    c.CategoryName AS Category,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    c.CategoryName;

--Net Profit by Category:
CREATE VIEW NetProfitByCategory AS
SELECT 
    c.CategoryName AS Category,
    SUM((od.UnitPrice * od.Quantity * (1 - od.Discount)) * 0.07) AS NetProfit
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    YEAR(o.OrderDate) = 1998 AND MONTH(o.OrderDate) <= 5
GROUP BY 
    c.CategoryName;


--NS% (Net Sales Percentage) by Category:
CREATE VIEW NetSalesPercentageByCategory AS
SELECT 
    nc.Category,
    nc.NetSales / (SELECT SUM(NetSales) FROM NetSalesByCategory) * 100 AS NetSalesPercentage
FROM 
    NetSalesByCategory nc;

--Category Performance Matrix 
CREATE VIEW CategoryPerformanceMatrix AS
SELECT 
    ns.Category,
    FORMAT(nsl.NetSalesLY, 'C', 'en-US') AS NetSalesLY,
    FORMAT(ns.NetSales, 'C', 'en-US') AS NetSales,
    FORMAT(np.NetProfit, 'C', 'en-US') AS NetProfit,
	FORMAT(nsp.NetSalesPercentage,'0.0', 'en-US') + '%' AS NetSalesPercentage
FROM 
    NetSalesByCategory ns
JOIN 
    NetSalesLYByCategory nsl ON ns.Category = nsl.Category
JOIN 
    NetSalesPercentageByCategory nsp ON ns.Category = nsp.Category
JOIN 
    NetProfitByCategory np ON ns.Category = np.Category

------------------------------------------------------------------------------------
--5 Employee Report 
--1 Net Sales per Employee Total
CREATE VIEW NetSalesPerEmployeeView AS
SELECT 
    e.EmployeeID,
    e.FirstName + ', ' + e.LastName AS EmployeeName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName;

--Average
CREATE VIEW AvgNetSalesPerEmployeeView AS
WITH EmployeeSales AS (
    SELECT 
        e.EmployeeID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
    FROM 
        Employees e
    JOIN 
        Orders o ON e.EmployeeID = o.EmployeeID
    JOIN 
        [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY 
        e.EmployeeID
)
SELECT 
    AVG(NetSales) AS AvgNetSalesPerEmployee
FROM 
    EmployeeSales;


--2 Count of Orders per Employee Total and 
CREATE VIEW OrderCountPerEmployeeView AS
SELECT 
    e.EmployeeID,
    e.FirstName + ', ' + e.LastName AS EmployeeName,
    COUNT(o.OrderID) AS OrderCount
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName;


--Average
CREATE VIEW AvgOrdersPerEmployeeView AS
WITH EmployeeOrderCounts AS (
    SELECT 
        e.EmployeeID,
        COUNT(o.OrderID) AS OrderCount
    FROM 
        Employees e
    JOIN 
        Orders o ON e.EmployeeID = o.EmployeeID
    GROUP BY 
        e.EmployeeID
)
SELECT 
    AVG(OrderCount) AS AvgOrdersPerEmployee
FROM 
    EmployeeOrderCounts;

--3 Count of Employees
CREATE VIEW TotalEmployeesView AS
SELECT 
    COUNT(*) AS TotalEmployees
FROM 
    Employees;

--4  Count of Supervisors
CREATE VIEW TotalSupervisorsView AS
SELECT 
    COUNT(DISTINCT e.EmployeeID) AS TotalSupervisors
FROM 
    Employees e
JOIN 
    Employees sub ON e.EmployeeID = sub.ReportsTo;

select * from Employees
--charts
--Monthly Net Sales by Employees
CREATE VIEW MonthlyNetSalesByEmployeesView AS
SELECT 
    e.EmployeeID,
    e.FirstName + ', ' + e.LastName AS EmployeeName,
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName, YEAR(o.OrderDate), MONTH(o.OrderDate)

--Count of Orders and Net Sales by Employees (Employee Performance)
CREATE VIEW EmployeePerformanceView AS
SELECT 
    e.EmployeeID,
    e.FirstName + ', ' + e.LastName AS EmployeeName,
    COUNT(o.OrderID) AS OrderCount,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName


--Delayed Orders and On-Time Orders by Employees
CREATE VIEW DelayedAndOnTimeOrdersByEmployeeView AS
SELECT 
    e.EmployeeID,
    e.LastName + ', ' + e.FirstName AS EmployeeName,
    SUM(CASE WHEN o.ShippedDate <= o.RequiredDate THEN 1 ELSE 0 END) AS OnTimeOrders,
    SUM(CASE WHEN o.ShippedDate > o.RequiredDate THEN 1 ELSE 0 END) AS DelayedOrders
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName


------------------------------------------------------------------------------------
--6	Shippers Report 
--1 Shipping Cost by Order
CREATE VIEW ShippingCostByOrderView AS
SELECT 
    OrderID,
    Freight AS ShippingCost
FROM 
    Orders;

--2 Average Days to Ship
CREATE VIEW AvgDaysToShipView AS
SELECT 
    AVG(DATEDIFF(day, OrderDate, ShippedDate)) AS AvgDaysToShip
FROM 
    Orders
WHERE 
    ShippedDate IS NOT NULL;

--charts
--Shipping Cost by Shippers
CREATE VIEW ShippingCostByShippersView AS
SELECT 
    s.CompanyName,
    SUM(o.Freight) AS TotalShippingCost
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
GROUP BY 
    s.CompanyName;

--On-Time vs. Delayed Orders (Delivery Performance)
CREATE VIEW DeliveryPerformanceView AS
SELECT 
    SUM(CASE WHEN DATEDIFF(day, o.RequiredDate, o.ShippedDate) <= 0 THEN 1 ELSE 0 END) AS OnTimeOrders,
    SUM(CASE WHEN DATEDIFF(day, o.RequiredDate, o.ShippedDate) > 0 THEN 1 ELSE 0 END) AS DelayedOrders
FROM 
    Orders o
WHERE 
    o.ShippedDate IS NOT NULL;

--3 Shipping Cost by Countries and Shippers
CREATE VIEW ShippingCostByCountryAndShipperView AS
SELECT 
    o.ShipCountry,
    s.CompanyName,
    SUM(o.Freight) AS TotalShippingCost
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
GROUP BY 
    o.ShipCountry, 
    s.CompanyName;

------------------------------------------------------------------------------------------------
------ShipperPerformanceMatrix

--NetSalesByShipper

CREATE VIEW NetSalesByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSales
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    s.CompanyName;

--NetSalesByShipperLY

CREATE VIEW NetSalesByShipperLY AS
SELECT 
    s.CompanyName AS Shipper,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS NetSalesLY
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) <= 5
GROUP BY 
    s.CompanyName;

--ShippingCostByShipper

CREATE VIEW ShippingCostByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    SUM(o.Freight) AS ShippingCost
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    s.CompanyName;

--ShippingCostByShipperLY
drop view ShippingCostByShipperLY
CREATE VIEW ShippingCostByShipperLY AS
SELECT 
    s.CompanyName AS Shipper,
    SUM(o.Freight) AS ShippingCostLY
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) <= 5
GROUP BY 
    s.CompanyName;

--OnTimeOrdersByShipper

CREATE VIEW OnTimeOrdersByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    CONCAT(
        FORMAT(COUNT(CASE WHEN o.ShippedDate <= o.RequiredDate THEN 1 END) * 100.0 / COUNT(*), 'N2'), 
        '%'
    ) AS OnTimeOrdersPercent
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    s.CompanyName;
select * from Orders
--AvgDaysToShipByShipper

CREATE VIEW AvgDaysToShipByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    AVG(DATEDIFF(day, o.OrderDate, o.ShippedDate)) AS AvgDaysToShip
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    s.CompanyName;

--NumberOfOrdersByShipper

CREATE VIEW NumberOfOrdersByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    COUNT(*) AS NumberOfOrders
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998
GROUP BY 
    s.CompanyName;

--AvgShippingCostPerOrderByShipper

CREATE VIEW AvgShippingCostPerOrderByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    AVG(o.Freight) AS AvgShippingCostPerOrder
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
WHERE 
    YEAR(o.OrderDate) = 1998 
GROUP BY 
    s.CompanyName;

--AvgShippingCostByShipper

CREATE VIEW AvgShippingCostByShipper AS
SELECT 
    s.CompanyName AS Shipper,
    AVG(o.Freight) AS AvgShippingCost
FROM 
    Orders o
JOIN 
    Shippers s ON o.ShipVia = s.ShipperID
GROUP BY 
    s.CompanyName;


drop view ShipperPerformanceMatrix


CREATE VIEW ShipperPerformanceMatrix AS
SELECT 
    ns.Shipper,
    ns.NetSales AS NetSalesThisYear,
    ly.NetSalesLY,
    sc.ShippingCost,
    sly.ShippingCostLY,
    ot.OnTimeOrdersPercent,
    ad.AvgDaysToShip,
    acs.AvgShippingCost,
    noo.NumberOfOrders,
    aco.AvgShippingCostPerOrder
FROM 
    NetSalesByShipper ns
JOIN 
    NetSalesByShipperLY ly ON ns.Shipper = ly.Shipper
JOIN
    OnTimeOrdersByShipper ot ON ns.Shipper = ot.Shipper
JOIN 
    ShippingCostByShipper sc ON ns.Shipper = sc.Shipper
JOIN 
    AvgDaysToShipByShipper ad ON ns.Shipper = ad.Shipper
JOIN 
    NumberOfOrdersByShipper noo ON ns.Shipper = noo.Shipper
JOIN
    ShippingCostByShipperLY sly ON ns.Shipper = sly.Shipper
JOIN
    AvgShippingCostPerOrderByShipper aco ON ns.Shipper = aco.Shipper
JOIN
    AvgShippingCostByShipper acs ON ns.Shipper = acs.Shipper;



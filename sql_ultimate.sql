-- Create db
CREATE DATABASE online_store;
-- Select db
USE online_store;

-- Run SQL Script to load TABLE definitions
source load_tables_def.sql
-- Verify the Tables
SHOW TABLES;
-- Run SQL Script to load TABLE sample data
source load_tables_data.sql

-- Verify if data is loaded
SELECT * FROM Products LIMIT 2;
SELECT * FROM Customers LIMIT 2;
SELECT * FROM Orders LIMIT 2;
SELECT * FROM OrderItems LIMIT 2;
SELECT * FROM Payments LIMIT 2;
SELECT * FROM Reviews LIMIT 2;
SELECT * FROM Categories LIMIT 2;

-- Delete Table
DROP TABLE Products;
-- Truncate Table, remove all data from a table while keeping the table structure 
TRUNCATE TABLE Customers;

-- Delete Database, permanently removes the entire database and all its tables and data
DROP DATABASE online_store;
-- To create and delete a database in one step, will drop the existing database if it exists and then create a new one.
CREATE DATABASE IF NOT EXISTS online_store;

-- Truncate all Tables with foreign keys
-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;
-- List of tables to be truncated
TRUNCATE TABLE Products;
TRUNCATE TABLE Customers;
TRUNCATE TABLE Orders;
TRUNCATE TABLE OrderItems;
TRUNCATE TABLE Payments;
TRUNCATE TABLE Reviews;
TRUNCATE TABLE Categories;
-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- TABLES : Products, Customers, Orders, OrderItems, Payments, Reviews, Categories 

-- ======= DQL: Data Query Language
-- SELECT
SELECT * FROM Products;         -- all
SELECT FirstName, LastName, Username FROM Customers;  -- selected fields
-- distinct 
SELECT DISTINCT FirstName FROM Customers;
--
SELECT DISTINCT rating, rental_duration FROM film;
-- distinct - accros all columns
SELECT DISTINCT PaymentDate, PaymentMethod FROM Payments;
-- limit 
SELECT * FROM Orders LIMIT 5;
-- count
SELECT COUNT(*) FROM Orders;
SELECT COUNT( DISTINCT PaymentMethod ) FROM Payments;
-- order by 
SELECT * FROM Payments ORDER BY PaymentAmount DESC;   -- ASC as default
-- multiple order by
SELECT PaymentDate, PaymentAmount, PaymentMethod FROM Payments ORDER BY PaymentDate DESC, PaymentAmount ASC;
-- order by column number
SELECT PaymentDate, PaymentAmount, PaymentMethod FROM Payments ORDER BY 1, 2 DESC;

--  where 
SELECT COUNT(*) FROM Orders WHERE OrderStatus = "Shipped";
SELECT OrderID, OrderDate FROM Orders WHERE TotalAmount > 100;

-- operators AND /OR 
SELECT COUNT(OrderID) from OrderItems WHERE ( ItemPrice >= 11 AND Quantity > 1 ) OR ProductID = 26;
-- BETWEEN
SELECT COUNT(*) FROM Orders WHERE OrderDate BETWEEN '2022-11-28' AND '2023-02-15 23:00'; 
-- data time is default 0:00.
-- IN 
SELECT * FROM Orders WHERE CustomerId IN (12,25,50) AND OrderStatus NOT IN ("Pending", "Shipped" );

-- filtering with LIKE and wildcards _(and and %(any), NOTE : case sensitive
SELECT FirstName, LastName FROM Customers WHERE FirstName LIKE '_a%';
SELECT FirstName, LastName FROM Customers WHERE FirstName LIKE '___';  -- 3 letters

/* Aggregate Functions 
Count, Avg, Min, Max, Sum */
SELECT COUNT(*) AS ReviewCount FROM Reviews;
SELECT SUM(TotalAmount) AS TotalOrderAmount FROM Orders;
SELECT AVG(Price) AS AveragePrice FROM Products;
SELECT MIN(Price) AS MinPrice, MAX(Price) AS MaxPrice FROM Products;

-- GROUP BY - each colum shall be either in agg function or in group by.
SELECT CustomerID, SUM(TotalAmount) AS TotalSpent FROM Orders GROUP BY CustomerID;
-- GROUP BY multiple columns
SELECT ProductID, ItemPrice, SUM(Quantity) FROM OrderItems
GROUP BY ProductID, ItemPrice ORDER BY 1;

-- HAVING  - use to filter on agg data
SELECT ProductID, COUNT(*), SUM(Quantity) FROM OrderItems GROUP BY ProductID HAVING COUNT(*) < 29 ;

-- ===============================
-- FOLLOWING is SQL in POSTGRESQL

-- UNION - combine rows 
-- columns must be the same size and type.
SELECT first_name FROM actor
UNION ALL			-- ALL do not remove dublicates 
SELECT first_name FROM customer
ORDER BY first_name;

-- multiple unions
SELECT NULL, staff_id, SUM(amount)
FROM payment GROUP BY staff_id
UNION 
SELECT TO_CHAR(payment_date,'Month'), NULL, SUM(amount)
FROM payment GROUP BY 1
UNION
SELECT TO_CHAR(payment_date,'Month'), staff_id, SUM(amount)
FROM payment GROUP BY 1, 2;

-- =========================================
-- CONDITIONALS   CASE - WHEN - THEN - ELSE 

SELECT 
CASE
	WHEN rating IN ('PG','PG-13') OR length > 210 THEN 'Tier 1'
	WHEN description LIKE '%Drama%' AND length > 90 THEN 'Tier 2'
	WHEN description LIKE '%Drama%' THEN ' Tier 3'
ELSE 'No data'
END 
FROM film
-- 
SELECT 
COUNT(*) as flights,
CASE
WHEN EXTRACT(month from scheduled_departure) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT (month from scheduled_departure) <= 5 THEN 'Spring'
WHEN EXTRACT (month from scheduled_departure) <= 8 THEN 'Summer'
ELSE 'Fall' 
END as season
FROM flights
GROUP BY season
-- count using CASE
SELECT
rating,
SUM (CASE 
	WHEN 'rating' IN ('PG','G') THEN 1
	ELSE 0 
	END )
FROM film

-- =============================================
-- FUNCTIONS 
-- https://www.techonthenet.com/postgresql/functions/index_alpha.php
-- https://www.techonthenet.com/mysql/functions/index.php

-- DATE function
SELECT *, DATE(payment_date) FROM payment WHERE  DATE(payment_date) IN ('2020-04-28','2020-04-29','2020-04-30');
-- UPPER & LOWER, LENGTH
SELECT email, UPPER(email), LOWER(email), LENGTH(email) FROM customer;
-- LEFT & RIGHT
SELECT first_name, LEFT(first_name,2), RIGHT(first_name,2), email, RIGHT (email,4),LEFT( RIGHT(email,4),1) as dot
FROM customer;
-- CONCATENATE
SELECT  LEFT(first_name,1) || '.' || LEFT(last_name,1) AS Inicials, first_name, last_name FROM customer;
-- POSITION
SELECT 
LEFT (email, POSITION('@'IN email) -1 ),
POSITION('@'IN email) 
FROM customer
-- SUBSTRING (column FOR number) or use Position
SELECT email, SUBSTRING( email FROM POSITION('.' in email)+1 FOR 3  ) FROM customer;
-- EXTRACT - parts od timestamp
SELECT EXTRACT (day from rental_date), count(*) FROM rental GROUP BY 1 ORDER BY 2 ;
-- TO_CHAR
-- https://www.postgresqltutorial.com/postgresql-string-functions/postgresql-to_char/
SELECT *, EXTRACT(month from payment_date), TO_CHAR(payment_date, 'YYYY-MM') FROM payment;
-- COALESCE  - if null then deafult value - both must be the same datatype
SELECT
COALESCE(actual_departure - scheduled_departure, '00:00') 
FROM flights
-- CAST - change data type  CAST (value AS datatype) - VARCHAR/DATE
SELECT
COALESCE( CAST (actual_departure - scheduled_departure AS VARCHAR), 'not arrived'),
LENGTH ( CAST( actual_departure AS VARCHAR ) )
FROM flights
-- REPLACE text with text
SELECT
REPLACE(passanger_id, ' ', ''),
CAST( REPLACE(passanger_id, ' ', '') AS INT)
FROM tickets

-- ==============================
-- JOINS 
-- https://learnsql.com/blog/sql-join-cheat-sheet/ 

-- inner join ( intesection)
SELECT * FROM TableA AS A
INNER JOIN TableB AS B
ON A.common_id = B.common_id;
 
-- left join ( all left with right intersaction )
-- right join is oposite operation, or change order of tabls
SELECT fare_conditions, COUNT(*)
FROM boarding_passed b
LEFT JOIN seats s ON b.seat_no = s.seat_no
GROUP BY fare_conditions;

SELECT passenger_name,SUM(total_amount) FROM tickets t
RIGHT JOIN bookings b ON t.book_ref=b.book_ref
GROUP BY passenger_name
ORDER BY SUM(total_amount) DESC

-- multiple joins
SELECT first_name, last_name, title, COUNT(*)
FROM customer cu
INNER JOIN rental re
ON cu.customer_id = re.customer_id
LEFT JOIN inventory inv
ON inv.inventory_id=re.inventory_id
RIGHT JOIN film fi
ON fi.film_id = inv.film_id
WHERE first_name='GEORGE' and last_name='LINTON'
GROUP BY title, first_name, last_name
ORDER BY 4 DESC

-- SELF COIN
SELECT
em.employee_id,em.name,
mn.name
FROM employee em 
LEFT JOIN employee mn ON em.manager_id = mn.employee_id

-- CROSS JOIN = CARTESIAN PRODUT = all posible combination of rows, not values 
SELECT s.staff_id, st.store_id, s.staff_id * st.store_id
FROM staff s CROSS JOIN store st;

-- ==========================================
-- VIEW
-- a virtual table that is based on the result of a SELECT query, 
-- stores the query logic only, not data, so query run every time when VIEW called
-- encapsulate complex SQL queries into a reusable and simplified table-like object

-- Create a view to show high-value orders for business customers
CREATE VIEW HighOrderCustomers AS
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(o.OrderID) AS OrderCount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(o.OrderID) > 3;

-- Query the view
SELECT * FROM HighOrderCustomers;

-- Create a view to show orders that are pending or have a total over a threshold
CREATE VIEW OrderSummary AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    c.CustomerName,
    CASE
        WHEN o.OrderStatus = 'Pending' THEN 'Pending'
        WHEN o.TotalAmount >= 1000 THEN 'High Value'
        ELSE 'Regular'
    END AS OrderType
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE
    o.OrderStatus = 'Pending'
    OR (o.TotalAmount >= 1000 AND c.CustomerType = 'Business');

SELECT * FROM OrderSummary;

-- MATERIALIZED VIEW 
-- materialized view is a database object that contains the results of a query and is physically stored on disk. 
-- updated periodically (or on-demand) to reflect changes in the underlying data. 

-- Create a materialized view to store total sales by product category and region
CREATE MATERIALIZED VIEW SalesSummary AS
SELECT
    pc.ProductCategory,
    r.Region,
    SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Categories pc ON p.CategoryID = pc.CategoryID
JOIN Regions r ON s.RegionID = r.RegionID
GROUP BY pc.ProductCategory, r.Region;

-- Query the materialized view
SELECT *
FROM SalesSummary
WHERE TotalSales >= 10000
ORDER BY ProductCategory, Region;
-- Refresh the materialized view (this will update the data)
REFRESH MATERIALIZED VIEW SalesSummary;

-- ===========================================
-- ADVANCED  SQL

-- GROUP BY GROUPING SETS
-- allows you to specify a list of grouping criteria to generate separate result sets for specific combinations 
-- allow you to specify individual grouping sets explicitly.
-- used to group the data in multiple ways within a single query
-- useful when you want to obtain summary data at different levels of granularity in a single query
SELECT
    ProductCategory,
    Region,
    YEAR(OrderDate) AS SaleYear,
    SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY GROUPING SETS (
    (ProductCategory, Region),     -- Group by category and region
    (ProductCategory, SaleYear),   -- Group by category and year
    (Region, SaleYear),            -- Group by region and year
    (ProductCategory),             -- Group by category only
    (Region),                      -- Group by region only
    (SaleYear),                    -- Group by year only
    ()                             -- Grand total (no grouping)
)
ORDER BY ProductCategory, Region, SaleYear;

-- GROUP BY CUBE
-- CUBE operation generates a result set with all possible combinations of dimensions. 
-- It computes subtotals and totals for every possible combination of dimensions. 
SELECT
    ProductCategory,
    Region,
    YEAR(OrderDate) AS SaleYear,
    SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY CUBE(ProductCategory, Region, SaleYear)
ORDER BY ProductCategory, Region, SaleYear;

-- GROUP BY ROLLUP
-- provides a hierarchical view of the data, rolling up from detail to summary.
-- generates result set with a hierarchical summary that starts from the most detailed level (ProductCategory, Region, SaleYear) 
-- and rolls up to less detailed levels
SELECT
    ProductCategory,
    Region,
    YEAR(OrderDate) AS SaleYear,
    SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY ROLLUP(ProductCategory, Region, SaleYear)
ORDER BY ProductCategory, Region, SaleYear;

SELECT 
	'Q' ||TO_CHAR(payment_date,'Q'),
	EXTRACT(month from payment_date),
	DATE(payment_date),
	SUM(amount)
FROM payment 
--GROUP BY 1,2,3
--GROUP BY ROLLUP (1,2,3) -- group by specified hierarchy
GROUP BY CUBE (1,2,3)  -- all possible combinations 
ORDER BY 1,2,3;


-- =====================================================
-- WINDOW FUNCTIONS - Aggregate - Ranking - Value window 
-- Aggregate functions, AVG(), MAX(), MIN(), SUM() and COUNT().
-- Ranking window functions : used to simply assign numbers to the existing rows according to some requirements
-- Value window functions : used to copy values from other rows to other rows within the defined windows.
-- PARTITION BY clause is the equivalent to GROUP BY in the SQL window functions
-- AGG(agg_column) OVER(PARTITION BY partition_column) 

-- Aggregate window functions 
SELECT customer_id, amount, 
SUM(amount) OVER( PARTITION BY customer_id) AS sum_of_customer,
COUNT(*) OVER (PARTITION BY customer_id) AS num_of_tx
FROM payment 
--
SELECT f.film_id, title, length, name AS category,
ROUND ( AVG(length) OVER(PARTITION BY c.name), 2) AS avg_category
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
ORDER BY 1;
--
SELECT *,
COUNT(*) OVER(PARTITION BY customer_id, amount) AS total_TX
FROM payment ORDER BY payment_id;
-- OVER - ORDER BY => gives running total 
SELECT *, 
SUM(amount) OVER(ORDER BY payment_date),
SUM(amount) OVER(ORDER BY payment_id) AS sum2,
SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_id) AS sum_3,
SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_date, payment_id) AS sum_4
FROM payment
--
SELECT flight_id, departure_airport,
SUM(actual_arrival - scheduled_arrival) OVER(PARTITION BY departure_airport ORDER BY flight_id)
FROM flights
--
SELECT booking_id, listing_name, neighbourhood_group,
AVG(price) OVER(),
MIN(price) OVER(),
MAX(price) OVER(),
ROUND ( AVG(price) OVER(), 2 ),
price - AVG(price) OVER() AS diff_from_avg,
price - AVG(price) OVER() * 100 AS perc_of_avg,
(price / AVG(price) OVER() - 1) * 100 AS percent_diff_from_avg_price
FROM bookings;
--
SELECT
	booking_id, listing_name, neighbourhood_group, neighbourhood, price,
	AVG(price) OVER(PARTITION BY neighbourhood_group) AS avg_price_by_neigh_group
	AVG(price) OVER(PARTITION BY neighbourhood_group, neighbourhood) AS avg_price_by_group_and_neigh
FROM bookings;

--  Ranking window functions
SELECT f.title, c.name, f.length,
RANK() OVER (ORDER BY length DESC),  		-- seq with gaps 1,1,1,4,4,6
DENSE_RANK() OVER (ORDER BY length DESC),	-- seq with no gaps 1,1,1,2,2,3 etc
DENSE_RANK() OVER (PARTITION BY c.name ORDER BY length DESC) -- partition by = group by.. and apply window.. to this window and next window start with fresh 
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
--
SELECT
	booking_id, listing_name, neighbourhood_group, neighbourhood, price,
	ROW_NUMBER() OVER(ORDER BY price DESC) AS overall_price_rank,
	RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_rank,
	ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank
	RANK() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) AS neigh_group_price_rank_with_rank
	DENSE_RANK() OVER(ORDER BY price DESC) AS overall_price_rank_with_dense_rank
	CASE
		WHEN ROW_NUMBER() OVER(PARTITION BY neighbourhood_group ORDER BY price DESC) <= 3 THEN 'Yes'
		ELSE 'No'
	END AS top3_flag
FROM bookings;

-- FRAME
-- window function creates window/partition 
-- inside Partition we create SUB-SET of records = FRAME 

-- FRAME CLAUSE - how to change FRAME range 
-- how to specify the FRAME
-- in OVER ( RANGE )   - range of records in frame 
-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW - default SQL RANGE
-- RANGE BETWEEN 2 PRECEDING AND CURRENT ROW
-- RANGE BETWEEN 3 PRECEDING AND 3 FOLLOWING
-- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

-- UNBOUNDED = either to the end or from the beginning of the dataset/partition
-- PRECEDING = all the records prior to the current row 
-- FOLLOWING = all the records following current row 
-- CURRENT ROW 

-- RANGE vs ROWS in FRAME CLAUSE - only diff is RANGE considers doublicated data, ROWS not. 

SELECT *,
FIRST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC) AS most_exp_prod,
LAST_VALUE(product_name) OVER(PARTITION BY product_category ORDER BY price DESC 
						RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_exp_prod
FROM products;
--
SELECT *,
FIRST_VALUE(product_name) OVER w AS most_exp_prod,  -- using WINDOW alias 
LAST_VALUE(product_name) OVER w AS least_exp_prod,
NTH_VALUE(product_name,2) OVER w AS 2_most_exp_prod  -- second most expensive 
FROM product
WINDOW w AS (ARTITION BY product_category ORDER BY price DESC 
						RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

--NTILE - create buckets.. and split data into them 
SELECT *,
NTILE(3) OVER( ORDER BY price DESC) AS buckets
FROM product WHERE product_category = 'Phone';
-- CUME_DIST = cumulative distribution in range 0-1 

-- Value/Analitical window functions
SELECT
	booking_id, listing_name, host_name, price, last_review,
	LAG(price) OVER(PARTITION BY host_name ORDER BY last_review),
	LAG(price, 2) OVER(PARTITION BY host_name ORDER BY last_review),
	LEAD(price) OVER(PARTITION BY host_name ORDER BY last_review),
	LEAD(price, 2) OVER(PARTITION BY host_name ORDER BY last_review)
FROM bookings

-- =========================================
-- SUBQUERIES

-- in SELECT statment - single value = scalar subquery = one row/one column
SELECT customer_id, freight, ( SELECT AVG(freight) FROM orders ) AS subquery
FROM orders;
-- 
SELECT *, (SELECT MAX(amount) FROM payment) - amount AS difference FROM payment;

-- in FROM statment  - nested table to query in outer query  : czesto agg over aggragate
SELECT ship_country, AVG(num_orders) 
FROM
	( SELECT customer_id, ship_country, COUNT(*) AS num_orders
	  FROM orders
	  GROUP BY 1,2;) sub
GROUP BY 1;

-- in WHERE statment
SELECT * FROM orders
WHERE employee_id IN ( SELECT employee_id FROM employees WHERE LOWER(first_name) LIKE ('%a%') );
-- single col / multiple row
SELECT * FROM departments
WHERE department_name NOT IN ( SELECT DISTINCT dept_name FROM employee );
-- multiple row multi col sub
SELECT * FROM employee
WHERE ( dept_name , salary) IN ( SELECT dept_name, MAX(salary) FROM employee GROUP BY dept_name );

-- CORRELATED subquery  - very slow as row by row compared
-- depends on the value returned from internal query
SELECT * FROM employee e1
WHERE salary > ( SELECT AVG(salary) FROM employee e2 WHERE e2.dept_name = e1.dept_name )
--
SELECT * FROM department d
-- exists is logical operator TRUE OR FALSE
WHERE NOT EXISTS ( SELECT 1 FROM employee e WHERE e.dept_name = d.dept_name );  
-- 
SELECT * FROM payment p1 
WHERE amount = (SELECT MAX(amount) FROM payment p2 WHERE p1.customer_id = p2.customer_id)
ORDER BY customer_id;

-- NESTED SUBQUERY
SELECT *
FROM ( SELECT store_name, SUM(price) AS total_sales FROM sales GROUP BY store_name) sales )
JOIN ( SELECT AVG(total_sales) AS sales 
	  FROM ( SELECT store_name, SUM(price) AS total_sales FROM sales GROUP BY store_name ) x
	 ) avg_sales
ON sales.total_sales > avg_sales.sales;

-- Sub must have alias
SELECT ROUND(AVG(amout_per_day), 3)
FROM (SELECT SUM(amount) AS amout_per_day, DATE(payment_date)  FROM payment GROUP BY 2) alias;

-- ==========================================
-- CTE common table expresiosn  - WITH close  
-- create kind of temporary virtual table 
-- with the scope of the query 
-- must be run with query..
-- known as sub-query factoring 

WITH average_salary (avg_sal) AS 
	( SELECT CAST (AVG(salary) AS INT) as avg_sal 
	  FROM employee )
SELECT * FROM employee e, average_salary av 
WHERE e.salary < av.salary;

WITH total_sales (store_id, total_sales_per_store) AS
	 (SELECT store_id, sum(cost) AS total_sales_per_store FROM  sales GROUP BY store_id ),
	 avg_sales (avg_total_sales_per_store) AS 
	 (SELECT AVG(total_sales_per_store) as avg_total_sales_per_store FROM total_sales t );
SELECT *
FROM total_sales ts, avg_sales aas
WHERE ts.total_sales_per_store > aas.total_sales_per_store;

-- ============================================
-- DDL, Data Definition Language
-- used to MANAGE DAATBASE/TABLES 

CREATE DATABASE airbnb name
	WITH encoding = 'UTF-8';
COMMENT on DATABASE name IS 'The database = name'
DROP DATABASE IF EXISTS name;

-- DATA Types 
-- integer SMALLINT, INT, BIGINT, NUMERIC (10, 2) = DECIMAL, SERIAL ( with auto-increment)
-- strings VARCHAR(N), CHAR(N), TEXT (unlimited)
-- data/time : DATE, TIME (+02) = with time zone, TIMESTAMP, TIME INTERVALS
-- bool : boolean
-- enum : enumeration states

-- CONSTRAINS 
-- NOT NULL 
-- UNIQUE  
-- DEAFULT 
-- PRIMARY KEY 
-- FOREIGN KEY 

CREATE TABLE director (
	director_id SERIAL PRIMARY KEY,
	director_name VARCHAR(50) NOT NULL UNIQUE,
	first_name VARCHAR(50) CHECK (lenght(first_name) > 3),
	last_name VARCHAR(50) DEFAULT 'Not given',
	age NUMERIC(3,0) CHECK(age > 0),
	date_of_birth DATE,
	end_date DATE CHECK (end_date > date_of_birth),
	address_id INT REFERENCES address(address_id)  -- foreign key 

);
-- create table from query 
CREATE TABLE table_from_query AS
SELECT * FROM director;

--
INSERT INTO staff VALUES (set of values),(set of values ) 

DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
	booking_id INT PRIMARY KEY,
	listing_name VARCHAR,
	host_id INT,
	host_name VARCHAR(50),
	neighbourhood_group VARCHAR(30),
	neighbourhood VARCHAR(30),	
	latitude DECIMAL(11,8),
	longitude DECIMAL(11,8),
	room_type VARCHAR(30),
	price INT,
	minimum_nights INT,
	num_of_reviews INT,
	last_review DATE,
	reviews_per_month DECIMAL(4,2),
	calculated_host_listings_count INT,
	availability_365 INT
);

-- ALT TABLE 
-- https://www.postgresql.org/docs/current/sql-altertable.html
-- https://www.w3schools.com/sql/sql_alter.asp
-- DROP COLUMN name, ADD COLUMN name, ALTER COLUMN name , RENAME COLUMN name, 
ALTER TABLE director 
ALTER COLUMN director_name TYPE VARCHAR(30),
ALTER COLUMN last_name DROP DEFAULT,
ALTER COLUMN last_name SET NOT NULL,
ADD COLUMN email VARCHAR(50) ;
DROP CONSTRAINT date_check
--
ALTER TABLE director 
RENAME COLUMN director_name TO director_nm;
--
ALTER TABLE director 
RENAME TO directors;


-- ====================================
-- STORED PROCEDURES  
-- block of SQL stored in SQL ( queries, DML,DDL, DCL, TCL, ) starting with BEGIN and finish with END
-- allow you to group a series of SQL statements into a reusable and executable unit.

-- Creating a stored procedure
DELIMITER $$
CREATE PROCEDURE GetCustomerOrders(IN customerID INT)
BEGIN
    SELECT OrderID, OrderDate, TotalAmount
    FROM Orders
    WHERE CustomerID = customerID;
END;
$$
DELIMITER ;

-- Invoking the stored procedure
CALL GetCustomerOrders(123);



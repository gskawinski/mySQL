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
SELECT * FROM Products;
SELECT COUNT(*) FROM Customers;
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
DROP DATABASE db;
-- To create and delete a database in one step, will drop the existing database if it exists and then create a new one.
CREATE DATABASE IF NOT EXISTS db;










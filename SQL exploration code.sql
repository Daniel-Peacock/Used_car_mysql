-- This SQL workbook intends to inspect and clean data scrapped from used car sale listings for further analysis and dashboard creation.
-- Data gathered from https://www.kaggle.com/datasets/adityadesai13/used-car-dataset-ford-and-mercedes?resource=download.
-- Imported using migration wizard built in MySql.

-- Checking if all tables got imported.
SHOW TABLES;

-- Inspecting Audi table
SELECT *
FROM used_car.audi
ORDER BY 1 DESC
LIMIT 100;

-- Inspecting BMW table
SELECT *
FROM used_car.bmw
ORDER BY 1 DESC
LIMIT 100;

-- Counts entries for each table
SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = 'used_car';

-- Total entries across tables == 72048
SELECT SUM(table_rows)
FROM information_schema.tables
WHERE table_schema = 'used_car';


-- There are two tables that represent one model and those models are represented in other tables. EG 'merc' has 'cclass' model and 'ford' has 'focus' model.
-- Checking if its duplicated or unique data between 'merc' and 'cclass' + 'ford' and 'focus'.

-- inspect cclass table
SELECT *
FROM used_car.cclass
ORDER BY 2;


-- inspect "merc" table filtered WHERE the model is C Class to compare.
SELECT *
FROM used_car.merc
WHERE model = ' C Class'
ORDER BY 2;

-- Lets try and combine them using UNION and UNION ALL then look at the amount of rows returned.
-- NOTE UNION will remove duplicates between the tables, while UNION ALL will combine all results regardless of duplicates.
-- NOTE UNION will not remove duplicates within a table but duplicates created from the union

-- UNION == 3931 ROWS
Select model, year, price, mileage
FROM used_car.cclass
UNION
SELECT model, year, price, mileage
FROM used_car.merc
WHERE model = ' C Class';

-- UNION ALL == 7646 ROWS
Select model, year, price, mileage
FROM used_car.cclass
UNION ALL
SELECT model, year, price, mileage
FROM used_car.merc
WHERE model = ' C Class';

-- Given the difference in rows is extrememly large, we can tell most of the data are duplicates. 

-- Lets do the same proccess to the 'ford = focus' and 'focus' tables to be thourough.

-- Inspect focus table
SELECT *
FROM used_car.focus
ORDER BY year DESC;

-- Inspect ford table with respect to model = ' focus'
SELECT *
FROM used_car.ford
WHERE model = ' focus'
ORDER BY year DESC;


-- Ford where model = focus,  Rows = 4588
SELECT model, year, price, mileage
FROM used_car.ford
WHERE model = ' focus';

-- Focus table, Rows = 5454
SELECT model, year, price, mileage
FROM used_car.focus;

-- UNION == 4979 ROWS
Select model, year, price, mileage
FROM used_car.focus
UNION
SELECT model, year, price, mileage
FROM used_car.ford
WHERE model = ' focus';

-- UNION ALL == 10042 ROWS
Select model, year, price, mileage
FROM used_car.focus
UNION all
SELECT model, year, price, mileage
FROM used_car.ford8
WHERE model = ' focus';

-- Once again we can see most of these entries are duplicates. 
-- We can combine the data to get slightly more entries which is ideal, however, there are missing columns in the tables 'focus' and 'cclass'.
-- Therefor, in this case we won't combine them because it would create null values for variables: 'tax', 'mpg' and 'fuelType'.
-- Which would limit our analysis for a slim gain in amount of entries.

-- Dropping tables 'focus' and 'cclass'
DROP TABLE focus, cclass;

-- Checking for duplicates within table 'bmw'. 

SELECT model, year, price, mileage, COUNT(*) as count
FROM used_car.bmw
GROUP BY model, year, price, mileage
HAVING count > 2
ORDER BY count DESC
;
-- This returns 15 rows, with some entries having 20,15 13 ect counts as well as many entries with 2 or 3 entries.
-- Based on price, year, model and mileage
-- Although theoretically possible, realistically, most of these duplicates are probably erroneous.
-- To clean the data and make it more accurate to the actual population we will be removing all the duplicate entries

-- Creating a temp table to do this operation 
CREATE TABLE temp_bmw AS 
SELECT DISTINCT * 
FROM used_car.bmw;

-- Checking if it has worked
SELECT model, year, price, mileage, transmission, fuelType, tax, mpg, engineSize,  COUNT(*) as count
FROM used_car.temp_bmw
GROUP BY model, year, price, mileage, transmission, fuelType, tax, mpg, engineSize
ORDER BY count DESC;
-- Indeed, all duplicate entries have been removed.

-- Now we can drop our original table and rename our temp table to the new table

DROP TABLE bmw;
RENAME TABLE temp_bmw TO bmw;
-- Now we have a fully cleaned table and need to repeat the process for all tables

-- audi table 
CREATE TABLE temp_audi AS 
SELECT DISTINCT * 
FROM used_car.audi;

DROP TABLE audi;
RENAME TABLE temp_audi TO audi;

-- ford table 
CREATE TABLE temp_ford AS 
SELECT DISTINCT * 
FROM used_car.ford;

DROP TABLE ford;
RENAME TABLE temp_ford TO ford;

-- hyundi table 
CREATE TABLE temp_hyundi AS 
SELECT DISTINCT * 
FROM used_car.hyundi;

DROP TABLE hyundi;
RENAME TABLE temp_hyundi TO hyundi;

-- merc table 
CREATE TABLE temp_merc AS 
SELECT DISTINCT * 
FROM used_car.merc;

DROP TABLE merc;
RENAME TABLE temp_merc TO merc;

-- skoda table 
CREATE TABLE temp_skoda AS 
SELECT DISTINCT * 
FROM used_car.skoda;

DROP TABLE skoda;
RENAME TABLE temp_skoda TO skoda;

-- Now we have 6 cleaned tables with no duplicates and can create some querries looking at aggregate functions and the spread of the data


SELECT model,
 MAX(price) as max_price,
 MIN(price) as min_price,
 ROUND(AVG(price), 2) as average_price,
Round(VAR_SAMP(price), 0) as sample_variance,
 ROUND((STDDEV_SAMP(price)), 2) as sample_std_dev,
 COUNT(*) as count
FROM used_car.audi
GROUP BY model
HAVING count > 1
ORDER BY model;







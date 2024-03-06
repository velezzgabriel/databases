


------------------------ QUERY EXECUTION PLAN ---------------------


-- EXPLAIN followed by the query
EXPLAIN SELECT * FROM your_table WHERE column = 'value';


-- EXPLAIN ANALIZE followed by the query
EXPLAIN ANALYZE SELECT * FROM your_table WHERE column = 'value';


-------------------------- SERIAL datatype	
-- reset serial value:
ALTER SEQUENCE sequence_name
RESTART WITH 1;
-- reset serial to an specific number
--false: This is the third argument to the setval function. 
--It specifies whether the sequence should be incremented by 1 after setting the new value. 
--When set to false, as in this command, the sequence will not be incremented, meaning the next value generated 
--by the sequence will be the same as the new value you specified (in this case, 100).
SELECT setval('your_table_id_seq', 100, false);
-- find out serial sequence name of a column
SELECT pg_get_serial_sequence('your_table_name', 'your_column_name');
-- see current serial value:
SELECT currval('sequence_name');

-------------------------- REPLACING NULL VALUE  -------------
--option #1
SELECT e.name as employee, 
        CASE WHEN m.name is null then 'no manager' ELSE m.name END as Manager
FROM tabla_employee e1
LEFT JOIN tabla_emploee e2
ON e1.manager_id = e2.employee_id

--option #2
SELECT e1.name AS employee, COALESCE(e2.name, 'No Manager') AS manager
FROM tabla_employee e1
LEFT JOIN tabla_employee e2 
ON e1.manager_id = e2.employee_id;


-------------------------- COALESCE -------------------------
--Returns the first NON-NULL value from each row.
SELECT id, COALESCE(first_name, middle_name, last_name) as Name
FROM table_x
--replace null values for a default value in a column
SELECT COALESCE(column1, 'Default') AS result
FROM your_table;
--with dates
SELECT COALESCE(start_date, '2023-01-01'::date) AS result
FROM events;
--with Subqueries:
--if the the subquery returns a non-null value, that value is used
SELECT COALESCE((SELECT value FROM other_table WHERE condition), 'Default') AS result
FROM your_table;
--with WHERE clause
-- "= 'Value'": This part checks if the result of the COALESCE function is equal to the string 'Value.'
SELECT *
FROM your_table
WHERE COALESCE(column1, column2) = 'Value';
--with NULLIF
--NULLIF(column1, 0): The NULLIF function compares "column1" to the value 0. 
--If "column1" is equal to 0, it returns null; otherwise, it returns the value of "column1." 
--This function effectively replaces 0 with null.
SELECT COALESCE(NULLIF(column1, 0), 1) AS result
FROM your_table;




---------------------------NULLIF ------------------------------
-- returns NULL if both columns are equal
SELECT NULLIF(column1, column2) AS result
FROM your_table;
-- CASE expression
SELECT CASE WHEN NULLIF(column1, 0) IS NULL THEN 'No Value' ELSE 'Has Value' END AS result
FROM your_table;
-- DIVISIONS BY ZERO HANDLING
SELECT NULLIF(dividend_column / NULLIF(divisor_column, 0), 0) AS result
FROM your_table;



-------------------- FILTER
/*
FILTER is much like WHERE, except that it removes rows only from the input of the particular aggregate function that it is attached to. 
Here, the COUNT aggregate counts ONLY rows with temp_lo below 45; but the MAX aggregate is still applied to ALL rows, so it still finds the reading of 46.
Another way to select the rows that go into an aggregate computation is to use FILTER, which is a per-aggregate option:

SELECT city, count(*) FILTER (WHERE temp_lo < 45), max(temp_lo)
    FROM weather
    GROUP BY city;
     city      | count | max
---------------+-------+-----
 Hayward       |     1 |  37
 San Francisco |     1 |  46*/


-------------------------  DUPLICATES  ----------------------------

------------------------------------  DUPLICATES
-- encontrando duplicados en una lista. No incluimos 'id' en la partition by 
-- porque generalmente este es un campo que siempre es diferente dado que se asigna automaticamente al ingresar info a una tabla.
SELECT * 
FROM (
    SELECT id,
    ROW_NUMBER() OVER(
        PARTITION BY
            nombre,
            apellido,
            email,
            colegiatura,
            fecha_incorporacion,
            carrera_id,
            tutor_id
        ORDER BY id ASC
        ) AS row
    *
    FROM  platzi.alumnos
    ) AS duplicados
WHERE duplicados.row > 1; 

-------------- Scenario 1: duplicated data based on some of the columns

--task: delete duplicate data from cars table.
--      duplicate record is identified based on the model and brand name.

--approach #1: using Unique Identifier
DELETE FROM cars
WHERE id IN (   select max(id)
                from cars 
                group by model, brand
                having count(*) > 1);

--approach #2: using Self Join.

DELETE FROM cars
WHERE id IN (   select c2.id
                from cars as c1
                join cars as c2 
                on c1.model = c2.model and c1.brand = c2.brand
                where c1.id < c2.id );

--approach #3: using Window Function.

DELETE FROM cars
WHERE id IN (   select id
                from ( select *, 
                       row_number() over(partition by model, brand) as rn
                       from cars) as x
                where x.rn > 1 );


-------------- Scenario 2: duplicated data based on ALL of the columns

--approach #1: using CTID, which is a unique row number that Postgres assign to every row. (only available in Postgresql)

DELETE FROM cars
WHERE id IN (   select max(ctid)
                from cars 
                group by model, brand
                having count(*) > 1);


--approach #2: using temporary unique id column

alter table cars add column row_num int generated always as Identity;

DELETE FROM cars
WHERE id IN (   select max(row_num)
                from cars 
                group by model, brand
                having count(*) > 1);

alter table cars drop column row_num;


--approach #3: creating a backup table, dropping original table. No good when working in production env.

create table cars_backup as 
select distinct * from cars;

drop table cars;

alter table cars_backup rename to cars;


--approach #4: creating a backup table without dropping original table.

create table cars_backup as 
select distinct * from cars;

truncate table cars;

insert into cars
select * from cars_backup;

drop table cars_backup;



--------------------------UNION and UNION ALL --------------------
/*
These are used to combine the result of two or more queries.
For them to work, the number, data type and order of columns in the select should be the same.
 UNION includes duplicates when merging tables, UNION ALL do not include duplicates.
 UNION combines ROWS, JOINS combine COLUMNS
 UNION is more time consuming.
 */

 select * from table_x
 UNION ALL
 select * from table_y 
 ORDER BY name        --ORDER BY must go after the LAST query.




---------------------------- CONSTRAINTS -----------------
---- constraints in a table....
SELECT oid, conname, connamespace FROM pg_constraint WHERE conrelid = 'table_name'::regclass;

--Add CONSTRAINTS:	
ALTER TABLE products ADD CHECK (name <> '');
ALTER TABLE table_name ADD PRIMARY KEY (column_name);
ALTER TABLE products ADD CONSTRAINT some_name UNIQUE (product_no);
--Add a Foreign Key Constraint:	
ALTER TABLE child_table ADD CONSTRAINT foreign_key_name
    FOREIGN KEY (child_column) REFERENCES parent_table (parent_column);
--Remove CONSTRAINTS:	
ALTER TABLE table_name DROP CONSTRAINT constraint_name;

---------UNIQUE Constraint
--Adding a UNIQUE constraint will automatically create a unique B-tree index on the column or group of columns listed in the constraint. 
--A uniqueness restriction covering only some rows cannot be written as a unique constraint, but it is possible to enforce such a restriction by creating a unique partial index.
--By default, two null values are not considered equal in this comparison. 
--Null behavior under this constraint might be explicitly written: UNIQUE NULLS NOT DISTINCT / UNIQUE NULLS DISTINCT


---------CHECK Constraint
--
CREATE TABLE products (
    product_no integer,
    name text,
    price numeric CONSTRAINT positive_price CHECK (price > 0)
);


---------PRIMARY KEY
--used as a unique identifier for rows in the table. This requires that the values be both UNIQUE and NOT NULL
--Adding a primary key will automatically create a unique B-tree index on the column or group of columns listed in the primary key, and will force the column(s) to be marked NOT NULL.


---------FOREIGN KEY
--We say that in this situation the orders table is the referencing table and the products table is the referenced table. Similarly, there are referencing and referenced columns.
--Restricting and cascading deletes are the two most common options. RESTRICT prevents deletion of a referenced row. NO ACTION means that if any referencing rows still exist 
--when the constraint is checked, an error is raised; this is the default behavior if you do not specify anything. (The essential difference between these two choices is that NO ACTION 
--allows the check to be deferred until later in the transaction, whereas RESTRICT does not.) CASCADE specifies that when a referenced row is deleted, row(s) referencing it should be automatically deleted as well. 
--There are two other options: SET NULL and SET DEFAULT. These cause the referencing column(s) in the referencing row(s) to be set to nulls or their default values, respectively, when the referenced row is deleted. 
--Note that these do not excuse you from observing any constraints. For example, if an action specifies SET DEFAULT but the default value would not satisfy the foreign key constraint, the operation will fail.






-------------------------- ALTER TABLE --------------------
--
--Add a New Column
ALTER TABLE table_name
    ADD COLUMN new_column_name data_type;
--add new column with unique identifier
alter table table_name add column row_num int generated always as Identity;
--RENAME a COLUMN:
ALTER TABLE table_name
    RENAME COLUMN old_column_name TO new_column_name;
--Change Data Type of a Column:	
ALTER TABLE table_name
    ALTER COLUMN column_name SET DATA TYPE new_data_type;
--Add a Default Value to a Column:	
ALTER TABLE table_name
    ALTER COLUMN column_name SET DEFAULT default_value;
--Drop a Column:	
ALTER TABLE table_name
    DROP COLUMN column_name;
--RENAME a TABLE:	
ALTER TABLE old_table_name RENAME TO new_table_name;
--Add an Index:	
CREATE INDEX index_name ON table_name (column_name);
--Drop an Index:	
DROP INDEX index_name;
--Enable or Disable Triggers:	
ALTER TABLE table_name
    ENABLE TRIGGER trigger_name;
--Set Column Identity (SERIAL):	
ALTER TABLE table_name
    ALTER COLUMN column_name SET GENERATED ALWAYS AS IDENTITY;
--Remove Column Identity (SERIAL):	
ALTER TABLE table_name
    ALTER COLUMN column_name DROP IDENTITY;
--Change the Owner of a Table:	
ALTER TABLE table_name
    OWNER TO new_owner;
--Change column datatype:
--This will succeed only if each existing entry in the column can be converted to the new type by an implicit cast. If a more complex conversion is needed, 
--you can add a USING clause that specifies how to compute the new values from the old.
--best to drop any constraints on the column before altering its type, and then add back suitably modified constraints afterwards.
ALTER TABLE products ALTER COLUMN price TYPE numeric(10,2);



----------------------- RETURNING DATA FROM MODIFYING ROWS
--RETURNING clause will print only the rows that have been modified
--RETURNING can be used INSERT, UPDATE, and DELETE commands
INSERT INTO users (firstname, lastname) VALUES ('Joe', 'Cool') RETURNING id;
UPDATE products SET price = price * 1.10  WHERE price <= 99.99  RETURNING name, price AS new_price;
DELETE FROM products  WHERE obsoletion_date = 'today'  RETURNING *;


----------------------- UPDATE	
--Update a Single Column in All Rows:	
UPDATE table_name
    SET column_name = new_value;
--Update Specific Rows Based on a Condition:	
UPDATE table_name
    SET column_name = new_value
WHERE condition;
--Update Multiple Columns in a Single Row:
UPDATE table_name
    SET column1 = value1, column2 = value2, ...
    WHERE condition;
--Update with Subquery:	
UPDATE table1
    SET column1 = table2.new_value
    FROM table2
    WHERE table1.id = table2.id;
--Update with Case Statement:	
UPDATE table_name
    SET column_name = CASE
                   WHEN condition1 THEN value1
                   WHEN condition2 THEN value2
                   ELSE default_value
                 END
    WHERE condition;
--Update a Column with a Calculated Value:	
UPDATE table_name
    SET column_name = column_name + 10
    WHERE condition;
--Update Data from Another Table Using a JOIN:	
UPDATE target_table
    SET target_column = source_table.new_value
    FROM source_table
    WHERE target_table.join_column = source_table.join_column;
	
	
	
----------------------- INSERT	
--Insert Multiple Rows in a Single Statement:	
INSERT INTO table_name (column1, column2, ...)
    VALUES
    (value1_1, value2_1, ...),
    (value1_2, value2_2, ...),
    ...;
--Insert Data from a Subquery:	
INSERT INTO table_name (column1, column2, ...)
    SELECT value1, value2, ...
    FROM another_table
    WHERE condition;
--Insert Data with a Default Value:	
INSERT INTO table_name (column1, column2, column3)
    VALUES (value1, value2, DEFAULT);



------------------------- GENERATE SERIES
-- GENERATE_SERIES(start, stop, step)
SELECT * FROM GENERATE_SERIES('2023-10-01'::DATE, '2023-10-05'::DATE, '1 day') AS date_series;
--
SELECT * FROM GENERATE_SERIES(
   TIMESTAMP '2023-10-01 00:00:00',
   TIMESTAMP '2023-10-01 12:00:00',
   INTERVAL '1 hour'
) AS timestamp_series;
--


---------------------- TEMPORARY TABLES (local and global) -------------------

-- LOCAL temporary tables available only from the connection where they were created from.
-- if a LOCAL temporary table was created within a stored procedure, they are dropped once the proc concludes.
--GLOBAL ones are visible to all connections. only destroyed when the last connection referencing the table closes. 
--GLOBAL names must be unique, LOCAL ones may not. 

----------------Session-scoped Temporary Tables (pg_temp or UNLOGGED): 
--These tables are visible only within the current database session. 
--They are automatically dropped when the session ends (e.g., when the client disconnects).
CREATE TEMP TABLE temp_table (
    id serial PRIMARY KEY,
    name text
);

--------------Transaction-scoped Temporary Tables (pg_temp_1, pg_temp_2, ...): 
--These tables are visible only within the current transaction block. 
--They are automatically dropped when the transaction is committed or rolled back.
BEGIN;
CREATE TABLE temp_table (
    id serial PRIMARY KEY,
    name text);
COMMIT;



---------------------------- VIEWS --------------------------
-- Views cannot be based on temp tables.

--Advantages:
--reduce complexity of the database schema
--mechanism to implement row and column level security
--can be used to present aggregated data and hide detailed data



-------------   SIMPLE VIEWS:
--They are based on a single SELECT statement.
--They allow you to create a VIRTUAL TABLE that presents data from one or more underlying tables in a simplified way.
--Simple views are read-only by default, meaning you can query them, but you can't directly perform INSERT, UPDATE, or DELETE operations on them.

CREATE VIEW employee_view AS
SELECT id, first_name, last_name
FROM employees;

-------------   UPDATABLE VIEWS
--Updatable views are a special type of view that allows you to perform INSERT, UPDATE, and DELETE operations on them.
--Updating a view will change the underlying table too.
--To create an updatable view, certain conditions must be met such as:
--          1) having a single base table
--          2) no DISTINCT or GROUP BY clauses
--          3) no window functions
CREATE OR REPLACE VIEW updatable_view AS
SELECT id, name
FROM products
WHERE active = true;


-------------    MATERIALIZED VIEWS
--NOTE: indexing a standard view will make it materialized. MAYBE
--Materialized views store the result of a query as a physical table.
--Unlike standard views, materialized views store data on disk and need to be refreshed manually or automatically.
--They are useful for improving query performance in cases where complex calculations or aggregations are needed frequently.
CREATE MATERIALIZED VIEW mview_name
AS 
SELECT id, AVG(val), COUNT(*)
FROM a_table
GROUP BY id;

--update materialized view
REFRESH MATERIALIZED VIEW mview_name;


---------------  INDEXED VIEWS  (Covering Indexes):
--NOTE: indexing a standard view will make it materialized. MAYBE

--PostgreSQL does not have native support for indexed views like some other database systems. 
--However, you can achieve similar functionality using indexes and standard views.
--You can create indexes on views to improve query performance when frequently accessing data through the view.
CREATE VIEW customer_orders AS
SELECT c.customer_id, o.order_date, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
--Creating the index has to be done in the underlying tables, it might not be done in the view itself, in Postgres.
CREATE INDEX idx_customer_orders ON customer_orders (customer_id);








----------------------- TRUNCATE		
--Truncate a Table:	
--Truncate a specific table, removing all rows and resetting the auto-increment (serial) column:
TRUNCATE table_name;

--Truncate a Table with CASCADE Option:	
--Truncate a table and all its dependent tables (foreign key related tables) using the CASCADE option.
---This will remove all rows from the specified table and any related tables."
TRUNCATE table_name CASCADE;

--Truncate a Table with a WHERE Clause:	
--You can truncate a table based on a condition using a WHERE clause. In this example, only rows matching the condition will be removed:
TRUNCATE table_name
    WHERE column_name = 'value';


	
------------------------ value IN
--to look for each value in the array within the table. 
--you can use a subquery instead of a hardwritten array	
SELECT * FROM users WHERE name IN ('Israel', 'Laura', 'Luis')
FROM a_table;

-------------------------- DATE TIME DATA TYPE ---------------------------
--DATE type     -->     '2023-10-03'
--TIME type     -->     '14:30:00'
--TIMESTAMP type-->     '2023-10-03 14:30:00'
--TIMESTAMP WITH TIME ZONE Type --> '2023-10-03 14:30:00+02:00' 

--Current info
SELECT CURRENT_DATE AS current_date, CURRENT_TIME AS current_time, CURRENT_TIMESTAMP AS current_timestamp;


--------------------------EXTRACT date
--extract date in certain format
date_format(trans_date, '%Y-%m') as month

-- FORMATTING
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD HH:MI:SS') AS formatted_timestamp;
SELECT TO_DATE('2023-10-03', 'YYYY-MM-DD') AS parsed_date;


-- output -> "2023-10-10 00:00:00"
SELECT '2023-10-03'::DATE + INTERVAL '7 days' AS future_date;

-- output -> 7
SELECT '2023-10-10'::DATE - '2023-10-03'::DATE AS date_diff;

-- output -> "2023-10-30"
SELECT '2023-10-20'::DATE + 10 AS date_sum;


-- used to extract and retrieve specific components (such as year, month, day, hour, etc.) from a date or timestamp.
SELECT EXTRACT(YEAR FROM the_datetype_column::DATE) AS anio_in_that_column FROM a_table;
SELECT EXTRACT(MONTH FROM transaction_timestamp::DATE) AS transaction_month FROM sales;
SELECT EXTRACT(DAY FROM the_datetype_column::DATE) AS anio_in_that_column FROM a_table;
SELECT EXTRACT(HOUR FROM log_timestamp) AS log_hour FROM log_entries FROM a_table;
SELECT EXTRACT(MINUTE FROM appointment_time) AS appointment_minute FROM appointments;

--Day of the week (DOW) from Date:
--This query extracts the day of the week (0 for Sunday, 6 for Saturday) from the "order_date" column of the "orders" table.
SELECT EXTRACT(DOW FROM order_date) AS day_of_week FROM orders;
--This query extracts the weekday (1 for Monday, 7 for Sunday) from the "due_date" column of the "tasks" table, using the ISO weekday format.
SELECT EXTRACT(ISODOW FROM due_date) AS weekday FROM tasks;

--Day of the Year from Date:
--This query extracts the day of the year (1 to 366) from the "holiday_date" column of the "holidays" table.
SELECT EXTRACT(DOY FROM holiday_date) AS day_of_year FROM holidays;

--TRUNCATE
SELECT DATE_TRUNC('month', '2023-10-30'::DATE) AS truncated_date;

-------------------------DATE_PART()
SELECT DATE_PART('YEAR', the_datatype_column) AS year_in_that_column FROM a_table;
SELECT DATE_PART('MONTH', the_datatype_column) AS month_in_that_column FROM a_table;
SELECT DATE_PART('DAY', the_datatype_column) AS day_in_that_column FROM a_table;

SELECT DATE_PART('quarter', '2023-09-25'::DATE);    -- Output: 3
SELECT DATE_PART('week', '2023-09-25'::DATE);       -- Output: 39
SELECT DATE_PART('doy', '2023-09-25'::DATE);        -- Output: 268
SELECT DATE_PART('dow', '2023-09-25'::DATE);        -- Output: 1 (Monday)
SELECT DATE_PART('isodow', '2023-09-25'::DATE);     -- Output: 1 (Monday)

SELECT DATE_PART('hour', '2023-09-25 15:30:00'::TIMESTAMP); -- Output: 15
SELECT DATE_PART('minute', '2023-09-25 15:30:00'::TIMESTAMP); -- Output: 30
SELECT DATE_PART('second', '2023-09-25 15:30:45'::TIMESTAMP); -- Output: 45



------------------------  SELECT	--------------------------

-- DISTINCT Rows from a Table:	
--Filters the results so that only distinct (unique) values are returned. It ensures that duplicate values are removed from the result set.
SELECT DISTINCT column_name FROM table_name;	
	
--OFFSET clause specifies the number of rows to skip before starting to return rows in the result set. In this case, it instructs the database to skip the first 5 rows.
SELECT * FROM table_name OFFSET 5;	
--BETWEEN	
SELECT * FROM tabla_diaria
    WHERE  cantidad BETWEEN 10 AND 100;

--LIMIT and OFFSET:	
--It restricts the result set to include only 10 rows, starting from the 6th row.
SELECT * FROM table_name LIMIT 10 OFFSET 5;

--Calculate AGGREGATES (e.g., SUM, AVG):	
SELECT AVG(column_name) FROM table_name;	
--This query returns the SUM of all values in the specified column.
SELECT SUM(column_name) FROM table_name;
--This query returns the COUNT of non-null values in the specified column.
SELECT COUNT(column_name) FROM table_name;	
SELECT MIN(column_name) FROM table_name;	
-- CALCULATIONS between columns
SELECT quantity * unit_price AS total_cost FROM sales;	


----------------------- FETCH
--fetch FIRST n rows only:
SELECT * FROM products
ORDER BY price DESC
FETCH FIRST 5 ROWS ONLY;
--fetch LAST n rows:
SELECT * FROM messages
ORDER BY message_id
FETCH PRIOR 3 ROWS ONLY;
--fetch NEXT 10 rows after skipping the first 5:
SELECT * FROM orders
OFFSET 5
FETCH NEXT 10 ROWS ONLY;
--fetch PRIOR 
SELECT * FROM messages
ORDER BY message_id
FETCH PRIOR 3 ROWS ONLY;

-- fetch rows from subquery:
SELECT *
FROM (
    SELECT id, name FROM customers
) AS subquery
FETCH FIRST 3 ROWS ONLY;
--fetch RANDOM rows:
SELECT * FROM products
ORDER BY RANDOM()
FETCH FIRST 4 ROWS ONLY;

--use VARIABLE offset:
DECLARE offset_var INT;
SET offset_var = 3;

SELECT * FROM customers
OFFSET offset_var
FETCH NEXT 5 ROWS ONLY;

--fetch rows with TIES
--This command retrieves the top 5 scores from the "leaderboard" table, including ties.
SELECT * FROM leaderboard
WHERE score >= 90
ORDER BY score DESC
FETCH FIRST 5 ROWS WITH TIES;

--fetch ABSOLUTE n rows
--This query retrieves the customer at the 15th position in the result set, based on their customer ID.
SELECT * FROM customers
ORDER BY customer_id
FETCH ABSOLUTE 15 ROWS;

--fetch RELATIVE n rows:
--This query retrieves the employee 3 positions below the current row in the result set, ordered by their salary in descending order.
SELECT * FROM employees
ORDER BY salary DESC
FETCH RELATIVE 3 ROWS;

--fetch ALL
--This query retrieves all products in category 2 from the "products" table.
SELECT * FROM products
WHERE category_id = 2
FETCH ALL;
--This query skips the first 10 employees, then fetches all remaining employees from the "employees" table, ordered by their hire date.
SELECT * FROM employees
ORDER BY hire_date
OFFSET 10
FETCH ALL;

---------------------  CAST DATA ----------------------
-- text to numeric
SELECT CAST('123.45' AS NUMERIC) AS numeric_value;
-- or
SELECT '123.45'::NUMERIC AS numeric_value;
-- numeric to text
SELECT CAST(42.25 AS TEXT) AS text_value;
-- or
SELECT 42.25::TEXT AS text_value;
-- date to text
SELECT CAST('2023-10-03' AS TEXT) AS date_text;
-- or
SELECT '2023-10-03'::TEXT AS date_text;
-- text to date
SELECT CAST('2023-10-03' AS DATE) AS date_value;
-- or
SELECT '2023-10-03'::DATE AS date_value;
-- timestamp to date
SELECT CAST('2023-10-03 14:30:00' AS DATE) AS date_value;
-- or
SELECT '2023-10-03 14:30:00'::DATE AS date_value;



----------------------- LIKE, NOT LIKE	
SELECT * FROM users WHERE name LIKE "Is%";
SELECT * FROM users WHERE name LIKE "Is_ael";
SELECT * FROM users WHERE name NOT LIKE "Is_ael";



------------------------- STRINGS
--String Concatenation (|| operator):	
--Result: "Hello, world!"
SELECT 'Hello, ' || 'world!' AS concatenated_string;	

--String Length (LENGTH or CHAR_LENGTH):	
--Result: 13
SELECT LENGTH('Hello, world!') AS string_length;

--Uppercase and Lowercase Conversion (UPPER and LOWER): 
--Result: "HELLO, WORLD!" and "hello, world!"
SELECT UPPER('Hello, world!') AS uppercase_string, LOWER('Hello, world!') AS lowercase_string;	

--String Trimming (TRIM, LTRIM, and RTRIM): 	
--Result: "Hello, world!"
SELECT TRIM('   Hello, world!   ') AS trimmed_string;	

--PATTERN Matching (LIKE and Regular Expressions)	
--Result: true and true
SELECT 'apple' LIKE 'a%' AS starts_with_a, 'apple' ~* 'A.*' AS regex_match;	

--PATTERN finding  -->output: 3
--returns the position of the first occurrence
SELECT (SELECT strpos('This is a test', 'is')) AS patindex_result;

--String Replacement (REPLACE): 	
--Result: "Hello, universe!"
SELECT REPLACE('Hello, world!', 'world', 'universe') AS replaced_string;	

--String Splitting (SPLIT_PART and STRING_TO_ARRAY):	
--Result: "banana"
SELECT SPLIT_PART('apple,banana,cherry', ',', 2) AS split_result;	

--REVERSE  and  LENGTH
SELECT word AS original_word,
       REVERSE(word) AS reversed_word,
       LENGTH(word) AS word_length
FROM words;

--Substring Extraction (SUBSTRING):	emulating RIGHT,LEFT,CHARINDEX
--LEFT      --> output: "Hello"
SELECT SUBSTRING('Hello, world!' FROM 1 FOR 5) AS substring_result;	
--RIGHT     --> output: 'orld'
SELECT SUBSTRING('hello world' FROM LENGTH('hello world') - 4 + 1) AS right_result;
--CHARINDEX --> output: 3
SELECT POSITION('llo' IN 'hello world') AS charindex_result;

--REPEAT
SELECT REPEAT('abc', 3) AS replicated_string;

-- PostgreSQL equivalent of SPACE
SELECT LPAD('', 5, ' ') AS space_string;

-----------------PADDING
--LPAD(string, length, pad_character)
-- Output: '00123'
SELECT LPAD('123', 5, '0') AS padded_string;
--RPAD(string, length, pad_character)
-- Output: '123XX'
SELECT RPAD('123', 5, 'X') AS padded_string;


------------------------  REGEX
--
SELECT email
FROM platzi.alumnos
WHERE email ~* '[A-Z0-9_%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}';


















------------------------ POINT-BASED EARTH DISTANCES	
--Install extension	
CREATE EXTENSION postgis;

--calculate distance in meters	
SELECT ST_DistanceSphere(
    'POINT(13.4050 52.5200)'::geography, -- Berlin coordinates
    'POINT(2.3522 48.8566)'::geography  -- Paris coordinates
) AS distance_in_meters;
	


------------------------------- SET		
--Enable or Disable Autocommit:	
-- Disables autocommit mode	This can be used to control transaction behavior.
SET autocommit = OFF; 

--Set Multiple Parameters in One Command:	
SET work_mem = '16MB', maintenance_work_mem = '128MB';	
		

--------------------------------- WHILE STATEMENT
-----
DO $$
DECLARE
  i INT := 1;
BEGIN
  WHILE i <= 10 LOOP
    RAISE NOTICE 'Current value of i: %', i;
    
    IF i = 5 THEN
      EXIT; -- Break out of the loop when i equals 5
    END IF;

    i := i + 1;
  END LOOP;
END;
$$;

---- ARRAY LOOPING
DO $$
DECLARE
  data INT[] := ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  i INT := 1;
BEGIN
  WHILE i <= array_length(data, 1) LOOP
    RAISE NOTICE 'Current data value: %', data[i];
    
    IF data[i] > 7 THEN
      EXIT; -- Break out of the loop when a value greater than 7 is encountered
    END IF;

    i := i + 1;
  END LOOP;
END;
$$;

---- while TRUE
DO $$
DECLARE
  total INT := 0;
  i INT := 1;
BEGIN
  WHILE TRUE LOOP
    total := total + i;
    RAISE NOTICE 'Current total: %', total;

    IF total > 15 THEN
      EXIT; -- Break out of the loop when the total exceeds 15
    END IF;

    i := i + 1;
  END LOOP;
END;
$$;



--------------------------------- EXCEPT
--EXCEPT operator, which is used to retrieve distinct rows from one result set that do not appear in another result set. It effectively subtracts one set of rows from another. 
--The number and the order of the columns must be the same in both the queries.
--Data type of the columns must be same or compatible.
--EXCEPT filters duplicates and returns only DISTINCT ROWS from the left query that are not in the right query.
SELECT employee_name
FROM employees
EXCEPT
SELECT former_employee_name
FROM former_employees;

--
SELECT student_name
FROM students
EXCEPT
SELECT graduate_name
FROM graduates;








--------------------------------- NOT IN 
-- NOT IN might not handle NULL values as expected. If the subquery returns NULL, the NOT IN condition won't behave as expected. 
--In such cases, using EXCEPT can be a more reliable option. Additionally, the performance characteristics of EXCEPT and NOT IN can differ, 
--so it's essential to consider the specific requirements of your query and choose the operator that best fits your needs.
--NOT IN does not filtrate duplicates.
--NOT IN doesn't need the number of columns to match. It can compare only certain columns of each query. 
--
SELECT employee_name
FROM employees
WHERE employee_name NOT IN (SELECT former_employee_name FROM former_employees);

--
SELECT student_name, student_id
FROM students
WHERE (student_name, student_id) NOT IN (SELECT graduate_name, graduate_id FROM graduates);




--------------------------------- IF STATEMENTS
--Mention the Language
--when you create a user-defined function using the CREATE FUNCTION statement, it's necessary to specify the language of the function using the LANGUAGE clause.
--this tells PostgreSQL which procedural language the function is written in so that it can correctly interpret and execute the function's code.
CREATE OR REPLACE FUNCTION calculate_discount(price NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
  IF price > 100 THEN
    RETURN price * 0.9;
  END IF;
  -- If price is not greater than 100, the original price is returned.
  RETURN price;
END;
$$ LANGUAGE plpgsql;

-----
DO $$
DECLARE
  grade CHAR := 'B';
BEGIN
  IF grade = 'A' THEN
    RAISE NOTICE 'Excellent';
  ELSIF grade = 'B' THEN
    RAISE NOTICE 'Good';
  ELSIF grade = 'C' THEN
    RAISE NOTICE 'Fair';
  ELSE
    RAISE NOTICE 'Needs improvement';
  END IF;
END;
$$;

-----
DO $$
DECLARE
  product_price DECIMAL(10, 2) := 75.50;
BEGIN
  IF product_price > 50.00 THEN
    UPDATE products SET discount = 10 WHERE id = 123;
    RAISE NOTICE 'Applied a 10%% discount to product 123';
  END IF;
END;
$$;


---------------------------------- CASE STATEMENT
----
DO $$
DECLARE
  day_of_week INT := 3;  -- 1=Sunday, 2=Monday, ..., 7=Saturday
  day_type TEXT;
BEGIN
  CASE
    WHEN day_of_week IN (1, 7) THEN day_type := 'Weekend'
    WHEN day_of_week BETWEEN 2 AND 6 THEN day_type := 'Weekday'
    ELSE day_type := 'Invalid'
  END CASE;
  RAISE NOTICE 'Day type: %', day_type;
END;
$$;

----discounted price --> case statement
SELECT
  product_name,
  CASE
    WHEN price > 100 THEN price * 0.9
    ELSE price
  END AS discounted_price
FROM products;

----aggregation --> case statement
SELECT
  department,
  COUNT(*) AS total_employees,
  SUM(
    CASE
      WHEN salary >= 50000 THEN 1
      ELSE 0
    END
  ) AS high_salary_count
FROM employees
GROUP BY department;

----subqueries --> case statement
SELECT
  order_id,
  total_amount,
  CASE
    WHEN total_amount > (SELECT AVG(total_amount) FROM orders) THEN 'Above Average'
    ELSE 'Below Average'
  END AS order_status
FROM orders;

----update --> case statement
UPDATE products
SET
  discount = 
    CASE
      WHEN price > 100 THEN 10
      ELSE 5
    END;

--ordering --> case statement
SELECT
  employee_name,
  salary,
  CASE
    WHEN salary > 75000 THEN 1
    WHEN salary > 50000 THEN 2
    ELSE 3
  END AS salary_rank
FROM employees
ORDER BY salary_rank;



-------------------------------  SUBQUERIES
--Where to use a subquery:  SELECT(not recommended), FROM , WHERE, HAVING, INSERT, UPDATE, DELETE

--SELECT subquery. avoid if possible.
--MUST return only one value (one column, one row)
--task: fetch all employee details and add remarks to those who earn more than the average
SELECT *,
        (case when salary > (select avg(salary) from employee)
        then 'Higher than average'
        else null
        end) as remarks
FROM employee;

--HAVING subquery
--task: fetch stores who have sold more units than avg units sold by all stores
SELECT store_name, sum(quantity)
FROM sales
GROUP BY store_name
HAVING sum(quantity) > (select avg(quantity) from sales);

--INSERT subquery
--task: insert into a table without inserting duplicate records.
SELECT * FROM employee_history; 
SELECT e.emp_id, e.emp_name, d.dept_name, e.salary, d.location
FROM employee AS e
JOIN department AS d 
ON d.dept_name = e.dept_name
WHERE NOT EXISTS  (SELECT 1 
                    FROM employee_history AS eh
                    WHERE eh.emp_id = e.emp_id);

--UPDATE subquery
--task: give 10% salary increment to all employees in Bangalore Location based on the maximum salary earned by an employee in each dept. 
--      Only consider employees in employee_history table
UPDATE employee AS e
SET salary = (select max(salary) + (max(salary)*0.1)
                from employee_history AS eh
                where eh.dept_name = e.dept_name)
            where e.dept_name in (select dept_name
                                    from department
                                    where location = 'Bangalore')
                and e.emp_id in (select emp_id from employee_history);

--DELETE subquery
--task: delete all departments that do not have any employees.
DELETE FROM department
WHERE dept_name in (WHERE not exists (select dept_name 
                                        from department as d 
                                        where e.dept_name = d.dept_name));


--------------TYPES OF SUBQUERY
-- Scalar Subquery, Multiple Row Subquery, Correlated Subquery

-- Scalar Subquery: always returns one row and one column or NULL.
--The subquery(SCALAR) can refer to variables from the surrounding query, which will act as constants during any one evaluation of the subquery. 
--*task: return list of employees with salaries greater than the avg salary.
--approach #1
SELECT * 
FROM employee
WHERE salary > (select avg(salary) from employee);
--approach #2
SELECT e.*
FROM employee e
JOIN (select avg(salary) AS sal from employee) AS avg_sal
    ON e.salary > avg_sal.sal;

-----------
CREATE OR REPLACE FUNCTION concat_lower_or_upper(a text, b text, uppercase boolean DEFAULT false)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    result text;
BEGIN
    IF uppercase THEN
        result := UPPER(a || ' ' || b);
    ELSE
        result := LOWER(a || ' ' || b);
    END IF;

    RETURN result;
END;
$$;




--Multiple Row Subquery has different types:
-- subquery type 1: returns multiple columns and multiple rows
--*task: find employees earning the highes salary in each department
SELECT *
FROM employee
WHERE (dept_name, salary)  in  (SELECT dept_name, MAX(salary)
                                FROM employee
                                GROUP BY dept_name);
-- subquery type 2: returns only 1 column and multiple rows
--*task: find the department that does not have any employees
SELECT *
FROM department
WHERE dept_name NOT IN (SELECT DISTINCT dept_name FROM employee);

--Correlated Subquery: ((VERY INEFFICIENT, better use joins or other type of queries ))
--subquery that depends on values returned from the outer query.
--*find employees in each department who earn more than avg salary in that department
SELECT * 
FROM employee AS e1
WHERE salary > (SELECT AVG(salary) 
                FROM employee AS e2
                WHERE e2.dept_name = e1.dept_name);
--*find department with no employees
SELECT *
FROM department AS d
WHERE not exists (select 1 from emploee as e where e.dept_name = d.dept_name)

--Nested subqueries
--find stores whose sales are greater than overall average
--Approach:
--1)find total sales for each store.
--2)find avg sales for all stores.
--3)compare 1 & 2.
with sales as
    (select store_name, sum(price) as total_sales
        from sales
        group by store_name)

SELECT *
FROM sales
JOIN (select avg(total_sales) AS sales
        from sales AS x) AS avg_sales
ON sales.total_sales > avg_sales.sales;



------------------------------- TRIGGERS		
--NEW is a special keyword that represents the new (or updated) row that is being inserted, updated, or deleted in the trigger's associated table. 
--FOR EACH ROW WHEN (condition): This option combines row-level trigger behavior with a condition. The trigger fires for each row when the specified condition evaluates to true. 
--It allows you to selectively trigger the behavior based on row-specific conditions.
--Example:
--FOR EACH ROW WHEN (NEW.salary > 10000)"


--INSTEAD OF triggers:
--fires instead of triggering action 
--These triggers are used for views and are fired instead of the standard INSERT, UPDATE, or DELETE operations on the view.
--They allow you to implement custom logic to handle data changes on views, which are not inherently updatable in some cases.


--Check age	"
-- Create a table for user data
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    age INT
);

-- Create a BEFORE INSERT trigger
CREATE OR REPLACE FUNCTION check_age()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.age < 18 THEN
        RAISE EXCEPTION 'Age must be at least 18.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to the ""users"" table
CREATE TRIGGER check_age_trigger
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION check_age();


---- LOGGIN TRIGGER: 
--Create a trigger to log changes after an UPDATE or DELETE operation:	

CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO change_log (action, table_name, record_id, timestamp)
        VALUES ('UPDATE', TG_TABLE_NAME, OLD.id, NOW());
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO change_log (action, table_name, record_id, timestamp)
        VALUES ('DELETE', TG_TABLE_NAME, OLD.id, NOW());
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger to the table
CREATE TRIGGER log_changes_trigger
AFTER UPDATE OR DELETE ON my_table
FOR EACH ROW
EXECUTE FUNCTION log_changes();



------------------------ COMMON TABLE EXPRESSION   CTE ---------------------
--it can be referenced with select, insert, delete, update clauses that IMMEDIATELY FOLLOWS the CTE. 
--allows you to define a temporary result set within a SQL query. CTEs are often used to simplify complex queries, break them into smaller, more manageable parts, and make SQL code more readable. 
--CTEs are defined using the WITH clause and can reference themselves recursively in the case of recursive CTEs.

------------ updating CTEs
--updates on CTEs are allowed only when the change affects one of the maybe few tables involved in the CTE query.
--be careful when updating columns that use FKeys as you may be changing the actual table that the Fkey is referencing 
-- and by doing so you will be changing data that you dont want to.

--generic CTE syntax.......
WITH cte_name (column1, column2, ...) AS (
    -- CTE query goes here
)


---------------------------examples CTEs..............
WITH category_sales AS (
    SELECT category, SUM(sales) AS total_sales
    FROM sales_data
    GROUP BY category
)
SELECT category, total_sales
FROM category_sales;

--------------------------------MULTIPLE CTEs
WITH department_salaries AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
department_headcount AS (
    SELECT department_id, COUNT(*) AS employee_count
    FROM employees
    GROUP BY department_id
)
SELECT ds.department_id, avg_salary, employee_count
FROM department_salaries ds
JOIN department_headcount dh ON ds.department_id = dh.department_id;

--CTE --> find the stores where Total_sales > Avg_sales of all stores.
--WITH CLAUSE
with Total_Sales (store_id, total_sales_per_store) as
            (select s.store_id, sum(sales) as total_sales_per_store
            from sales as s 
            group by s.store_id),
    avg_sales (avg_sales_for_all_stores) as 
            (select cast(avg(total_sales_per_store) as INT) as avg_sales_for_all_stores
            from Total_Sales)

SELECT *
FROM Total_Sales AS ts 
JOIN avg_sales AS av 
on ts.total_sales_per_store > av.avg_sales_for_all_stores


	
------------------------PREPARED STATEMENTS	
--declare statement	
PREPARE my_statement (integer) AS
    SELECT * FROM my_table WHERE column_name = $1;

--execute statement	
EXECUTE my_statement(42);
	
--DO BLOCK	
-- Create a variable to store the result
DO $$
DECLARE
    result_variable text;
BEGIN
    -- Define the prepared statement
    PREPARE my_statement AS
        SELECT column_name FROM my_table WHERE condition;

    -- Execute the prepared statement and store the result in the variable
    EXECUTE my_statement;
    FETCH INTO result_variable;

    -- Output the result
    RAISE NOTICE 'Result: %', result_variable;
END;
$$;


----------------------- PROCEDURES
-- scalar functions can be used in SELECT and WHERE , stored procedures cannot.
--
--ADVANTAGES
/*
>execution plan retention and reusability
>reduces network traffic
>code reusability and better maintainability
>better security
>avoids sql injection attack
*/
-- syntax
CREATE OR REPLACE PROCEDURE pr_name (p_name varchar, p_age int)
LANGUAGE plpgsql
AS $$
DECLARE
    variables declarations
BEGIN
    procedure body -> all logics
END;
$$


----------------- procedure with no parametres
-- update the stock of a phone being sold
-- 1) create the procedure
CREATE OR REPLACE PROCEDURE procedure_sale_products()
LANGUAGE plpgsql
AS $$
DECLARE
    variable_product_code varchar(20);
    variable_price float;
BEGIN 
    SELECT product_code, price  
    INTO variable_product_code, variable_price
    FROM products
    WHERE product_name = 'iphone 13';

    INSERT INTO sales (order_date, product_code, quantity_ordered, sale_price)
        VALUES(CURRENT_DATE, variable_product_code, 1, (variable_price * 1));

    UPDATE products
    SET quantity_remaining = (quantity_remaining - 1),
        quantity_sold = (quantity_sold + 1)
    WHERE product_code = variable_product_code;

    RAISE NOTICE '¡¡¡ Product Sold !!!';
END;
$$
-- 2) call the procedure
CALL procedure_buy_products();




----------------- procedure with parametres
--This is a store that sells phones and laptops
--For every given product and the quantity:
    --* check if product is available based on the required quantity.
    --* if available, then modify the database tables accordingly.
CREATE OR REPLACE PROCEDURE procedure_buy_products(parameter_product_name VARCHAR, parameter_quantity INT)
LANGUAGE plpgsql
AS $$
DECLARE
    variable_product_code varchar(20);
    variable_price float;
    variable_count int;
BEGIN 
    -- check if the product asked for is in the inventory and if we have the quantity available
    SELECT count(1)
    INTO variable_count
    FROM products
    WHERE product_name = parameter_product_name
    AND quantity_remaining >= parameter_quantity; 
    
    -- if variable_count > 0 means that we have the product and quantity necessary for the sale
    IF variable_count > 0 
    THEN 
        SELECT product_code, price  
        INTO variable_product_code, variable_price
        FROM products
        WHERE product_name = parameter_product_name;
    
    -- insert a new sale into the sales table
        INSERT INTO sales (order_date, product_code, quantity_ordered, sale_price)
            VALUES(CURRENT_DATE, variable_product_code, parameter_quantity, (variable_price * parameter_quantity));
    
    -- update product stock in products table
        UPDATE products
        SET quantity_remaining = (quantity_remaining - parameter_quantity),
            quantity_sold = (quantity_sold + parameter_quantity)
        WHERE product_code = variable_product_code;
        RAISE NOTICE '¡¡¡ Product Sold !!!';
    
    ELSE
        RAISE NOTICE 'Insuficient Quantity!';
    END IF; 
END;
$$
-- 2) call the procedure
CALL procedure_sale_products('a_product_name', 2);


-- procedures with RETURN statement
CREATE OR REPLACE PROCEDURE get_employees_with_salary_above(threshold NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
        -- Return a result set of employees with salaries above the threshold
  RETURN QUERY SELECT id, name, salary FROM employees WHERE salary > threshold;
END;
$$;



--------------------------- FUNCTIONS  -------------------------------
--FUNCTION TEMPLATE
CREATE OR REPLACE FUNCTION func_name  (param_name1 datatype, param_name2 datatype....n)
RETURNS return_datatype
AS
$$
BEGIN
    <function_body_here>
END;
$$
LANGUAGE


--IF STATEMENT TEMPLATE
IF      <condition> THEN  <statements>
ELSIF   <condition> THEN  <statements>
ELSE    <statements>
END IF;


--RETURN A TABLE
CREATE OR REPLACE FUNCTION fn_getmovie_by_year(yr integer)
    returns table (movie_id integer,
                    movie_name character varying(60)
                    year_released integer)
AS
$$
BEGIN
    RETURN QUERY
    select m.movie_id,
            m.movie_name,
            m.year_released
    from movies as m
    where m.year_released = yr;
END;
$$
LANGUAGE plpgsql;
--> execute function:
SELECT * FROM fn_getmovie_by_year(1995);


----
CREATE OR REPLACE FUNCTION fnmake_full  (first_name varchar, last_name varchar)
RETURNS varchar
AS
$$
BEGIN
    IF      first_name is null and last_name is null THEN  return null;
    ELSIF   first_name is null and last_name is NOT null THEN  return null; THEN  return last_name;
    ELSIF   first_name is NOT null and last_name is null THEN  return null; THEN  return first_name;
    ELSE    return first_name || ' ' || last_name;
    END IF;
END;
$$
LANGUAGE
--CREATE  function	(scalar function)
CREATE OR REPLACE FUNCTION SP_calculate_total_price(quantity integer, unit_price numeric)
    RETURNS numeric AS $$
    BEGIN
        RETURN quantity * unit_price;
    END;
    $$ LANGUAGE plpgsql;
--CALLing function
SELECT SP_calculate_total_price (10,500)

--CREATE function, RETURNS TABLE  (inline table valued function)
CREATE OR REPLACE FUNCTION SP_get_employee_info(employee_id INT)
RETURNS TABLE (id INT, name VARCHAR, salary NUMERIC) AS $$
BEGIN
  RETURN QUERY SELECT id, name, salary FROM employees WHERE id = employee_id;
END;
$$ LANGUAGE plpgsql;

--SELECTING PROCEDURE
SELECT * FROM SP_get_employee_info(1);
    
-- assign the return of a FUNCTION to a VARIABLE
CREATE OR REPLACE FUNCTION get_employee_salary(employee_id INT) RETURNS NUMERIC AS $$
DECLARE
  salary NUMERIC;
BEGIN
  SELECT base_salary + bonus INTO salary FROM employees WHERE id = employee_id;
  RETURN salary;
END;
$$ LANGUAGE plpgsql;


-----------  SCALAR function -------------
-- it is a function that might take or not parameters and return a single (scalar) value.
-- scalar functions can be used in SELECT and WHERE , stored procedures cannot.


------------ INLINE TABLE VALUED function ---------------
-- return a table.
-- can be used to achieve the functionality of parameterized views.
-- the table returned can be used in joins with other tables
--return clause does not specify the structure of the table.
--more efficient than multistatement table valued functions.
--it is possible to update the underlying table
--SQL treats inlines like a View, that is why the efficiency.

------------- MULTISTATEMENT TABLE VALUED function -------------
-- returns a table, which structure you have specified in the return clause. 
-- multistatement table has BEGIN and END, inline table does not have them. 
--less efficients than inline table valued functions. 
--it NOT is possible to update the underlying table
--SQL treats these ones like stored procedures, thats why they are less efficient.



----------------------------- ERROR HANDLING -------------------
--**********************
DO $$ 
BEGIN
    -- Code that may cause an error
    -- ...

    EXCEPTION
        WHEN division_by_zero THEN
            -- Handle division by zero error
            RAISE NOTICE 'Division by zero error occurred';

        WHEN others THEN
            -- Handle other errors
            RAISE NOTICE 'An error occurred: %', SQLERRM;
END $$;

--********************      Using RAISE to Raise Custom Exceptions:
--You can use the RAISE statement to raise custom exceptions when a certain condition is met. 
--This can be helpful for signaling errors in your code:
CREATE OR REPLACE FUNCTION divide(a NUMERIC, b NUMERIC) 
RETURNS NUMERIC AS $$
BEGIN
    IF b = 0 THEN
        RAISE EXCEPTION 'Division by zero is not allowed';
    ELSE
        RETURN a / b;
    END IF;
END;
$$ LANGUAGE plpgsql;

--********************      Handling Errors in SQL Statements:
--You can also handle errors within SQL statements using error-checking functions like COALESCE, NULLIF, and CASE. 
--These functions allow you to control the behavior of your queries based on specific conditions.
--In this example, we use NULLIF to prevent division by zero and COALESCE to provide a default value in case of an error:
SELECT COALESCE(10 / NULLIF(0, 0), 1) AS result;





--DROP function	
--If the function has parameters, specify their data types. This part is optional 
---but can be used to ensure you are dropping the correct function if there are multiple functions with the same name but different parameter lists.
DROP FUNCTION calculate_total_price(integer, numeric);
DROP FUNCTION IF EXISTS calculate_total_price(integer, numeric);


---------------- FUNCTIONS using Python language
----FIRST MAKE SURE YOU HAVE THE EXTENSION INSTALLED
CREATE EXTENSION IF NOT EXISTS plpythonu;

----reverse a string
CREATE OR REPLACE FUNCTION reverse_string(input_text TEXT)
RETURNS TEXT AS $$
    return input_text[::-1]
$$ LANGUAGE plpythonu;

----generate random nums
CREATE OR REPLACE FUNCTION generate_random_numbers(count INT)
RETURNS INT[] AS $$
    import random
    return [random.randint(1, 100) for _ in range(count)]
$$ LANGUAGE plpythonu;


--------------------------------- WINDOW FUNCTIONS
/*
A window function performs a calculation across a set of table rows that are somehow related to the current row. 
This is comparable to the type of calculation that can be done with an aggregate function. 
However, window functions do not cause rows to become grouped into a single output row like non-window aggregate calls would. 
Instead, the rows retain their separate identities. 
Behind the scenes, the window function is able to access more than just the current row of the query result.
*/

-------TIPS
--Without ORDER BY, this means all rows of the partition are included in the window frame, since all rows become peers of the current row.
-- The rows considered by a window function are those of the “virtual table” produced by the query's FROM clause as filtered by its WHERE, GROUP BY, and HAVING clauses if any. 
-- We already saw that ORDER BY can be omitted if the ordering of rows is not important. It is also possible to omit PARTITION BY, in which case there is a single partition containing all rows.
-- By default, if ORDER BY is supplied then the frame consists of all rows from the start of the partition up through the current row, plus any following rows that are equal to the current row according to the ORDER BY clause. 
--When ORDER BY is omitted the default frame consists of all rows in the partition.

--Window functions are permitted only in the SELECT list and the ORDER BY clause of the query. They are forbidden elsewhere, such as in GROUP BY, HAVING and WHERE clauses.
--Also, window functions execute after non-window aggregate functions. This means it is valid to include an aggregate function call in the arguments of a window function, but not vice versa.



----------------------- useful SELECT subquery with Window functions
-- help us filtrating after window function has been computed.
SELECT depname, empno, salary, enroll_date
FROM
  (SELECT depname, empno, salary, enroll_date,
          rank() OVER (PARTITION BY depname ORDER BY salary DESC, empno) AS pos
     FROM empsalary
  ) AS ss
WHERE pos < 3;

------------------------ multiple window functions in select
-- create the window frame and assign it to 'w' , then reference it in the select where the window function goes
SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);


-- OVER() STATEMENT 
--DEFAULT FRAME CLAUSE in over() statement
over(range between unbounded preceding and current row)
--from first in the frame until last in the frame
over(range between unbounded preceding and unbounded following)
over(rows between unbounded preceding and unbounded following)
--from number of rows before and after current row
over(range between 2 preceding and 2 following)
over(rows   between 2 preceding and 2 following)

--------------------- FRAMES  --> RANGE and ROWS difference
"RANGE fija el FRAME basado en el VALOR de la fila actual
ROWS fija el FRAME basado en numero de rows, no en su valor"
--***In ROWS mode, the offset must yield a non-null, non-negative integer, and the option means that the frame starts or ends the specified number of rows before or after the current row.
--***In GROUPS mode, the offset again must yield a non-null, non-negative integer, and the option means that the frame starts or ends the specified number of peer groups before or after the current row's peer group, 
--where a peer group is a set of rows that are equivalent in the ORDER BY ordering. (There must be an ORDER BY clause in the window definition to use GROUPS mode.)
--***In RANGE mode, these options require that the ORDER BY clause specify exactly one column. The offset specifies the maximum difference between the value of that column in the current row and its value in preceding or following rows of the frame. 
--The data type of the offset expression varies depending on the data type of the ordering column. For numeric ordering columns it is typically of the same type as the ordering column, but for datetime ordering columns it is an interval. For example, if the ordering column is of type date or timestamp, one could write RANGE BETWEEN '1 day' PRECEDING AND '10 days' FOLLOWING. 
--The offset is still required to be non-null and non-negative, though the meaning of “non-negative” depends on its data type.

-------- EXCLUSION
--The frame_exclusion option allows rows around the current row to be excluded from the frame, even if they would be included according to the frame start and frame end options. EXCLUDE CURRENT ROW excludes the current row from the frame. EXCLUDE GROUP excludes the current row and its ordering peers from the frame. EXCLUDE TIES excludes any peers of the current row from the frame, but not the current row itself. 
--EXCLUDE NO OTHERS simply specifies explicitly the default behavior of not excluding the current row or its peers.

"nth_value()→ anyelement is used to retrieve the value of a specified expression from the nth row in the current window frame.
    Takes two arguments: the expression to retrieve and the position of the row within the window frame.
    ***Returns value evaluated at the row that is the n'th row of the window frame (counting from 1); returns NULL if there is no such row.
    ¡¡ojo!! If the nth location is out of bound, it will return NULL as the value
    ¡¡ojo!! values for the rows before reaching nth row might be NULL"
--following query, nth_value(score, (COUNT(*) + 1) / 2) retrieves the score from the row that corresponds to the median position in the ordered result set. The (COUNT(*) + 1) / 2 formula calculates the median position.
SELECT
    test_id,
    score,
    nth_value(score, (COUNT(*) + 1) / 2) OVER (ORDER BY score) AS median_score
FROM test_scores;
--In this query, nth_value(employee_name, 1) retrieves the employee's name from the first row in each department's partition, ordered by hire date in descending order. 
--This effectively identifies the last employee hired in each department.
SELECT
    employee_name,
    department,
    hire_date,
    nth_value(employee_name, 1) OVER (PARTITION BY department ORDER BY hire_date DESC) AS last_employee_in_department
FROM employee_details;

"ROW_NUMBER()→ bigint: Returns the number of the current row within its partition, counting from 1."
--following query assigns a unique row number to each employee based on their salary, ordered in descending order.
SELECT
    employee_id,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

"RANK()→ bigint: Returns the rank of the current row, with gaps; that is, the row_number of the first row in its peer group.
                Assigns a unique rank to each row, with equal values receiving the same rank and leaving gaps in the sequence.
                FORMULA = (rank-1) / (total rows -1)  Result between 0 and 1"
--This query assigns a rank to employees within each department based on their salary.
--Equal salaries receiving the same rank.
SELECT
    department,
    employee_name,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employee_details;

"DENSE_RANK()→ bigint: Similar to RANK(), but assigns consecutive ranks to equal values without gaps."
--This query assigns a dense rank to employees based on their salary in descending order, without any gaps in the ranking.
SELECT
    department,
    employee_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_salary_rank
FROM employee_details;

"NTILE(num_buckets integer )→ integer: Divides the result set into 'n' approximately equal parts and assigns a bucket number to each row.
            Returns an integer ranging from 1 to the argument value, dividing the partition as equally as possible."
--This query divides products into four price buckets based on their price, ensuring approximately equal distribution.
SELECT
    product_name,
    price,
    NTILE(4) OVER (ORDER BY price) AS price_bucket
FROM products;

"LAG(column, offset, default)→ anycompatible: Retrieves the value of a specified column from the previous row within the partition.
                    Returns value evaluated at the row that is offset rows before the current row within the partition; if there is no such row, instead returns default (which must be of a type compatible with value). 
                    Both offset and default are evaluated with respect to the current row. If omitted, offset defaults to 1 and default to NULL."
--This query retrieves the previous order date for each order within the same customer's partition.
SELECT
    order_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
FROM orders;

"LEAD(column, offset, default)→ anycompatible: Retrieves the value of a specified column from the next row within the partition.
                Returns value evaluated at the row that is offset rows after the current row within the partition; if there is no such row, instead returns default (which must be of a type compatible with value). 
                Both offset and default are evaluated with respect to the current row. If omitted, offset defaults to 1 and default to NULL."
--This query retrieves the next order date for each order within the same customer's partition.
SELECT
    order_id,
    order_date,
    LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
FROM orders;

"FIRST_VALUE(column)→ anyelement: Returns the value of the specified column from the first row in the window frame."
SELECT
    category,
    product_name,
    price,
    FIRST_VALUE(product_name) OVER (PARTITION BY category ORDER BY price) AS cheapest_product
FROM products;

"LAST_VALUE(column)→ anyelement: Returns the value of the specified column from the last row in the window frame."
SELECT
    category,
    product_name,
    price,
    LAST_VALUE(product_name) OVER (PARTITION BY category ORDER BY price) AS most_expensive_product
FROM products;

"SUM(column): Calculates the sum of values in a specified column within the window frame."
--This query calculates the total salary for each department by summing the salaries of employees within each department.
SELECT
    department,
    employee_name,
    salary,
    SUM(salary) OVER (PARTITION BY department) AS department_total_salary
FROM employee_details;

------------------------- for when there is NULL values  SALESSSSSSSSSSSSSSSSSSSSSS
CREATE OR REPLACE VIEW vTotalSalesByProduct AS
SELECT
    t2.name,
    SUM(COALESCE(t1.quantitysold * t1.unitprice, 0)) AS totalsales,
    COUNT(*) AS totaltransactions  --we might need to have this count alwayssssss
FROM
    tabla1 t1
JOIN
    tabla2 t2 ON t1.product_id = t2.product_id
GROUP BY
    t2.name;


"AVG(column): Calculates the average of values in a specified column within the window frame."
--This query calculates the average salary for each department by averaging the salaries of employees within each department.
SELECT
    department,
    employee_name,
    salary,
    AVG(salary) OVER (PARTITION BY department) AS department_avg_salary
FROM employee_details;

"COUNT(column): Counts the number of non-null values in a specified column within the window frame."
--This query counts the number of employees in each department by counting the non-null "employee_id" values within each department.
SELECT
    department,
    employee_name,
    COUNT(employee_id) OVER (PARTITION BY department) AS department_employee_count
FROM employee_details;

"MIN(column): Retrieves the minimum value from a specified column within the window frame."
--This query retrieves the minimum salary within each department by finding the lowest salary value within each department.
SELECT
    department,
    employee_name,
    MIN(salary) OVER (PARTITION BY department) AS department_min_salary
FROM employee_details;

"MAX(column): Retrieves the maximum value from a specified column within the window frame."
--This query retrieves the maximum salary within each department by finding the highest salary value within each department.
SELECT
    department,
    employee_name,
    MAX(salary) OVER (PARTITION BY department) AS department_max_salary
FROM employee_details;

"PERCENT_RANK()→ double precision: Calculates the relative rank of a row within the window frame as a percentage.
                Returns the relative rank of the current row, that is (rank - 1) / (total partition rows - 1). The value thus ranges from 0 to 1 inclusive."
--This query calculates the percentile rank of each employee's salary within their department, ordered by salary in descending order.
SELECT
    department,
    employee_name,
    salary,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS percentile_rank
FROM employee_details;

"CUME_DIST()→ double precision: Calculates the cumulative distribution of rows within the window frame as a percentage.
                Returns the cumulative distribution, that is (number of partition rows preceding or peers with current row) / (total partition rows). The value thus ranges from 1/N to 1."
--This query calculates the cumulative distribution of salaries within each department, ordered by salary in ascending order.
SELECT
    department,
    employee_name,
    salary,
    CUME_DIST() OVER (PARTITION BY department ORDER BY salary ASC) AS cumulative_distribution
FROM employee_details;

"MODE(): Returns the most frequent value within the window frame."
--This query identifies the most frequent (mode) salary value within each department based on the employee's salary.
SELECT
    department,
    employee_name,
    salary,
    MODE() WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) AS department_mode_salary
FROM employee_details;

--- still WINDOW FUNCTION.......................
-- first_value , last_value, nth_value 
SELECT *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w as least_exp_product,
nth_value(product_name,5) over w as second_most_exp_product
from product_name
window w as (partition by product_category order by price desc 
            range between unbounded preceding and unbounded following)



-------------------------- INDEXES

"
INDEX
It is a look up guide to find the info you want. 
A table without an index is known as a HEAP and it will go through every piece of info when it is looking for something. Needs more computational resources.

Clustered Index:
Defines the order of physically stored data in a table. 
Pkeys add a clustered index to the table by default.
This indexes are part of the table itself.
There can be only one clustered index per table.
You want them to be assigned to columns whose values are unique, incrementing, unchanging

Non-Clustered Index:
They are stored separately and act as a reference guide. 
They do not determine the physical order of a table, it is just a look up, a reference.
There can be multiple non-clustered indexes per table, unlike clustered indexes.
You want them to be those columns that you are constantly accessing. 

Maintenance.
Indexes are separate entities in the db so they will need to be maintained. 

"
-- might be created on TABLES or VIEWS



---- indexes associated with a table.
SELECT * FROM pg_indexes WHERE tablename = 'table_name';
SELECT index_name FROM pg_indexes WHERE tablename = 'table_name';

-- list unused indexes
SELECT schemaname, tablename, indexname FROM pg_stat_user_indexes WHERE idx_scan = 0;

--create index of a column
CREATE INDEX index_name ON table_name (column_name);

--detailed information about a specific index,
\di+ index_name

--drop index
DROP INDEX index_name;

--disable index temporarily
ALTER INDEX index_name DISABLE;
--enable index
ALTER INDEX index_name ENABLE;

--rebuild index
REINDEX INDEX index_name;




-------------------------- INHERITANCE
--In this case, a row of capitals inherits all columns (name, population, and elevation) from its parent, cities.
--The capitals table has an additional column, state, which shows its state abbreviation. In PostgreSQL, a table can inherit from zero or more other tables.

CREATE TABLE cities (
  name       text,
  population real,
  elevation  int     -- (in ft)
);

CREATE TABLE capitals (
  state      char(2) UNIQUE NOT NULL
) INHERITS (cities);

--For example, the following query finds the names of all cities, including state capitals, that are located at an elevation over 500 feet:

SELECT name, elevation
  FROM cities
  WHERE elevation > 500;

--On the other hand, the following query finds all the cities that are not state capitals and are situated at an elevation over 500 feet:
--Here the ONLY before cities indicates that the query should be run over only the cities table, and not tables below cities in the inheritance hierarchy. 
--Many of the commands that we have already discussed — SELECT, UPDATE, and DELETE — support this ONLY notation.
SELECT name, elevation
    FROM ONLY cities
    WHERE elevation > 500;















-------------------------- SCHEMA
--create schema
CREATE SCHEMA new_schema;
--switch schema in a session:
SET search_path TO new_schema, public
--rename schema:
ALTER SCHEMA old_schema RENAME TO renamed_schema;
--list schemas in current database:
SELECT schema_name FROM information_schema.schemata;
--Set Default Schema for a User:
ALTER USER username SET search_path TO new_schema, public;
--drop a schema:  
--The CASCADE option is used to remove dependent objects as well.
DROP SCHEMA if exists old_schema CASCADE;
--playing with an specific schema:
INSERT INTO new_schema.my_table (name) VALUES ('John');
SELECT * FROM new_schema.my_table;
CREATE TABLE new_schema.my_table (
    id serial PRIMARY KEY,
    name varchar(255)
);


--------------------------- SEARCH PATH   ------------------
--show SEARCH PATH
SHOW search_path;
--change schema search path
SET search_path = schema_name;
-- alter search path
ALTER ROLE username SET search_path TO schemaname;


--------------------------QUERY----------------------------
--EXPLAIN query
EXPLAIN some_query_you_want__to_analize;



-------------------------- ACCESSING POSTGRES 
----
----    sudo -u postgres psql
----    sudo mysql
----
\l                          -- list databases
\c my_new_database          -- connect to a database
\d table_name               -- table info
\d+ table_name              -- table details
\dt                         -- tables in current db
\du                         -- list of roles
\di                         -- indexes in current database
\di+ my_index               -- detailed info from an index 
\df+ my_function            -- definition of a function
\dn                         -- schemas in current database
\dE                         -- foreign tables from other databases in the current database                    
\dm                         -- list of views in current database
\ds                         -- list Sequences/Pkey
\du+                        -- list users and their associated roles
\dx                         -- list extentions
\i my_script.sql            -- execute external sql files
---returns size of the table's data and the total size in bytes, including indexes and associated objects.
SELECT pg_table_size('table_name') AS table_size, pg_total_relation_size('table_name') AS total_size;
--

-------------------------- USER
\du user_name               -- list roles and their attributes
\du+                        -- list users and their associated roles
\dg role_name               -- roles and their attributes
-- current user
SELECT current_user;
--create role
CREATE ROLE username WITH LOGIN PASSWORD 'password';
--change password
ALTER USER username PASSWORD 'new_password';
--grant a privilege
ALTER ROLE username SUPERUSER;
-- granting priviledes
GRANT CONNECT ON DATABASE dbname TO username;
GRANT ALL PRIVILEGES ON SCHEMA schemaname TO username;
GRANT SELECT ON TABLE tablename TO username;
REVOKE SELECT ON TABLE tablename FROM username;
-- alter search path
ALTER ROLE username SET search_path TO schemaname;
--list all roles (users and groups) in the database cluster
SELECT rolname FROM pg_roles;
--list all users
SELECT usename FROM pg_user;
-- delete role
DROP ROLE username CASCADE;


-------------------------- CONFIGURATION
-- show current overall configuration
SHOW ALL;
-- change config settings (e.g.)
SET configuration_setting = new_value;
-- usename, client_addr (IP), client_port, backend_type
SELECT usename, client_addr, client_port, backend_type FROM pg_stat_activity;


-------------------------- DATABASE CONNECTION 
--
psql -h 'host_name' -U 'postgres_username' -d 'db_you_want_to_connect_to'
psql -h avanzatech.cfpcm0h6wspe.us-east-2.rds.amazonaws.com -U student_1 -d student_1_opt_lab

-------------------------- DATABASE	
-- whenever a database is created, 2 files are created:
--      * .MDF file. which is the Master Data File , it contains the actual data
--      * .LDF file. which is the transaction log file, it is used to recover the database.

CREATE DATABASE database_name;                      
SELECT current_database();                          -- CURRENT database
SELECT pg_terminate_backend (pg_backend_pid());     --DISCONNECT from current database
ALTER DATABASE old_name RENAME TO new_name;         --RENAME database	
ALTER DATABASE database_name OWNER TO new_owner;    --CHANGE OWNER of database	
ALTER DATABASE database_name OWNER TO CURRENT_USER; --CHANGE OWNER to current user
-- database SIZE
SELECT pg_size_pretty(pg_database_size(datname)) AS size, datname FROM pg_database;

-------------------------- DATABASE --> FIND OWNER of current database 
SELECT u.usename                                    
 FROM pg_database d
  JOIN pg_user u ON (d.datdba = u.usesysid)
 WHERE d.datname = (SELECT current_database());

DROP DATABASE database_name;                            --DROP database	
pg_dump -U username -d database_name -f backup_file.sql --BACKUP a database	
psql -U username -d database_name -f backup_file.sql    --RESTORE a database	
ANALYZE database_name;                                  --ANALIZE database	

-------------------------- DATABASE --> BRING FOREIGN DATABASE	
SELECT * 
FROM dblink (
'dbname = somedb
port=5432 host=someserver
user=someuser
password=somepwd ' ,
'SELECT gid, area, perimeter, state,county, tract, blockgroup, block, the_geom
FROM  massgis.cens2000blocks')  
AS blockgroups



--------------------------- PG_DUMP
--is used to create backups of PostgreSQL databases, and it allows you to export database objects, 
--including tables, data, and schema definitions, to a file that can later be used for database restoration.
--backup, -d option specifies the database name and direct the output to a file using the -f option.
pg_dump -d your_database -f backup_file.sql
--in combination with tools like gzip or bzip2 to create compressed backup files.
pg_dump -d your_database | gzip > backup_file.sql.gz
--by default, pg_dump includes both schema definitions and data. For only schema definitions, use -s option:
pg_dump -d your_database -s -f schema_only.sql
--backup a remote database specifying the connection parameters with -h, -p, -U, and -d options.
pg_dump -h remote_host -p 5432 -U remote_user -d remote_database -f remote_backup.sql
--pg_dump supports a custom format (-Fc) that allows you to create more flexible and efficient backups.
pg_dump -d your_database -Fc -f custom_format.backup
--backup only a single table from a database, specify the table name with the -t option.
pg_dump -d your_database -t your_table -f table_backup.sql


--------------------------- PG_RESTORE
-- restore a PostgreSQL database from a backup file, you can use the following command:
-----replace your_database with the name of the target database.
-----replace your_user with the username used to connect to the database.
-----replace backup_file.sql with the name of the backup file.
pg_restore -d your_database -U your_user backup_file.sql
--If you created a custom format backup using pg_dump
pg_restore -d your_database -U your_user -Fc custom_format.backup
--backup to a remote database, specify connection parameters with -h (host) and -p (port) options:
pg_restore -h remote_host -p 5432 -d remote_database -U remote_user remote_backup.sql
-- restore only the schema definitions (no data), you can use the -s option:
pg_restore -d your_database -U your_user -s schema_only.sql
--restore a single table from a backup, specify the table name with the -t option:
pg_restore -d your_database -U your_user -t your_table table_backup.sql
--restore the database objects to a different schema using the -n option:
pg_restore -d your_database -U your_user -n new_schema backup_file.sql

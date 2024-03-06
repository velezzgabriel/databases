--

/*

1581. Customer Who Visited but Did Not Make Any Transactions

Table: Visits
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| visit_id    | int     |
| customer_id | int     |
+-------------+---------+
visit_id is the column with unique values for this table.
This table contains information about the customers who visited the mall.

Table: Transactions
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| transaction_id | int     |
| visit_id       | int     |
| amount         | int     |
+----------------+---------+
transaction_id is column with unique values for this table.
This table contains information about the transactions made during the visit_id.
 
Write a solution to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.
Return the result table sorted in any order.
The result format is in the following example.

Example 1:
Input: 
Visits
+----------+-------------+
| visit_id | customer_id |
+----------+-------------+
| 1        | 23          |
| 2        | 9           |
| 4        | 30          |
| 5        | 54          |
| 6        | 96          |
| 7        | 54          |
| 8        | 54          |
+----------+-------------+
Transactions
+----------------+----------+--------+
| transaction_id | visit_id | amount |
+----------------+----------+--------+
| 2              | 5        | 310    |
| 3              | 5        | 300    |
| 9              | 5        | 200    |
| 12             | 1        | 910    |
| 13             | 2        | 970    |
+----------------+----------+--------+
Output: 
+-------------+----------------+
| customer_id | count_no_trans |
+-------------+----------------+
| 54          | 2              |
| 30          | 1              |
| 96          | 1              |
+-------------+----------------+

*/
--create table 'Visits'
CREATE TABLE IF NOT EXISTS platzi."Visits"
(    visit_id integer NOT NULL DEFAULT nextval('platzi."Visits_visit_id_seq"'::regclass),
    customer_id integer NOT NULL,
    CONSTRAINT visits_pkey PRIMARY KEY (visit_id));
--populate table


--create table 'Transactions'
CREATE TABLE IF NOT EXISTS platzi."Transactions"
(
    transaction_id integer NOT NULL DEFAULT nextval('platzi."Transactions_transaction_id_seq"'::regclass),
    visit_id integer NOT NULL,
    CONSTRAINT "Transactions_pkey" PRIMARY KEY (transaction_id),
    CONSTRAINT "Transaction_Visits_fkey" FOREIGN KEY (visit_id)
        REFERENCES platzi."Visits" (visit_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
)


--------------------- solution --------------------------

select v.customer_id, count(v.customer_id) as count_no_trans
from visits v
left join transactions t
on v.visit_id = t.visit_id
where t.transaction_id is null
group by v.customer_id
order by count_no_trans desc;




/*
197. Rising Temperature
Table: Weather
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| recordDate    | date    |
| temperature   | int     |
+---------------+---------+
id is the column with unique values for this table.
This table contains information about the temperature on a certain day.
 
Write a solution to find all dates' Id with higher temperatures compared to its previous dates (yesterday).
Return the result table in any order.
 

Example 1:
Input: 
Weather table:
+----+------------+-------------+
| id | recordDate | temperature |
+----+------------+-------------+
| 1  | 2015-01-01 | 10          |
| 2  | 2015-01-02 | 25          |
| 3  | 2015-01-03 | 20          |
| 4  | 2015-01-04 | 30          |
+----+------------+-------------+
Output: 
+----+
| id |
+----+
| 2  |
| 4  |
+----+
Explanation: 
In 2015-01-02, the temperature was higher than the previous day (10 -> 25).
In 2015-01-04, the temperature was higher than the previous day (20 -> 30).
*/
CREATE TABLE IF NOT EXISTS platzi.weather
(
    id integer NOT NULL DEFAULT nextval('platzi.weather_id_seq'::regclass),
    "record_Date" date NOT NULL,
    temperature integer NOT NULL,
    CONSTRAINT weather_pkey PRIMARY KEY (id)
)

insert into weather values 
(1,'2015-01-01',10),         
(2,'2015-01-02',25),        
(3,'2015-01-03',20),     
(4,'2015-01-04',30);

--------------------- solution --------------------------

select w2.id
from weather w1, weather w2
where w2."record_Date"- interval '1 day' =w1."record_Date"
	and w2.temperature > w1.temperature;



/*
1661. Average Time of Process per Machine
Table: Activity
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| machine_id     | int     |
| process_id     | int     |
| activity_type  | enum    |
| timestamp      | float   |
+----------------+---------+
The table shows the user activities for a factory website.
(machine_id, process_id, activity_type) is the primary key (combination of columns with unique values) of this table.
machine_id is the ID of a machine.
process_id is the ID of a process running on the machine with ID machine_id.
activity_type is an ENUM (category) of type ('start', 'end').
timestamp is a float representing the current time in seconds.
'start' means the machine starts the process at the given timestamp and 'end' means the machine ends the process at the given timestamp.
The 'start' timestamp will always be before the 'end' timestamp for every (machine_id, process_id) pair.
 

There is a factory website that has several machines each running the same number of processes. 
Write a solution to find the average time each machine takes to complete a process.
The time to complete a process is the 'end' timestamp minus the 'start' timestamp. 
The average time is calculated by the total time to complete every process on the machine divided by the number of processes that were run.
The resulting table should have the machine_id along with the average time as processing_time, which should be rounded to 3 decimal places.
Return the result table in any order.

Example 1:

Input: 
Activity table:
+------------+------------+---------------+-----------+
| machine_id | process_id | activity_type | timestamp |
+------------+------------+---------------+-----------+
| 0          | 0          | start         | 0.712     |
| 0          | 0          | end           | 1.520     |
| 0          | 1          | start         | 3.140     |
| 0          | 1          | end           | 4.120     |
| 1          | 0          | start         | 0.550     |
| 1          | 0          | end           | 1.550     |
| 1          | 1          | start         | 0.430     |
| 1          | 1          | end           | 1.420     |
| 2          | 0          | start         | 4.100     |
| 2          | 0          | end           | 4.512     |
| 2          | 1          | start         | 2.500     |
| 2          | 1          | end           | 5.000     |
+------------+------------+---------------+-----------+
Output: 
+------------+-----------------+
| machine_id | processing_time |
+------------+-----------------+
| 0          | 0.894           |
| 1          | 0.995           |
| 2          | 1.456           |
+------------+-----------------+
Explanation: 
There are 3 machines running 2 processes each.
Machine 0's average time is ((1.520 - 0.712) + (4.120 - 3.140)) / 2 = 0.894
Machine 1's average time is ((1.550 - 0.550) + (1.420 - 0.430)) / 2 = 0.995
Machine 2's average time is ((4.512 - 4.100) + (5.000 - 2.500)) / 2 = 1.456

*/

CREATE TABLE IF NOT EXISTS platzi.activity_table
(
    machine_id integer NOT NULL,
    process_id integer NOT NULL,
    activity_type character varying(10) COLLATE pg_catalog."default" NOT NULL,
    "timestamp" real NOT NULL
)

insert into activity_table values
( 0     ,       0   ,       'start'   ,     0.712     ),
(0       ,    0     ,      'end'        ,    1.520     ),
( 0       ,    1    ,       'start'     ,     3.140     ),
( 0        ,   1    ,       'end'       ,     4.120     ),
( 1       ,    0    ,       'start'     ,     0.550     ),
( 1       ,    0    ,       'end'       ,     1.550     ),
( 1       ,    1    ,       'start'     ,     0.430     ),
( 1       ,    1    ,       'end'       ,     1.420     ),
( 2       ,    0    ,       'start'     ,     4.100    ) ,
( 2       ,    0    ,       'end'       ,     4.512   )  ,
( 2       ,    1    ,       'start'     ,     2.500  )   ,
( 2       ,    1    ,       'end'       ,     5.000  ) ;


--------------------- solution --------------------------


select  a1.machine_id, round(avg(a2.timestamp-a1.timestamp), 3) as processing_time
from activity_table a1
join activity_table a2 
on a1.machine_id=a2.machine_id and a1.process_id=a2.process_id
and a1.activity_type='start' and a2.activity_type='end'
group by a1.machine_id








/*
577. Employee Bonus
Table: Employee
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| empId       | int     |
| name        | varchar |
| supervisor  | int     |
| salary      | int     |
+-------------+---------+
empId is the column with unique values for this table.
Each row of this table indicates the name and the ID of an employee in addition to their salary and the id of their manager.

Table: Bonus
+-------------+------+
| Column Name | Type |
+-------------+------+
| empId       | int  |
| bonus       | int  |
+-------------+------+
empId is the column of unique values for this table.
empId is a foreign key (reference column) to empId from the Employee table.
Each row of this table contains the id of an employee and their respective bonus.
 

Write a solution to report the name and bonus amount of each employee with a bonus less than 1000.


Example 1:
Input: 
Employee table:
+-------+--------+------------+--------+
| empId | name   | supervisor | salary |
+-------+--------+------------+--------+
| 3     | Brad   | null       | 4000   |
| 1     | John   | 3          | 1000   |
| 2     | Dan    | 3          | 2000   |
| 4     | Thomas | 3          | 4000   |
+-------+--------+------------+--------+
Bonus table:
+-------+-------+
| empId | bonus |
+-------+-------+
| 2     | 500   |
| 4     | 2000  |
+-------+-------+
Output: 
+------+-------+
| name | bonus |
+------+-------+
| Brad | null  |
| John | null  |
| Dan  | 500   |
+------+-------+
*/

CREATE TABLE IF NOT EXISTS platzi.employee
(
    "empId" integer NOT NULL,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    supervisor integer NOT NULL,
    salary integer NOT NULL,
    CONSTRAINT "empId_unique" UNIQUE ("empId")
)

CREATE TABLE IF NOT EXISTS platzi.bonus
(
    "empId" integer NOT NULL,
    bonus integer NOT NULL,
    CONSTRAINT bonus_employee_fkey FOREIGN KEY ("empId")
        REFERENCES platzi.employee ("empId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

insert into employee values 
( 3   ,   'Brad'   , null  ,      4000  ), 
( 1   ,   'John'   , 3     ,      1000 ) , 
( 2   ,   'Dan'    , 3     ,      2000)  , 
( 4   ,   'Thomas' , 3     ,      4000)  ; 

insert into bonus values
(2,500),(4,2000);

--------------------- solution --------------------------

select e.name, b.bonus
from employee e
left join bonus b
on e."empId" = b."empId"
where bonus<1000 or bonus is null
order by bonus;


/*
1280. Students and Examinations
Table: Students
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| student_id    | int     |
| student_name  | varchar |
+---------------+---------+
student_id is the primary key (column with unique values) for this table.
Each row of this table contains the ID and the name of one student in the school.
 

Table: Subjects
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| subject_name | varchar |
+--------------+---------+
subject_name is the primary key (column with unique values) for this table.
Each row of this table contains the name of one subject in the school.
 

Table: Examinations
+-------------+---------+
| Column Name  | Type    |
+--------------+---------+
| student_id   | int     |
| subject_name | varchar |
+--------------+---------+
There is no primary key (column with unique values) for this table. It may contain duplicates.
Each student from the Students table takes every course from the Subjects table.
Each row of this table indicates that a student with ID student_id attended the exam of subject_name.
 

Write a solution to find the number of times each student attended each exam.
Return the result table ordered by student_id and subject_name.
The result format is in the following example.

 
Example 1:
Input: 
Students table:
+------------+--------------+
| student_id | student_name |
+------------+--------------+
| 1          | Alice        |
| 2          | Bob          |
| 13         | John         |
| 6          | Alex         |
+------------+--------------+
Subjects table:
+--------------+
| subject_name |
+--------------+
| Math         |
| Physics      |
| Programming  |
+--------------+
Examinations table:
+------------+--------------+
| student_id | subject_name |
+------------+--------------+
| 1          | Math         |
| 1          | Physics      |
| 1          | Programming  |
| 2          | Programming  |
| 1          | Physics      |
| 1          | Math         |
| 13         | Math         |
| 13         | Programming  |
| 13         | Physics      |
| 2          | Math         |
| 1          | Math         |
+------------+--------------+
Output: 
+------------+--------------+--------------+----------------+
| student_id | student_name | subject_name | attended_exams |
+------------+--------------+--------------+----------------+
| 1          | Alice        | Math         | 3              |
| 1          | Alice        | Physics      | 2              |
| 1          | Alice        | Programming  | 1              |
| 2          | Bob          | Math         | 1              |
| 2          | Bob          | Physics      | 0              |
| 2          | Bob          | Programming  | 1              |
| 6          | Alex         | Math         | 0              |
| 6          | Alex         | Physics      | 0              |
| 6          | Alex         | Programming  | 0              |
| 13         | John         | Math         | 1              |
| 13         | John         | Physics      | 1              |
| 13         | John         | Programming  | 1              |
+------------+--------------+--------------+----------------+

*/


CREATE TABLE IF NOT EXISTS platzi.students
(
    student_id integer NOT NULL,
    student_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT student_name_pkey PRIMARY KEY (student_id)
)

CREATE TABLE IF NOT EXISTS platzi.subjects
(
    subject_name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT subject_name_pkey PRIMARY KEY (subject_name)
)

CREATE TABLE IF NOT EXISTS platzi.examinations
(
    student_id integer NOT NULL,
    subject_name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT examinations_students_fkey FOREIGN KEY (student_id)
        REFERENCES platzi.students (student_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT examinations_subjects_fkey FOREIGN KEY (subject_name)
        REFERENCES platzi.subjects (subject_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)


--------------------- solution --------------------------
select s.student_id, s.student_name, sub.subject_name, count(ex.student_id) as attended_exams
from students s
cross join subjects sub

left join examinations ex
on s.student_id = ex.student_id and sub.subject_name = ex.subject_name
group by s.student_id, s.student_name, sub.subject_name
order by s.student_id;





/*
570. Managers with at Least 5 Direct Reports
Table: Employee
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
| department  | varchar |
| managerId   | int     |
+-------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table indicates the name of an employee, their department, and the id of their manager.
If managerId is null, then the employee does not have a manager.
No employee will be the manager of themself.
 

Write a solution to find managers with at least five direct reports.
Return the result table in any order.
The result format is in the following example.

Example 1:
Input: 
Employee table:
+-----+-------+------------+-----------+
| id  | name  | department | managerId |
+-----+-------+------------+-----------+
| 101 | John  | A          | None      |
| 102 | Dan   | A          | 101       |
| 103 | James | A          | 101       |
| 104 | Amy   | A          | 101       |
| 105 | Anne  | A          | 101       |
| 106 | Ron   | B          | 101       |
+-----+-------+------------+-----------+
Output: 
+------+
| name |
+------+
| John |
+------+
*/


CREATE TABLE IF NOT EXISTS platzi.employee2
(
    id integer NOT NULL,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    department character varying(30) COLLATE pg_catalog."default" NOT NULL,
    managerid integer NOT NULL,
    CONSTRAINT employee2_pkey PRIMARY KEY (id)
)

--------------------- solution #1 --------------------------

select tabla.name 
from (select e.name, count(e2.managerid) as counter
from employee2 e
join employee2 e2
on e.id = e2.managerid
group by e.name, e2.managerid) as tabla
where counter >= 5;


--------------------- solution #2 --------------------------

select name 
from employee2 
where id in
(select managerid 
from employee2
Group by managerid
Having count(managerid)>=5);




/*
1934. Confirmation Rate
Table: Signups
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| user_id        | int      |
| time_stamp     | datetime |
+----------------+----------+
user_id is the column of unique values for this table.
Each row contains information about the signup time for the user with ID user_id.
 
Table: Confirmations
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| user_id        | int      |
| time_stamp     | datetime |
| action         | ENUM     |
+----------------+----------+
(user_id, time_stamp) is the primary key (combination of columns with unique values) for this table.
user_id is a foreign key (reference column) to the Signups table.
action is an ENUM (category) of the type ('confirmed', 'timeout')
Each row of this table indicates that the user with ID user_id requested a confirmation message at time_stamp and that 
confirmation message was either confirmed ('confirmed') or expired without confirming ('timeout').
 

The confirmation rate of a user is the number of 'confirmed' messages divided by the total number of requested confirmation messages. 
The confirmation rate of a user that did not request any confirmation messages is 0. Round the confirmation rate to two decimal places.
Write a solution to find the confirmation rate of each user.
Return the result table in any order.

Example 1:
Input: 
Signups table:
+---------+---------------------+
| user_id | time_stamp          |
+---------+---------------------+
| 3       | 2020-03-21 10:16:13 |
| 7       | 2020-01-04 13:57:59 |
| 2       | 2020-07-29 23:09:44 |
| 6       | 2020-12-09 10:39:37 |
+---------+---------------------+
Confirmations table:
+---------+---------------------+-----------+
| user_id | time_stamp          | action    |
+---------+---------------------+-----------+
| 3       | 2021-01-06 03:30:46 | timeout   |
| 3       | 2021-07-14 14:00:00 | timeout   |
| 7       | 2021-06-12 11:57:29 | confirmed |
| 7       | 2021-06-13 12:58:28 | confirmed |
| 7       | 2021-06-14 13:59:27 | confirmed |
| 2       | 2021-01-22 00:00:00 | confirmed |
| 2       | 2021-02-28 23:59:59 | timeout   |
+---------+---------------------+-----------+
Output: 
+---------+-------------------+
| user_id | confirmation_rate |
+---------+-------------------+
| 6       | 0.00              |
| 3       | 0.00              |
| 7       | 1.00              |
| 2       | 0.50              |
+---------+-------------------+
Explanation: 
User 6 did not request any confirmation messages. The confirmation rate is 0.
User 3 made 2 requests and both timed out. The confirmation rate is 0.
User 7 made 3 requests and all were confirmed. The confirmation rate is 1.
User 2 made 2 requests where one was confirmed and the other timed out. The confirmation rate is 1 / 2 = 0.5.
*/


CREATE TABLE IF NOT EXISTS platzi.signups
(
    user_id integer NOT NULL,
    time_stamp date NOT NULL,
    CONSTRAINT signups_pkey PRIMARY KEY (user_id),
    CONSTRAINT signups_userid_unique UNIQUE (user_id)
)

CREATE TABLE IF NOT EXISTS platzi.confirmations
(
    user_id integer NOT NULL,
    time_stamp date NOT NULL,
    action platzi.confirmations_action_type NOT NULL,
    CONSTRAINT confirmations_userid_timestamp_pkey PRIMARY KEY (user_id, time_stamp)
)



--------------------- solution --------------------------
SELECT s.user_id,
       CASE
           WHEN COUNT(c.action) = 0 THEN 0.00
           ELSE ROUND(SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END) * 1.0/ COUNT(c.action), 2)
       END AS confirmation_rate
FROM signups s
LEFT JOIN confirmations c ON s.user_id = c.user_id
GROUP BY s.user_id;




/*
1251. Average Selling Price
Table: Prices
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| start_date    | date    |
| end_date      | date    |
| price         | int     |
+---------------+---------+
(product_id, start_date, end_date) is the primary key (combination of columns with unique values) for this table.
Each row of this table indicates the price of the product_id in the period from start_date to end_date.
For each product_id there will be no two overlapping periods. That means there will be no two intersecting periods for the same product_id.

Table: UnitsSold
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| purchase_date | date    |
| units         | int     |
+---------------+---------+
This table may contain duplicate rows.
Each row of this table indicates the date, units, and product_id of each product sold. 
 
Write a solution to find the average selling price for each product. average_price should be rounded to 2 decimal places.
Return the result table in any order.
The result format is in the following example.
 
Example 1:
Input: 
Prices table:
+------------+------------+------------+--------+
| product_id | start_date | end_date   | price  |
+------------+------------+------------+--------+
| 1          | 2019-02-17 | 2019-02-28 | 5      |
| 1          | 2019-03-01 | 2019-03-22 | 20     |
| 2          | 2019-02-01 | 2019-02-20 | 15     |
| 2          | 2019-02-21 | 2019-03-31 | 30     |
+------------+------------+------------+--------+
UnitsSold table:
+------------+---------------+-------+
| product_id | purchase_date | units |
+------------+---------------+-------+
| 1          | 2019-02-25    | 100   |
| 1          | 2019-03-01    | 15    |
| 2          | 2019-02-10    | 200   |
| 2          | 2019-03-22    | 30    |
+------------+---------------+-------+
Output: 
+------------+---------------+
| product_id | average_price |
+------------+---------------+
| 1          | 6.96          |
| 2          | 16.96         |
+------------+---------------+
Explanation: 
Average selling price = Total Price of Product / Number of products sold.
Average selling price for product 1 = ((100 * 5) + (15 * 20)) / 115 = 6.96
Average selling price for product 2 = ((200 * 15) + (30 * 30)) / 230 = 16.96
*/


CREATE TABLE IF NOT EXISTS platzi.prices
(
    product_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    price integer NOT NULL,
    CONSTRAINT prices_pkey PRIMARY KEY (product_id, start_date, end_date)
)

CREATE TABLE IF NOT EXISTS platzi.unitssold
(
    product_id integer NOT NULL,
    purchase_date date NOT NULL,
    units integer NOT NULL
)


--------------------- solution --------------------------
select u.product_id, round(sum(u.units*p.price)/sum(u.units),2) as average_price
from unitssold u
join prices p
on u.product_id = p.product_id and u.purchase_date >= p.start_date and u.purchase_date <= p.end_date
group by u.product_id;





/*
1075. Project Employees I
Table: Project

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| project_id  | int     |
| employee_id | int     |
+-------------+---------+
(project_id, employee_id) is the primary key of this table.
employee_id is a foreign key to Employee table.
Each row of this table indicates that the employee with employee_id is working on the project with project_id.
 
Table: Employee
+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| employee_id      | int     |
| name             | varchar |
| experience_years | int     |
+------------------+---------+
employee_id is the primary key of this table. It's guaranteed that experience_years is not NULL.
Each row of this table contains information about one employee.
 

Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.
Return the result table in any order.
The query result format is in the following example.
 

Example 1:
Input: 
Project table:
+-------------+-------------+
| project_id  | employee_id |
+-------------+-------------+
| 1           | 1           |
| 1           | 2           |
| 1           | 3           |
| 2           | 1           |
| 2           | 4           |
+-------------+-------------+
Employee table:
+-------------+--------+------------------+
| employee_id | name   | experience_years |
+-------------+--------+------------------+
| 1           | Khaled | 3                |
| 2           | Ali    | 2                |
| 3           | John   | 1                |
| 4           | Doe    | 2                |
+-------------+--------+------------------+
Output: 
+-------------+---------------+
| project_id  | average_years |
+-------------+---------------+
| 1           | 2.00          |
| 2           | 2.50          |
+-------------+---------------+
Explanation: The average experience years for the first project is (3 + 2 + 1) / 3 = 2.00 and for the second project is (3 + 2) / 2 = 2.50
*/


CREATE TABLE IF NOT EXISTS platzi.employee3
(
    employee_id integer NOT NULL,
    name character varying COLLATE pg_catalog."default" NOT NULL,
    experience_years numeric NOT NULL,
    CONSTRAINT employee3_pkey PRIMARY KEY (employee_id)
)

CREATE TABLE IF NOT EXISTS platzi.project
(
    project_id integer NOT NULL,
    employee_id integer NOT NULL,
    CONSTRAINT project__pkey PRIMARY KEY (project_id, employee_id),
    CONSTRAINT project_employee3_fkey FOREIGN KEY (employee_id)
        REFERENCES platzi.employee3 (employee_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
)


-------------------- solution ----------------------


select p.project_id, round(sum(experience_years)/count(p.employee_id),2) as average_years
from project p
join employee3 e
on p.employee_id = e.employee_id
group by p.project_id;






/*
1633. Percentage of Users Attended a Contest
Table: Users
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| user_name   | varchar |
+-------------+---------+
user_id is the primary key (column with unique values) for this table.
Each row of this table contains the name and the id of a user.
 

Table: Register
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| contest_id  | int     |
| user_id     | int     |
+-------------+---------+
(contest_id, user_id) is the primary key (combination of columns with unique values) for this table.
Each row of this table contains the id of a user and the contest they registered into.
 
Write a solution to find the percentage of the users registered in each contest rounded to two decimals.
Return the result table ordered by percentage in descending order. In case of a tie, order it by contest_id in ascending order.
The result format is in the following example.

 Example 1:
Input: 
Users table:
+---------+-----------+
| user_id | user_name |
+---------+-----------+
| 6       | Alice     |
| 2       | Bob       |
| 7       | Alex      |
+---------+-----------+
Register table:
+------------+---------+
| contest_id | user_id |
+------------+---------+
| 215        | 6       |
| 209        | 2       |
| 208        | 2       |
| 210        | 6       |
| 208        | 6       |
| 209        | 7       |
| 209        | 6       |
| 215        | 7       |
| 208        | 7       |
| 210        | 2       |
| 207        | 2       |
| 210        | 7       |
+------------+---------+
Output: 
+------------+------------+
| contest_id | percentage |
+------------+------------+
| 208        | 100.0      |
| 209        | 100.0      |
| 210        | 100.0      |
| 215        | 66.67      |
| 207        | 33.33      |
+------------+------------+
Explanation: 
All the users registered in contests 208, 209, and 210. The percentage is 100% and we sort them in the answer table by contest_id in ascending order.
Alice and Alex registered in contest 215 and the percentage is ((2/3) * 100) = 66.67%
Bob registered in contest 207 and the percentage is ((1/3) * 100) = 33.33%
*/


CREATE TABLE IF NOT EXISTS platzi.users
(
    user_id integer NOT NULL,
    user_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
)

CREATE TABLE IF NOT EXISTS platzi.register
(
    contest_id integer NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT register_pkey PRIMARY KEY (contest_id, user_id),
    CONSTRAINT register_users_fkey FOREIGN KEY (user_id)
        REFERENCES platzi.users (user_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)


------------------register-----------------------


select r.contest_id, round(count(r.user_id)/ (select count(distinct user_id) from users)::numeric *100,2) as counter
from users u
left join register r
on u.user_id = r.user_id
group by r.contest_id
order by r.contest_id;







/*
1211. Queries Quality and Percentage
Table: Queries
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| query_name  | varchar |
| result      | varchar |
| position    | int     |
| rating      | int     |
+-------------+---------+
This table may have duplicate rows.
This table contains information collected from some queries on a database.
The position column has a value from 1 to 500.
The rating column has a value from 1 to 5. Query with rating less than 3 is a poor query.
 
We define query quality as:
The average of the ratio between query rating and its position.
We also define poor query percentage as:
The percentage of all queries with rating less than 3.

Write a solution to find each query_name, the quality and poor_query_percentage.
Both quality and poor_query_percentage should be rounded to 2 decimal places.
Return the result table in any order.

Example 1:

Input: 
Queries table:
+------------+-------------------+----------+--------+
| query_name | result            | position | rating |
+------------+-------------------+----------+--------+
| Dog        | Golden Retriever  | 1        | 5      |
| Dog        | German Shepherd   | 2        | 5      |
| Dog        | Mule              | 200      | 1      |
| Cat        | Shirazi           | 5        | 2      |
| Cat        | Siamese           | 3        | 3      |
| Cat        | Sphynx            | 7        | 4      |
+------------+-------------------+----------+--------+
Output: 
+------------+---------+-----------------------+
| query_name | quality | poor_query_percentage |
+------------+---------+-----------------------+
| Dog        | 2.50    | 33.33                 |
| Cat        | 0.66    | 33.33                 |
+------------+---------+-----------------------+
Explanation: 
Dog queries quality is ((5 / 1) + (5 / 2) + (1 / 200)) / 3 = 2.50
Dog queries poor_ query_percentage is (1 / 3) * 100 = 33.33

Cat queries quality equals ((2 / 5) + (3 / 3) + (4 / 7)) / 3 = 0.66
Cat queries poor_ query_percentage is (1 / 3) * 100 = 33.33

*/



CREATE TABLE IF NOT EXISTS platzi.queries
(
    query_name character varying(20) COLLATE pg_catalog."default" NOT NULL,
    result character varying(30) COLLATE pg_catalog."default" NOT NULL,
    "position" integer NOT NULL,
    rating integer NOT NULL
)


----------------- solution ------------------------

select query_name,  round(avg(rating/position::numeric),2) as quality,
					round(sum(case when rating<3 then 1 else 0 end)::numeric/count(rating)*100,2)
from queries
group by query_name;





/*
1193. Monthly Transactions I
Table: Transactions
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| country       | varchar |
| state         | enum    |
| amount        | int     |
| trans_date    | date    |
+---------------+---------+
id is the primary key of this table.
The table has information about incoming transactions.
The state column is an enum of type ["approved", "declined"].
 

Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.
Return the result table in any order.

Example 1:
Input: 
Transactions table:
+------+---------+----------+--------+------------+
| id   | country | state    | amount | trans_date |
+------+---------+----------+--------+------------+
| 121  | US      | approved | 1000   | 2018-12-18 |
| 122  | US      | declined | 2000   | 2018-12-19 |
| 123  | US      | approved | 2000   | 2019-01-01 |
| 124  | DE      | approved | 2000   | 2019-01-07 |
+------+---------+----------+--------+------------+
Output: 
+----------+---------+-------------+----------------+--------------------+-----------------------+
| month    | country | trans_count | approved_count | trans_total_amount | approved_total_amount |
+----------+---------+-------------+----------------+--------------------+-----------------------+
| 2018-12  | US      | 2           | 1              | 3000               | 1000                  |
| 2019-01  | US      | 1           | 1              | 2000               | 2000                  |
| 2019-01  | DE      | 1           | 1              | 2000               | 2000                  |
+----------+---------+-------------+----------------+--------------------+-----------------------+
*/

CREATE TABLE IF NOT EXISTS platzi.transactions2
(
    id integer NOT NULL,
    country character varying COLLATE pg_catalog."default" NOT NULL,
    state platzi.transactions2_enum_state NOT NULL,
    amount integer NOT NULL,
    trans_date date NOT NULL,
    CONSTRAINT transactions2_pkey PRIMARY KEY (id)
)


----------------- solution -------------------------

select to_char(trans_date, 'YYYY-MM') as month, country, count(state)as trans_count, count(case when state='approved' then 1 end) as approved_count, 
		sum(amount) as trans_total_amount, sum(case when state='approved' then amount end)  as approved_total_amount
from transactions2 t
group by month, country;





/*
1174. Immediate Food Delivery II
Table: Delivery
+-----------------------------+---------+
| Column Name                 | Type    |
+-----------------------------+---------+
| delivery_id                 | int     |
| customer_id                 | int     |
| order_date                  | date    |
| customer_pref_delivery_date | date    |
+-----------------------------+---------+
delivery_id is the column of unique values of this table.
The table holds information about food delivery to customers that make orders at some date and specify a preferred delivery date (on the same order date or after it).
 
If the customer's preferred delivery date is the same as the order date, then the order is called immediate; otherwise, it is called scheduled.
The first order of a customer is the order with the earliest order date that the customer made. It is guaranteed that a customer has precisely one first order.
Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.
The result format is in the following example.

Example 1:
Input: 
Delivery table:
+-------------+-------------+------------+-----------------------------+
| delivery_id | customer_id | order_date | customer_pref_delivery_date |
+-------------+-------------+------------+-----------------------------+
| 1           | 1           | 2019-08-01 | 2019-08-02                  |
| 2           | 2           | 2019-08-02 | 2019-08-02                  |
| 3           | 1           | 2019-08-11 | 2019-08-12                  |
| 4           | 3           | 2019-08-24 | 2019-08-24                  |
| 5           | 3           | 2019-08-21 | 2019-08-22                  |
| 6           | 2           | 2019-08-11 | 2019-08-13                  |
| 7           | 4           | 2019-08-09 | 2019-08-09                  |
+-------------+-------------+------------+-----------------------------+
Output: 
+----------------------+
| immediate_percentage |
+----------------------+
| 50.00                |
+----------------------+
Explanation: 
The customer id 1 has a first order with delivery id 1 and it is scheduled.
The customer id 2 has a first order with delivery id 2 and it is immediate.
The customer id 3 has a first order with delivery id 5 and it is scheduled.
The customer id 4 has a first order with delivery id 7 and it is immediate.
Hence, half the customers have immediate first orders.
*/

CREATE TABLE IF NOT EXISTS platzi.delivery
(
    delivery_id integer NOT NULL,
    customer_id integer NOT NULL,
    order_date date NOT NULL,
    customer_pref_delivery_date date NOT NULL,
    CONSTRAINT delivery_pkey PRIMARY KEY (delivery_id)
)

------------------- solution -------------------------


with cte as(
select * , rank()over(partition by customer_id order by order_date)as date_rank
from delivery
)


select round(sum(case when  d.order_date = cte.customer_pref_delivery_date then 1 end)::numeric / sum(case when cte.date_rank = 1 then 1 end),2)*100 as percentage
from delivery d
left join cte
on d.delivery_id = cte.delivery_id and cte.date_rank =1






/*
550. Game Play Analysis IV
Table: Activity
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key (combination of columns with unique values) of this table.
This table shows the activity of players of some games.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on someday using some device.
 
Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date, then divide that number by the total number of players.
The result format is in the following example.


Example 1:
Input: 
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+
Output: 
+-----------+
| fraction  |
+-----------+
| 0.33      |
+-----------+
Explanation: 
Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33
*/

CREATE TABLE IF NOT EXISTS platzi.activity_games
(
    player_id integer NOT NULL,
    device_id integer NOT NULL,
    event_date date NOT NULL,
    games_played numeric NOT NULL,
    CONSTRAINT activity_games_pkey PRIMARY KEY (player_id, device_id)
)



---------------- solution -------------------------

select round((sum(case when a2.games_played is not null then 1 end )/ (select count(distinct player_id)::numeric from activity_games)),2) as fraction 
from activity_games a1
left join activity_games a2
on a1.player_id = a2.player_id and a1.event_date+interval '1 day' = a2.event_date;









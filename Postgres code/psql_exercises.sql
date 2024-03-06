------------------------------------  ntile()
--Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.
SELECT product_name,
CASE    when x.buckets = 1 then 'Expensive phones'
        when x.buckets = 2 then 'Mid range phones'
        when x.buckets = 3 then 'Cheaper phones'
FROM ( 
    SELECT *,
    ntile(3) over (order by price desc) as buckets
    from product_category
    where product_category = 'Phone') as x;


--cume_dist()
--fetch all products constituting the first 30% of most expensive products
SELECT product_name, (cume_dist_percentage||'%') as cume_dist_percentage
from (
    SELECT * ,
    round(cume_dist() over (order by price desc)::numeric * 100, 2 ) as cume_dist_percentage 
    from product) x
where x.cume_dist_percentage <= 30;

--percent_rank()
--how much more expensive is 'galaxy z fold 3' when compared to all products.
SELECT product_name, percentage_rank,
FROM(
    SELECT *,
    round (percent_rank() over(order by price)::numeric *100,2) as percentage_rank
    FROM product) x 
WHERE x.product_name = 'galaxy z fold3';



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



------------------------------------  RANGES
SELECT *
FROM platzi.alumnos
WHERE tutor_id IN (1,2,3,4);
WHERE tutor_id >= 1  AND  tutor_id <= 10;
WHERE tutor_id BETWEEN 1 AND 10;

--int4range = 32-bit signed integers -> small int
--int8range = 64-bit signed integers -> big int
SELECT int4range(10,20) @> 3; --output: false
SELECT UPPER(int8range(15,25)); --output= 25
SELECT LOWER(int8range(15,25)); --output= 15

-- && refers to the overlapping betwen the two given ranges.
--  returns true or false.
SELECT numrange(11.1,22.2) && numrange(20.0,30.0)

SELECT int4range(10,20) * int4range(15,25); --returns intersection -> [15,20)

SELECT ISEMPTY(numrange(1,5)); -- returns FALSE, as it is not empty

SELECT *
FROM platzi.alumnos
WHERE int4range(10,20) @> tutor_id;


------------------------------------  SERIES
--generate_series(initial(num,timestamp...), end_(num,timestamp...), leap_size(num,hours,days...))
SELECT CURRENT_DATE + s.a AS databases
FROM generate_series(0,14,7) AS s(a) --hereby referencing a NEW_TABLE 's' and a NEW_COLUMN 'a'.
--
SELECT * 
FROM generate_series('2020-09-01 00:00:00'::timestamp,'2020-09-04 12:00:00', '10 hours');

--
SELECT  a.id,
        a.nombre,
        a.apellido,
        a.carrera_id,
        s.a
FROM platzi.alumnos AS a
    INNER JOIN generate_series(0,10) AS s(a)
    ON s.a = a.carrera_id
ORDER BY a.carrera_id;



------------------------------------ ORDINALITY
--
SELECT lpad('*', CAST(ORDINALITY as int), '*'), *
FROM generate_series(100,2,-2) WITH ORDINALITY;


------------------------------------  SELF JOIN
--encuentra alumnos que tambien son tutores y cuenta cuantos alumnos tiene cada tutor.
SELECT CONCAT(t.nombre, ' ', t.apellido) AS tutor,
        COUNT(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
    INNER JOIN platzi.alumnos AS t ON a.tutor_id = t.id
GROUP BY tutor
ORDER BY alumnos_por_tutor DESC
LIMIT 10; 


--PADDING
-- lpad('initial_string', <#chars>, 'filler')
-- rpad('initial_string', <#chars>, 'filler')
SELECT lpad("a_string", CAST(row_id AS int), '*' )
FROM (
    SELECT ROW_NUMBER() OVER(ORDER BY carrera_id) AS row_id, *
    FROM platzi.alumnos
) AS alumnos_with_row_id
WHERE row_id <= 5
ORDER BY carrera_id




-------------------------------------- RECURSIVE QUERIES
--Syntax
WITH [RECURSIVE] CTE_name AS
    (
     SELECT query (Non Recursive query or the Base query)
        UNION [ALL]
     SELECT query (Recursive query using CTE_name [with a termination condition])
    )
SELECT * FROM CTE_name;


--display number from 1 to 10 without using any built in functions
WITH RECURSIVE numbers AS  --'numbers' is a table
    (SELECT 1 AS n
     UNION
     SELECT n + 1
     FROM numbers WHERE n < 10 

    )
SELECT * FROM numbers;



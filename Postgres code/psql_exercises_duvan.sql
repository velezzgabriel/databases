
-- for a given product, identify customers who have ordered that product the most.


create or replace function greatest_buyer_of(item_id int)
returns TABLE (customer_id INT, customer_name VARCHAR(50))
language plpgsql
as
$$

begin
	RETURN QUERY
	select cust.customer_id, cust.name
	from customers cust
	join orders ord
	on cust.customer_id = ord.customer_id
	join orderdetails ordet
	on ord.order_id = ordet.order_id
	where ordet.product_id = item_id
	group by cust.customer_id, cust.name
	order by sum(ordet.quantity_ordered) desc
	limit 5;
end;
$$;

--------------------TESTING---------------------

EXPLAIN ANALYZE select greatest_buyer_of(201294)

select * from  greatest_buyer_of(201294)


DROP function greatest_buyer_of

select * from orderdetails
limit 1


-----------------------------------------------



--******************DUVAN EXCERCISES************************


---1. Los 10 productos que menos stock tienen. 
select * from products
order by products.stock_quantity
limit 10


--2. Cantidad de órdenes que fueron realizadas con 5 productos o más, en el  mes anterior al actual. 
SELECT count(total_prod) AS total_orders
FROM (select count(od.order_id) as total_prod
	from orderdetails od
	join orders o
	on od.order_id = o.order_id
	where o.order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
	  		AND  o.order_date <= CURRENT_DATE  
	group by od.order_id) AS subquery
WHERE total_prod >= 5
LIMIT 10


--3. Nombre y cantidad de veces vendido, de los 10 productos más vendidos en Colombia y Venezuela. 
select p.product_name, sum(od.quantity_ordered) as total_sold
from products p
join orderdetails od
on p.product_id = od.product_id
join orders o
on od.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
where c.country = 'Venezuela' or c.country = 'Colombia'
group by p.product_name
order by total_sold desc
limit 10



--4.  Nombre de los clientes que no tienen un tag asignado, que su correo sea '.org' , y que no hayan realizado ordenes. 
select * from customers c
left join customertags ct
on c.customer_id = ct.customer_id
left join orders o
on c.customer_id = o.customer_id
where ct.tag_id is null and c.email like '%.org%' and o.order_id is null
limit 10


--5. Listado de órdenes con su fecha y la información del cliente, ordenadas por el valor total de orden. 
select o.order_id, o.order_date, c.name, SUM(p.price * od.quantity_ordered) AS totales
from orderdetails od
join products p
on od.product_id = p.product_id
join orders o
on od.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by o.order_id, c.name
order by totales desc
limit 10



--6. Cuál es el producto más vendido en los primeros 5 días de los meses a clientes con tag “vip”
WITH ranked_sales AS (
    SELECT
        DATE_TRUNC('day', o.order_date) AS day,
        p.product_id,
        SUM(od.quantity_ordered) AS total_ordered,
        ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('MONTH', o.order_date)
                           ORDER BY SUM(od.quantity_ordered) DESC) AS rank
    FROM
        orders o
    JOIN
        orderdetails od ON o.order_id = od.order_id
    JOIN
        products p ON od.product_id = p.product_id
    WHERE
        o.order_date >= DATE_TRUNC('year', CURRENT_DATE - INTERVAL '1 year')
        AND o.order_date < DATE_TRUNC('year', CURRENT_DATE)
		and extract (day from o.order_date)<= 5
	
    GROUP BY
        DATE_TRUNC('day', o.order_date),
        DATE_TRUNC('MONTH', o.order_date),
        p.product_id
)

SELECT *
FROM   ranked_sales
WHERE  rank = 1
ORDER BY day


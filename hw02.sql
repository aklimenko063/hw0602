SELECT COUNT(*)
FROM public.orders;

SELECT SUM(CAST((unit_price - (unit_price * discount)) * quantity as numeric(15,2))) AS total_sum
FROM public.order_details;

SELECT city, 
	COUNT(*)
FROM public.employees
GROUP BY city;

SELECT
    p.product_name,
    grouped.total_quantity_sold
FROM
    (SELECT
         od.product_id,
         SUM(od.quantity) AS total_quantity_sold
     FROM
         public.order_details od
     GROUP BY
         od.product_id) AS grouped
JOIN
    public.products p ON grouped.product_id = p.product_id
WHERE
    grouped.total_quantity_sold = (
        SELECT
            MAX(total_quantity_sold)
        FROM
            (SELECT
                 SUM(od.quantity) AS total_quantity_sold
             FROM
                 public.order_details od
             GROUP BY
                 od.product_id) AS subquery
    );
	
WITH employee_orders AS (
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(CAST((od.unit_price - (od.unit_price * od.discount)) * od.quantity AS numeric(15,2)))  AS total_order_value
    FROM 
        public.employees e
    JOIN 
        public.orders o ON e.employee_id = o.employee_id
    JOIN 
        public.order_details od ON o.order_id = od.order_id
    GROUP BY 
        e.employee_id, e.first_name, e.last_name
),
min_employee_order AS (
    SELECT 
        MIN(total_order_value) AS min_total_order_value
    FROM 
        employee_orders
)
SELECT 
    eo.first_name,
    eo.last_name,
    eo.total_order_value
FROM 
    employee_orders eo
JOIN 
	min_employee_order meo ON eo.total_order_value = meo.min_total_order_value;
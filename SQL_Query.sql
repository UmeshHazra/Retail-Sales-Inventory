create database retail_analysis;
use retail_analysis;
select * from clean_order_items;

SELECT *
FROM clean_orders o
LEFT JOIN clean_customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

select * from
clean_order_items oi
left join clean_products p
on oi.product_id = p.product_id
where p.product_id is null;

# 1. TOTAL SALES ANALYSIS
select 
sum(quantity * list_price * (1-discount)) as total_price
from clean_order_items;

# 2. TOP 10 SELLING PRODUCTS
select 
p.product_name,
sum(oi.quantity) as total_quentity_sold
from clean_order_items oi
join clean_products p
on oi.product_id = p.product_id
group by p.product_name
order by total_quentity_sold desc
limit 10;

# 3. SALES BY STORE
select 
s.store_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS store_sales
from clean_orders o
join clean_order_items oi
on o.order_id = oi.order_id
join clean_stores s
on o.store_id = s.store_id
group by s.store_name
order by store_sales desc;

# 4. REPEAT CUSTOMERS
select
c.customer_name,
count(o.order_id) as total_order
from clean_customers c 
join clean_orders o 
on c.customer_id = o.customer_id
group by c.customer_name
having count(o.order_id)>1
order by total_order desc;

# 5. HIGHEST SPENDING CUSTOMERS
SELECT 
    c.customer_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM clean_customers c
JOIN clean_orders o
ON c.customer_id = o.customer_id
JOIN clean_order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 10;

# 6. INVENTORY ANALYSIS
select 
s.store_name,
p.product_name,
st.quantity
from clean_stocks st 
join clean_stores s 
on st.store_id = s.store_id
join clean_products p 
on st.product_id = p.product_id
order by st.quantity asc;

# 7. LOW STOCK PRODUCTS
select 
s.store_name,
p.product_name,
st.quantity
from clean_stocks st 
join clean_stores s 
on st.store_id = s.store_id
join clean_products p 
on st.product_id = p.product_id
where st.quantity < 10
order by st.quantity asc;

# 8. MONTHLY SALES TREND
select 
    SUBSTR(order_date,1,7) as month,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as monthly_sales
from clean_orders o
join clean_order_items oi
on o.order_id = oi.order_id
group by month
order by month;

# 1. SALES SUMMARY VIEW
CREATE VIEW Sales_Summary1 AS
SELECT 
    o.order_id,
    c.customer_name,
    s.store_name,
    p.product_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    o.order_date,

    SUBSTR(o.order_date, 1, 7) AS sales_month,

    (oi.quantity * oi.list_price * (1 - oi.discount)) AS sales_amount

FROM clean_orders o

JOIN clean_customers c
ON o.customer_id = c.customer_id

JOIN clean_stores s
ON o.store_id = s.store_id

JOIN clean_order_items oi
ON o.order_id = oi.order_id

JOIN clean_products p
ON oi.product_id = p.product_id;

# 2. CUSTOMER SUMMARY VIEW
CREATE VIEW customer_summary1 AS

SELECT 

    o.order_id,
    o.order_date,

    c.customer_id,
    c.customer_name,
    c.city AS customer_city,
    c.state AS customer_state,

    stf.staff_id,
    stf.staff_name,

    s.store_id,
    s.store_name,
    s.state AS store_state,

    (oi.quantity * oi.list_price * (1 - oi.discount)) AS sales_amount

FROM clean_orders o

JOIN clean_customers c
ON o.customer_id = c.customer_id

JOIN clean_staffs stf
ON o.staff_id = stf.staff_id

JOIN clean_stores s
ON o.store_id = s.store_id

JOIN clean_order_items oi
ON o.order_id = oi.order_id;

# 3. INVENTORY SUMMARY VIEW
CREATE VIEW inventory_summary AS
SELECT 
    s.store_name,
    p.product_name,
    st.quantity
FROM clean_stocks st
JOIN clean_stores s
ON st.store_id = s.store_id
JOIN clean_products p
ON st.product_id = p.product_id;

CREATE VIEW inventory_summary1 AS

SELECT 

    st.store_id,
    s.store_name,
    s.city AS store_city,
    s.state AS store_state,

    p.product_id,
    p.product_name,

    b.brand_name,
    c.category_name,

    st.quantity,

    CASE
        WHEN st.quantity < 10 THEN 'Low Stock'
        WHEN st.quantity BETWEEN 10 AND 50 THEN 'Medium Stock'
        ELSE 'High Stock'
    END AS stock_status

FROM clean_stocks st

JOIN clean_stores s
ON st.store_id = s.store_id

JOIN clean_products p
ON st.product_id = p.product_id

JOIN clean_brands b
ON p.brand_id = b.brand_id

JOIN clean_categories c
ON p.category_id = c.category_id;

SELECT * FROM inventory_summary1;
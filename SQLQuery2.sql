    --eda 
--total revenue
select round(SUM(total_amount),2)as total_revenue ----> 12627621.02
from Orders

----------------------------
--Monthly Revenue Trend (2022–2024)
select min(order_date )as min_date, MAX(order_date)as max_date --->2022-01-01//2024-01-01
from Orders

select YEAR(order_date)as year,
       MONTH(order_date)as month,
	   SUM(total_amount) as total_revenue
from orders
group by YEAR(order_date),MONTH(order_date)
order by SUM(total_amount)desc
-------------------------------------
--Revenue by Region?
select c.region,round(sum(o.total_amount),2)as revenue_by_region
from orders o
left join
Customers c
on o.customer_id = c.customer_id
group by c.region
order by round(sum(o.total_amount),2) desc
--------------------------------------
--Discount Band Impact on Revenue (like segmentation for discount percentages ) 

SELECT
  CASE WHEN discount = 0     THEN 'No Discount'
       WHEN discount <= 0.10  THEN '1-10%'
       WHEN discount <= 0.20  THEN '11-20%'
       ELSE '21-30%' END       AS discount_band,
  COUNT(order_id)              AS orders,
  ROUND(AVG(total_amount),2)   AS avg_order_value,
  ROUND(SUM(total_amount),2)   AS total_revenue
FROM Orders
WHERE order_status != 'Cancelled'
GROUP BY  CASE WHEN discount = 0     THEN 'No Discount'
       WHEN discount <= 0.10  THEN '1-10%'
       WHEN discount <= 0.20  THEN '11-20%'
       ELSE '21-30%' END
ORDER BY total_revenue DESC;
----------------------------------
--Revenue by Payment Method
select payment_method, round(SUM(total_amount),2)as revenue
from Orders
group by payment_method 
order by revenue desc;
----------------------------------        --section 2 customer behavier

--Top 25 Customers by Lifetime Value (top 25 spenders)
select top(25)c.customer_id, c.full_name, c.city, c.region,  COUNT(order_id)as total_orders ,round(sum(o.total_amount),2) as revenue 
from customers c
left join orders o
on c.customer_id= o.customer_id
WHERE o.order_status = 'Delivered'
group by c.customer_id, c.full_name, c.city, c.region
order by revenue desc
----------------------------------
--Customers with Zero Orders ?
select c.customer_id, c.full_name, c.email,
  c.city, c.join_date, c.status
from Customers c
left join Orders o
on c.customer_id= o.customer_id
WHERE o.order_id IS NULL
 AND c.email NOT IN ('','N/A')
  AND c.email LIKE '%@%.%'
order by join_date                       -------> 0
---------------------------------
--Segment all 800 customers into One-Time Buyers (1 order),
--Repeat Buyers (2–6), and Loyal Customers (7+). Thresholds are set for our 12.5 avg orders/customer dataset.

WITH order_counts AS (
  SELECT customer_id,
         COUNT(order_id)            AS num_orders,
         ROUND(SUM(total_amount),2) AS total_spend
  FROM Orders WHERE order_status != 'Cancelled'
  GROUP BY customer_id
)
SELECT
  CASE WHEN num_orders = 1  THEN '1 - One-Time Buyer'
       WHEN num_orders <= 6 THEN '2 - Repeat Buyer'
       ELSE '3 - Loyal Customer' END AS segment,
  COUNT(*)                   AS customer_count,
  ROUND(AVG(num_orders),1)   AS avg_orders,
  ROUND(AVG(total_spend),2)  AS avg_lifetime_value
FROM order_counts
GROUP BY CASE WHEN num_orders = 1  THEN '1 - One-Time Buyer'
       WHEN num_orders <= 6 THEN '2 - Repeat Buyer'
       ELSE '3 - Loyal Customer' END
	   ORDER BY segment ;
--------------------------------------
-- Revenue by Gender & Region
select c.region, c.gender, round(sum(o.total_amount),2) as revenue
from Customers c
left join 
Orders o
on c.customer_id= o.customer_id
WHERE o.order_status != 'Cancelled'
group by c.region, c.gender
order by revenue desc;
-------------------------------------
--total sales for each product (add aditional deatails product id /date )using window function not group by 
 -- salesByProductAndOrderStatus
select order_id,
       order_date,
       p.product_id ,
	   o.order_status,
	   total_amount,
	   SUM(total_amount) over ()TotalSales,
	   sum(total_amount) over(partition by  p.product_id ) total_sales_by_prooduct,
	   sum(total_amount) over(partition by p.product_id, o.order_status) salesByProductAndOrderStatus
from Orders o
left join 
Products p on o.product_id=p.product_id
--------------------------------------- section 3 product performance
-- Top 15 Products by Revenue
select top (15) o.product_id, p.product_name,p.category,
            SUM(o.quantity)              AS units_sold,
      round(SUM( total_amount ),2)       As revenue
from Orders o
left join Products p
on o.product_id = p.product_id
where order_status ='Delivered'
group by  o.product_id, p.product_name, p.category
order by revenue desc   
---------------------------------------
--Gross Profit & Margin by Category
select 
      p.category,
	  sum(o.quantity)                             as units_sold,
	  SUM(total_amount)                           as revenue,
	  sum(p.cost * o.quantity)                    as total_cost,
	  SUM(total_amount-(p.cost * o.quantity))     as gross_profit,
	  round(SUM(total_amount-(p.cost * o.quantity))*100
	             /SUM(total_amount) ,2)              as gross_margin_percent
from Orders o
left join 
Products p
on o.product_id = p.product_id
group by p.category
ORDER BY gross_margin_percent DESC;
-------------------------------------
 -- Low Stock & Reorder Alert - Flag CRITICAL (< 20 units) and LOW (20–40 units)
 SELECT
  p.product_id, p.product_name, p.category,
  p.stock_quantity,
  CASE WHEN p.stock_quantity < 20 THEN ' CRITICAL'
       WHEN p.stock_quantity < 40 THEN ' LOW'
       ELSE ' OK' END         AS stock_status,
  s.supplier_name, s.country, s.rating
FROM Products p
JOIN Suppliers s ON p.supplier_id = s.supplier_id
WHERE p.stock_quantity < 40
ORDER BY p.stock_quantity ;
----------------------------------
-- Top 3 Products per Category (Window Fn)
 with ranked as(
                SELECT 
                p.product_name,category,
	            round(SUM(total_amount),2) as revenue,
				sum(o.quantity)   as units_sold,
				rank() over(partition by category order by SUM(total_amount)) AS rank_in_category
	                                                                          

from Orders o
left join products p
on o.product_id = p.product_id
where o.order_status='Delivered'
group by category ,p.product_name
)
select* from ranked
where rank_in_category <= 3
ORDER BY category;






-----------------------------
select * from Products
select * from Orders
select * from Customers
select * from Suppliers

select distinct region  from Customers
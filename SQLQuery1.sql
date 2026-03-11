select* from Customers;

-- 1.  Find the duplicate customer_id?
select customer_id, COUNT(*) as occurance
from Customers 
group by customer_id
having COUNT(*) > 1 ;

WITH Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY customer_id
           ) AS rn
    FROM Customers
)

DELETE FROM Duplicates
WHERE rn > 1;
---------------------------------
-- 2.  Find all invalid or blank emails

select customer_Id, full_name , email 
from Customers 
where email = '' or email= 'N/A' or email not like '%@%.%'
---------------------------------
--3.  Find all fake phone numbers
select customer_id, phone
from Customers
WHERE phone = '0000000000' OR phone = '000-000-0000' or phone = null ;
---------------------------------
-- 4.  Find invalid ages (negative or above 100) and replace them with mean
select customer_id, full_name, age
from Customers
where age >100 or age <0

select AVG (age )from Customers where age between 0 and 100 -- correct avg 

update Customers
set age = (select AVG(age) from Customers where age between 0 and 100)
 where age >100 or age < 0
----------------------------------
--5.  Find names in ALL CAPS
select customer_id, first_name,last_name
from Customers
where first_name=UPPER(first_name) and last_name = UPPER(last_name)

----------------------------------
--6.  Fix inconsistent gender codes (M → Male)
select count(customer_id), gender
from Customers                    
group by gender

update Customers
set gender = case when gender= 'M' then 'Male'
                  when gender= 'F' then 'Female'
				  else gender end;
----------------------------------
--7.  Find and fix lowercase status value

SELECT DISTINCT status
FROM Customers;

UPDATE Customers
SET status = UPPER(LEFT(status,1)) + LOWER(SUBSTRING(status,2,LEN(status)));
----------------------------------
--8.  Find missing join_date values
select customer_id , join_date
from Customers
where join_date is null or join_date= '';  --15 missing join date value
----------------------------------
-- 9.  Find orders with zero or negative quantity / total
select order_id,quantity,total_amount
from Orders
where quantity <=0 AND total_amount > 0;

delete from Orders where quantity <=0 AND total_amount > 0;-- no meanning to keep order rows has 0 quantity 
----------------------------------
--10. Find orphan orders — customer not in Customers table
select o.order_id,o.customer_id 
from Orders o
left join Customers c
on o.customer_id=c.customer_id
where c.customer_id is null -- 15 records

DELETE FROM Orders
WHERE customer_id NOT IN (SELECT customer_id FROM Customers);
----------------------------------
--11. Find orphan orders — product not in Products table
select O.order_id,o.product_id
from Orders o
left join Products p
on o.product_id=p.product_id
where p.product_id is null --15 records

delete from Orders
where product_id not in (select product_id from Products);
--------------------------------
--12. Find orders where ship_date is before order_date
select order_id,order_date,ship_date
from Orders
where ship_date < order_date
--------------------------------
--13. Fix inconsistent payment_method casing
select distinct payment_method
from Orders

-----------------------------------------------------------------------------------



select * from Orders


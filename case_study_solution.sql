# 1. Which product has the highest price? Only return a single row.
with CTE1 as (
select product_id,product_name,price, dense_rank() over( order by price desc) as ranking
from products
)
select product_id,product_name,price
from CTE1
where ranking=1

__________________________________________________

#2. Which customer has made the most orders?

with total_orders as
(
select tiny_shop.c.customer_id,count(o.order_id) as order_count,
dense_rank() over ( order by count(o.order_id) desc) as ranking
from tiny_shop.customers c join
tiny_shop.orders o on
c.customer_id=o.customer_id
group by tiny_shop.c.customer_id
) 
select c.customer_id, c.first_name, c.last_name, tot_o.order_count
from total_orders as tot_o
join customers c
on tot_o.customer_id=c.customer_id
where tot_o.ranking= 1

________________________________________________

#3. What’s the total revenue per product?

select oi.product_id, p.product_name, sum(price*quantity) as Revenue
from products p 
join order_items oi 
on p.product_id=oi.product_id
group by 1,2
__________________________________________________
# 4. Find the day with the highest revenue.

select  dayname(o.order_date), sum(price*quantity) as Revenue
from products p 
join order_items oi 
on p.product_id=oi.product_id
join orders o
on o.order_id=oi.order_id
group by 1
___________________________________________________

#5. Find the first order (by date) for each customer.
with date_ranking as (
select customer_id, order_id, order_date, rank() over ( partition by customer_id order by order_date ) as ranking
from orders
group by 1,2,3)

select dr.customer_id,first_name,last_name, order_date
from date_ranking dr
join customers c
on dr.customer_id=c.customer_id
where ranking = 1

__________________________________________________________
# 6. Find the top 3 customers who have ordered the most distinct products
with CTE1 as(
Select 
c.customer_id,c.first_name, c.last_name, count(distinct oi.product_id) AS distinct_product_count,
row_number() over( order by count(distinct oi.product_id) desc) as row_num
From customers c
Join orders o ON c.customer_id = o.customer_id
join order_items oi ON o.order_id = oi.order_id
Group by c.customer_id,c.first_name,c.last_name
Order By count(distinct oi.product_id) Desc
)

select customer_id,first_name,last_name,distinct_product_count from CTE1
where row_num <=3
__________________________________________________________
#7. Which product has been bought the least in terms of quantity?
with CTE1 as 
(
select product_id, sum(quantity) as total_quantity, rank() over( order by sum(quantity)) as ranking 
from order_items
group by product_id
#order by sum(quantity)
)

select c.product_id,product_name, total_quantity
from CTE1 c
join products
on C.product_id= products.product_id
where ranking=1
_________________________________________________________
#8 What is the median order total?

WITH revenue_per_order as
  (SELECT o.order_id,  
          SUM(price*quantity) as total_revenue
  FROM order_items as oi
  JOIN products as p
  ON oi.product_id=p.product_id
  JOIN orders as o
  ON oi.order_id=o.order_id
  GROUP BY 1
  ),
sorting_order as
  (SELECT *,
        ROW_NUMBER()OVER (ORDER BY total_revenue DESC) as sorting,
        count(*)OVER() as total
  FROM revenue_per_order) 
SELECT order_id, total_revenue as median_amount
FROM sorting_order
WHERE sorting=total/2 or sorting=ROUND(total/2,1)

________________________________________________________
# 9. For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
with CTE1 as (
select o.order_id, sum(oi.quantity*p.price) as total_amount
from order_items oi 
join products p on oi.product_id=p.product_id
join orders o on oi.order_id=o.order_id
group by 1
)

select 
order_id, total_amount,
case
	when total_amount > 300 then "Expensive"
    when total_amount > 100 then "Affordable"
    else "Cheap"
END AS order_category
from CTE1    
_______________________________________________________
# 10. Find customers who have ordered the product with the highest price.
with CTE1 as 
(
select o.customer_id, o.order_id,oi.product_id, price, dense_rank() over(order by price desc) as ranking
from 
order_items oi join orders o on oi.order_id=o.order_id
join products p on oi.product_id=p.product_id 
)

select ct.customer_id,first_name,last_name, price
from CTE1 ct join customers c on c.customer_id=ct.customer_id
where ranking=1

__________________________________________________________



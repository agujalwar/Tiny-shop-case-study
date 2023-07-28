**Schema (MySQL v8.0)**

    CREATE TABLE customers (
        customer_id integer PRIMARY KEY,
        first_name varchar(100),
        last_name varchar(100),
        email varchar(100)
    );
    
    CREATE TABLE products (
        product_id integer PRIMARY KEY,
        product_name varchar(100),
        price decimal
    );
    
    CREATE TABLE orders (
        order_id integer PRIMARY KEY,
        customer_id integer,
        order_date date
    );
    
    CREATE TABLE order_items (
        order_id integer,
        product_id integer,
        quantity integer
    );
    
    INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
    (1, 'John', 'Doe', 'johndoe@email.com'),
    (2, 'Jane', 'Smith', 'janesmith@email.com'),
    (3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
    (4, 'Alice', 'Brown', 'alicebrown@email.com'),
    (5, 'Charlie', 'Davis', 'charliedavis@email.com'),
    (6, 'Eva', 'Fisher', 'evafisher@email.com'),
    (7, 'George', 'Harris', 'georgeharris@email.com'),
    (8, 'Ivy', 'Jones', 'ivyjones@email.com'),
    (9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
    (10, 'Lily', 'Nelson', 'lilynelson@email.com'),
    (11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
    (12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
    (13, 'Sophia', 'Thomas', 'sophiathomas@email.com');
    
    INSERT INTO products (product_id, product_name, price) VALUES
    (1, 'Product A', 10.00),
    (2, 'Product B', 15.00),
    (3, 'Product C', 20.00),
    (4, 'Product D', 25.00),
    (5, 'Product E', 30.00),
    (6, 'Product F', 35.00),
    (7, 'Product G', 40.00),
    (8, 'Product H', 45.00),
    (9, 'Product I', 50.00),
    (10, 'Product J', 55.00),
    (11, 'Product K', 60.00),
    (12, 'Product L', 65.00),
    (13, 'Product M', 70.00);
    
    INSERT INTO orders (order_id, customer_id, order_date) VALUES
    (1, 1, '2023-05-01'),
    (2, 2, '2023-05-02'),
    (3, 3, '2023-05-03'),
    (4, 1, '2023-05-04'),
    (5, 2, '2023-05-05'),
    (6, 3, '2023-05-06'),
    (7, 4, '2023-05-07'),
    (8, 5, '2023-05-08'),
    (9, 6, '2023-05-09'),
    (10, 7, '2023-05-10'),
    (11, 8, '2023-05-11'),
    (12, 9, '2023-05-12'),
    (13, 10, '2023-05-13'),
    (14, 11, '2023-05-14'),
    (15, 12, '2023-05-15'),
    (16, 13, '2023-05-16');
    
    INSERT INTO order_items (order_id, product_id, quantity) VALUES
    (1, 1, 2),
    (1, 2, 1),
    (2, 2, 1),
    (2, 3, 3),
    (3, 1, 1),
    (3, 3, 2),
    (4, 2, 4),
    (4, 3, 1),
    (5, 1, 1),
    (5, 3, 2),
    (6, 2, 3),
    (6, 1, 1),
    (7, 4, 1),
    (7, 5, 2),
    (8, 6, 3),
    (8, 7, 1),
    (9, 8, 2),
    (9, 9, 1),
    (10, 10, 3),
    (10, 11, 2),
    (11, 12, 1),
    (11, 13, 3),
    (12, 4, 2),
    (12, 5, 1),
    (13, 6, 3),
    (13, 7, 2),
    (14, 8, 1),
    (14, 9, 2),
    (15, 10, 3),
    (15, 11, 1),
    (16, 12, 2),
    (16, 13, 3);
    

---

**Query #1**

    select product_id,product_name,price
    from products
    order by price desc
    limit 1;

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 13         | Product M    | 70    |

---
**Query #2**

    with total_orders as
    (
    select c.customer_id,count(o.order_id) as order_count,
    dense_rank() over ( order by count(o.order_id) desc) as ranking
    from customers c join
    orders o on
    c.customer_id=o.customer_id
    group by c.customer_id
    ) 
    select c.customer_id, c.first_name, c.last_name, tot_o.order_count
    from total_orders as tot_o
    join customers c
    on tot_o.customer_id=c.customer_id
    where tot_o.ranking= 1;

| customer_id | first_name | last_name | order_count |
| ----------- | ---------- | --------- | ----------- |
| 1           | John       | Doe       | 2           |
| 2           | Jane       | Smith     | 2           |
| 3           | Bob        | Johnson   | 2           |

---
**Query #3**

    select oi.product_id, p.product_name, sum(price*quantity) as Revenue
    from products p 
    join order_items oi 
    on p.product_id=oi.product_id
    group by 1,2;

| product_id | product_name | Revenue |
| ---------- | ------------ | ------- |
| 1          | Product A    | 50      |
| 2          | Product B    | 135     |
| 3          | Product C    | 160     |
| 4          | Product D    | 75      |
| 5          | Product E    | 90      |
| 6          | Product F    | 210     |
| 7          | Product G    | 120     |
| 8          | Product H    | 135     |
| 9          | Product I    | 150     |
| 10         | Product J    | 330     |
| 11         | Product K    | 180     |
| 12         | Product L    | 195     |
| 13         | Product M    | 420     |

---
**Query #4**

    select  dayname(o.order_date), sum(price*quantity) as Revenue
    from products p 
    join order_items oi 
    on p.product_id=oi.product_id
    join orders o
    on o.order_id=oi.order_id
    group by 1;

| dayname(o.order_date) | Revenue |
| --------------------- | ------- |
| Monday                | 405     |
| Tuesday               | 555     |
| Wednesday             | 335     |
| Thursday              | 355     |
| Friday                | 130     |
| Saturday              | 240     |
| Sunday                | 230     |

---
**Query #5**

    with date_ranking as (
    select customer_id, order_id, order_date, rank() over ( partition by customer_id order by order_date ) as ranking
    from orders
    group by 1,2,3)
    
    select dr.customer_id,first_name,last_name, order_date
    from date_ranking dr
    join customers c
    on dr.customer_id=c.customer_id
    where ranking = 1;

| customer_id | order_date | first_name | last_name |
| ----------- | ---------- | ---------- | --------- |
| 1           | 2023-05-01 | John       | Doe       |
| 2           | 2023-05-02 | Jane       | Smith     |
| 3           | 2023-05-03 | Bob        | Johnson   |
| 4           | 2023-05-07 | Alice      | Brown     |
| 5           | 2023-05-08 | Charlie    | Davis     |
| 6           | 2023-05-09 | Eva        | Fisher    |
| 7           | 2023-05-10 | George     | Harris    |
| 8           | 2023-05-11 | Ivy        | Jones     |
| 9           | 2023-05-12 | Kevin      | Miller    |
| 10          | 2023-05-13 | Lily       | Nelson    |
| 11          | 2023-05-14 | Oliver     | Patterson |
| 12          | 2023-05-15 | Quinn      | Roberts   |
| 13          | 2023-05-16 | Sophia     | Thomas    |

---
**Query #6**

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
    where row_num <=3;

| customer_id | first_name | last_name | distinct_product_count |
| ----------- | ---------- | --------- | ---------------------- |
| 1           | John       | Doe       | 3                      |
| 2           | Jane       | Smith     | 3                      |
| 3           | Bob        | Johnson   | 3                      |

---
**Query #7**

    with CTE1 as 
    (
    select product_id, sum(quantity) as total_quantity, rank() over( order by sum(quantity)) as ranking 
    from order_items
    group by product_id
    
    )
    
    select c.product_id,product_name, total_quantity
    from CTE1 c
    join products
    on c.product_id= products.product_id
    where ranking=1;

| product_id | total_quantity | product_name |
| ---------- | -------------- | ------------ |
| 4          | 3              | Product D    |
| 5          | 3              | Product E    |
| 7          | 3              | Product G    |
| 8          | 3              | Product H    |
| 9          | 3              | Product I    |
| 11         | 3              | Product K    |
| 12         | 3              | Product L    |

---
**Query #8**

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
    WHERE sorting=total/2 or sorting=ROUND(total/2,1);

| order_id | median_amount |
| -------- | ------------- |
| 9        | 140           |

---
**Query #9**

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
    from CTE1;

| order_id | total_amount | order_category |
| -------- | ------------ | -------------- |
| 1        | 35           | Cheap          |
| 2        | 75           | Cheap          |
| 3        | 50           | Cheap          |
| 4        | 80           | Cheap          |
| 5        | 50           | Cheap          |
| 6        | 55           | Cheap          |
| 7        | 85           | Cheap          |
| 8        | 145          | Affordable     |
| 9        | 140          | Affordable     |
| 10       | 285          | Affordable     |
| 11       | 275          | Affordable     |
| 12       | 80           | Cheap          |
| 13       | 185          | Affordable     |
| 14       | 145          | Affordable     |
| 15       | 225          | Affordable     |
| 16       | 340          | Expensive      |

---
**Query #10**

    with CTE1 as 
    (
    select o.customer_id, o.order_id,oi.product_id, price, dense_rank() over(order by price desc) as ranking
    from 
    order_items oi join orders o on oi.order_id=o.order_id
    join products p on oi.product_id=p.product_id 
    )
    
    select ct.customer_id,first_name,last_name, price
    from CTE1 ct join customers c on c.customer_id=ct.customer_id
    where ranking=1;

| customer_id | price | first_name | last_name |
| ----------- | ----- | ---------- | --------- |
| 13          | 70    | Sophia     | Thomas    |
| 8           | 70    | Ivy        | Jones     |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/5NT4w4rBa1cvFayg2CxUjr/4)
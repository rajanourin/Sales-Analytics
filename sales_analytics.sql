

-- TABLES
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    city        VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category     VARCHAR(30) NOT NULL,
    price        NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id    INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id  INT NOT NULL REFERENCES products(product_id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    amount      NUMERIC(10,2),
    order_date  DATE NOT NULL
);

-- DATA
INSERT INTO customers (customer_id, name, city, signup_date) VALUES
(1,  'Anu Menon',      'Kochi',      '2023-12-20'),
(2,  'Rahul Nair',     'Calicut',    '2024-01-02'),
(3,  'Fathima Beevi',  'Malappuram', '2024-01-15'),
(4,  'Arjun Das',      'Trivandrum', '2024-02-01'),
(5,  'Meera Krishnan', 'Kochi',      '2024-02-10'),
(6,  'Sanjay Kumar',   'Bangalore',  '2024-03-01'),
(7,  'Priya Sharma',   'Chennai',    '2024-03-20'),
(8,  'Nikhil Joseph',  'Calicut',    '2024-04-10'),
(9,  'Divya Pillai',   'Thrissur',   '2024-05-15'),
(10, 'Imran Khan',     'Hyderabad',  '2024-06-20'),
(11, 'Alan Thomas',    'Kannur',     '2024-07-01'),
(12, 'Sneha Varma',    'Palakkad',   '2024-08-01');

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Laptop',       'Electronics', 55000),
(2, 'Headphones',   'Electronics',  2500),
(3, 'Smartphone',   'Electronics', 30000),
(4, 'Office Chair', 'Furniture',    6500),
(5, 'Study Table',  'Furniture',    8000),
(6, 'Notebook Pack','Stationery',    250),
(7, 'Pen Set',      'Stationery',    400),
(8, 'Backpack',     'Accessories',  1800);

INSERT INTO orders (order_id, customer_id, product_id, quantity, order_date) VALUES
(1,  1, 2, 1, '2024-01-10'), (2,  2, 6, 5, '2024-01-18'),
(3,  3, 3, 1, '2024-02-02'), (4,  1, 7, 3, '2024-02-14'),
(5,  4, 4, 2, '2024-02-20'), (6,  5, 8, 1, '2024-03-03'),
(7,  2, 2, 2, '2024-03-11'), (8,  6, 1, 1, '2024-03-25'),
(9,  3, 6, 4, '2024-04-05'), (10, 7, 5, 1, '2024-04-12'),
(11, 1, 8, 2, '2024-04-22'), (12, 8, 3, 1, '2024-05-02'),
(13, 4, 7, 2, '2024-05-15'), (14, 2, 4, 1, '2024-05-28'),
(15, 9, 2, 1, '2024-06-06'), (16, 5, 1, 1, '2024-06-19'),
(17, 3, 5, 1, '2024-07-01'), (18, 10, 6, 3, '2024-07-09'),
(19, 6, 3, 2, '2024-07-23'), (20, 1, 1, 1, '2024-08-08'),
(21, 7, 8, 2, '2024-08-16'), (22, 4, 2, 3, '2024-08-27'),
(23, 2, 7, 4, '2024-09-04'), (24, 8, 4, 1, '2024-09-18');

-- amount = quantity x product price
UPDATE orders o
SET amount = o.quantity * p.price
FROM products p
WHERE p.product_id = o.product_id;




-- Q1. Overall KPIs
SELECT COUNT(*) AS total_orders,
       SUM(amount) AS total_revenue,
       ROUND(AVG(amount), 2) AS avg_order_value
FROM orders;

-- Q2. Monthly revenue
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS orders,
       SUM(amount) AS revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- Q3. Quarterly revenue
SELECT EXTRACT(QUARTER FROM order_date) AS quarter,
       SUM(amount) AS revenue
FROM orders
GROUP BY quarter
ORDER BY quarter;

-- Q4. Revenue by city
SELECT c.city, SUM(o.amount) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- Q5. Average order value by city
SELECT c.city, ROUND(AVG(o.amount), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY avg_order_value DESC;

-- Q6. Revenue by category
SELECT p.category, SUM(o.amount) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q7. Category share of total revenue (%)
SELECT p.category,
       SUM(o.amount) AS revenue,
       ROUND(100.0 * SUM(o.amount) / (SELECT SUM(amount) FROM orders), 2) AS pct_of_total
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q8. Top selling category (by units sold)
SELECT p.category, SUM(o.quantity) AS units_sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY units_sold DESC
LIMIT 1;

-- Q9. Top 3 selling products (by units sold)
SELECT p.product_name, SUM(o.quantity) AS units_sold, SUM(o.amount) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 3;

-- Q10. Top 5 customers by revenue
SELECT c.name, SUM(o.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 5;

-- Q11. Repeat customers (more than 1 order)
SELECT c.name, COUNT(*) AS num_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(*) > 1
ORDER BY num_orders DESC;

-- Q12. Repeat vs one-time customers (CTE + CASE)
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS num_orders
    FROM orders
    GROUP BY customer_id
)
SELECT CASE WHEN num_orders > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type,
       COUNT(*) AS customers
FROM order_counts
GROUP BY customer_type;

-- Q13. Customers who never ordered
SELECT c.name, c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q14. Customer segments (CASE WHEN)
WITH totals AS (
    SELECT c.customer_id, c.name,
           COALESCE(SUM(o.amount), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name
)
SELECT name, total_spent,
       CASE
           WHEN total_spent >= 50000 THEN 'Premium'
           WHEN total_spent >= 10000 THEN 'Regular'
           WHEN total_spent > 0      THEN 'Low'
           ELSE 'Inactive'
       END AS segment
FROM totals
ORDER BY total_spent DESC;

-- Q15. Orders above the average order value (subquery)
SELECT order_id, customer_id, amount
FROM orders
WHERE amount > (SELECT AVG(amount) FROM orders)
ORDER BY amount DESC;

-- Q16. Most recent order per customer (correlated subquery)
SELECT c.name, o.order_id, o.order_date, o.amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY c.name;

-- Q17. Days from signup to first order (date functions)
SELECT c.name,
       MIN(o.order_date) - c.signup_date AS days_to_first_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.signup_date
ORDER BY days_to_first_order;

-- Q18. Customers per city (including cities with no orders)
SELECT c.city,
       COUNT(DISTINCT c.customer_id) AS customers,
       COALESCE(SUM(o.amount), 0) AS revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY revenue DESC;




CREATE OR REPLACE VIEW monthly_sales_view AS
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS total_orders,
       SUM(amount) AS revenue,
       ROUND(AVG(amount), 2) AS avg_order_value
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM');

CREATE OR REPLACE VIEW customer_summary_view AS
SELECT c.customer_id, c.name, c.city,
       COUNT(o.order_id) AS total_orders,
       COALESCE(SUM(o.amount), 0) AS total_spent,
       MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city;

-- Week 44 - Advanced SQL (TrailShop)

-- Task 1.1: Subqueries
 
-- 1. Products priced above the average price (scalar subquery)
SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
 
-- 2. Customers who have placed more than 2 orders (IN subquery)
SELECT first_name, last_name, email
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 2
);
 
-- 3. Each product's price vs its category's average (correlated subquery)
SELECT p.name,
       c.name AS category,
       p.price,
       ROUND(p.price - (
           SELECT AVG(p2.price)
           FROM products p2
           JOIN product_categories pc2 ON pc2.product_id = p2.product_id
           WHERE pc2.category_id = pc.category_id
       ), 2) AS diff_from_category_avg
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id
ORDER BY c.name, p.price DESC;
 
-- =========================================================
-- Task 1.2: EXISTS
-- =========================================================
 
-- 1. Customers who ordered at least one Footwear product
SELECT c.first_name, c.last_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN product_categories pc ON pc.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = pc.category_id
    WHERE o.customer_id = c.customer_id
      AND cat.name = 'Footwear'
);
 
-- 2. Products that have never been ordered
SELECT p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);
 
-- =========================================================
-- Task 1.3: CASE expressions
-- =========================================================
 
-- 1. Price tier label
SELECT name,
       price,
       CASE
           WHEN price < 25 THEN 'Budget'
           WHEN price < 75 THEN 'Standard'
           ELSE 'Premium'
       END AS price_tier
FROM products
ORDER BY price;
 
-- 2. Count orders by status using CASE inside COUNT
SELECT COUNT(*) AS total_orders,
       COUNT(CASE WHEN status = 'pending'   THEN 1 END) AS pending,
       COUNT(CASE WHEN status = 'shipped'   THEN 1 END) AS shipped,
       COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered,
       COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled
FROM orders;
 
-- =========================================================
-- Task 1.4: Three views
-- =========================================================
 
CREATE OR REPLACE VIEW v_product_catalog AS
SELECT p.name AS product_name,
       c.name AS category_name,
       p.price,
       CASE
           WHEN p.stock = 0 THEN 'Out of Stock'
           WHEN p.stock < 5 THEN 'Low Stock'
           ELSE 'In Stock'
       END AS stock_status
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id;
 
CREATE OR REPLACE VIEW v_customer_summary AS
SELECT c.first_name || ' ' || c.last_name AS full_name,
       c.email,
       COUNT(DISTINCT o.order_id) AS order_count,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
 
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT DATE_TRUNC('month', o.order_date)::date AS month,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;
 
-- Verify the views
SELECT * FROM v_product_catalog;
SELECT * FROM v_customer_summary ORDER BY total_spent DESC;
SELECT * FROM v_monthly_revenue;
 
-- =========================================================
-- Task 1.5: UNION / EXCEPT
-- =========================================================
 
-- 1. Footwear + Accessories product names, no duplicates
SELECT p.name
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id
WHERE c.name = 'Footwear'
UNION
SELECT p.name
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id
WHERE c.name = 'Accessories';
 
-- 2. Categories that have products but no orders
SELECT c.name
FROM categories c
JOIN product_categories pc ON pc.category_id = c.category_id
EXCEPT
SELECT c.name
FROM categories c
JOIN product_categories pc ON pc.category_id = c.category_id
JOIN order_items oi ON oi.product_id = pc.product_id;
 
-- =========================================================
-- Task 1.6: CTEs
-- =========================================================
 
-- 1. Revenue per category, then categories above average
WITH category_revenue AS (
    SELECT c.name AS category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM categories c
    JOIN product_categories pc ON pc.category_id = c.category_id
    JOIN order_items oi ON oi.product_id = pc.product_id
    GROUP BY c.name
)
SELECT category, revenue
FROM category_revenue
WHERE revenue > (SELECT AVG(revenue) FROM category_revenue)
ORDER BY revenue DESC;
 
-- 2. Two CTEs: order counts + average, then top customers
WITH customer_orders AS (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS full_name,
           COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
avg_orders AS (
    SELECT AVG(order_count) AS avg_count
    FROM customer_orders
)
SELECT co.full_name, co.order_count
FROM customer_orders co, avg_orders a
WHERE co.order_count > a.avg_count
ORDER BY co.order_count DESC;
-- Week 41: Querying Data

-- ============================================
-- Basic Queries (SELECT + WHERE)
-- ============================================

\echo '--- Q1: Footwear products ---'
SELECT p.name, p.price, p.stock
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id
WHERE c.name = 'Footwear';

\echo '--- Q2: Products priced 50 to 150 ---'
SELECT name, price
FROM products
WHERE price BETWEEN 50 AND 150
ORDER BY price ASC;

\echo '--- Q3: Customers with last name starting M or K ---'
SELECT first_name, last_name
FROM customers
WHERE last_name LIKE 'M%' OR last_name LIKE 'K%';

\echo '--- Q4: Pending or shipped orders ---'
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status IN ('pending', 'shipped')
ORDER BY order_date DESC;

\echo '--- Q5: Products with Pro in the name ---'
SELECT name, price
FROM products
WHERE name ILIKE '%pro%';

-- ============================================
-- Aggregate Queries
-- ============================================

\echo '--- Q6: Total number of products ---'
SELECT COUNT(*) AS total_products
FROM products;

\echo '--- Q7: Average product price ---'
SELECT ROUND(AVG(price), 2) AS avg_price
FROM products;

\echo '--- Q8: Most expensive and cheapest product ---'
SELECT name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products)
   OR price = (SELECT MIN(price) FROM products)
ORDER BY price DESC;

\echo '--- Q9: Orders per customer ---'
SELECT c.first_name || ' ' || c.last_name AS customer,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY order_count DESC;

\echo '--- Q10: Revenue per order status ---'
SELECT o.status,
       SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.status
ORDER BY total_revenue DESC;

-- ============================================
-- JOIN Queries
-- ============================================

\echo '--- Q11: Products with category names ---'
SELECT c.name AS category, p.name AS product
FROM products p
JOIN product_categories pc ON pc.product_id = p.product_id
JOIN categories c ON c.category_id = pc.category_id
ORDER BY c.name, p.name;

\echo '--- Q12: Orders with customer name ---'
SELECT o.order_id,
       c.first_name || ' ' || c.last_name AS customer,
       o.order_date,
       o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

\echo '--- Q13: Order #1 breakdown ---'
SELECT p.name AS product,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.order_id = 1;

\echo '--- Q14: Customers with no orders ---'
SELECT c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

\echo '--- Q15: Category summary (inventory value over 500) ---'
SELECT c.name AS category,
       COUNT(p.product_id) AS product_count,
       ROUND(AVG(p.price), 2) AS avg_price,
       SUM(p.price * p.stock) AS inventory_value
FROM categories c
JOIN product_categories pc ON pc.category_id = c.category_id
JOIN products p ON p.product_id = pc.product_id
GROUP BY c.category_id, c.name
HAVING SUM(p.price * p.stock) > 500
ORDER BY inventory_value DESC;
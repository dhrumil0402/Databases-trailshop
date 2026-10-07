-- Week 40 - Task 1.5: Practice DELETE

DELETE FROM products WHERE product_id = 1;
BEGIN;

SELECT * FROM order_items WHERE order_id = 6;
DELETE FROM orders
WHERE order_id = (SELECT order_id FROM orders ORDER BY order_date DESC LIMIT 1);
SELECT * FROM order_items WHERE order_id = 6;

DELETE FROM categories WHERE name = 'Tents';
SELECT product_id, name FROM products WHERE product_id IN (6, 7);
SELECT * FROM product_categories WHERE product_id IN (6, 7);
DELETE FROM customers WHERE customer_id = 6;
SELECT * FROM customers;

ROLLBACK;

SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS orders FROM orders;
SELECT COUNT(*) AS order_items FROM order_items;
SELECT COUNT(*) AS product_categories FROM product_categories;
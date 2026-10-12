-- Week 40 - Task 1.4: Practice UPDATE
-- Run this ONLY ONCE, running it twice raises the Footwear prices again

-- 1. Increase Footwear prices by 10%
UPDATE products
SET price = price * 1.10
WHERE product_id IN (
    SELECT pc.product_id
    FROM product_categories pc
    JOIN categories c ON c.category_id = pc.category_id
    WHERE c.name = 'Footwear'
);
SELECT name, price FROM products WHERE product_id IN (1, 2, 3);

-- 2. Change customer #3's email
UPDATE customers
SET email = 'laura.nieminen@newmail.com'
WHERE customer_id = 3;
SELECT * FROM customers WHERE customer_id = 3;

-- 3. Order #2 from shipped to delivered
UPDATE orders
SET status = 'delivered'
WHERE order_id = 2 AND status = 'shipped';
SELECT * FROM orders WHERE order_id = 2;

-- 4. Set HydroFlask stock to 85
UPDATE products
SET stock = 85
WHERE name = 'HydroFlask 1L';
SELECT name, stock FROM products WHERE name = 'HydroFlask 1L';

-- 5. Add a description where it is NULL
UPDATE products
SET description = 'Description coming soon'
WHERE description IS NULL;
SELECT name, description FROM products;
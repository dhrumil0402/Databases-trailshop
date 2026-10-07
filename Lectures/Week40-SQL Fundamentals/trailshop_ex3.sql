-- Week 40 - Exercise 3: SQL Writing Exercises

BEGIN;

CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    company_name  VARCHAR(200) NOT NULL UNIQUE,
    contact_name  VARCHAR(150),
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    country       VARCHAR(100) NOT NULL DEFAULT 'Finland'
);

CREATE TABLE product_reviews (
    review_id    SERIAL PRIMARY KEY,
    product_id   INTEGER NOT NULL REFERENCES products(product_id),
    customer_id  INTEGER NOT NULL REFERENCES customers(customer_id),
    rating       INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text  TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
\dt

INSERT INTO categories (name, description)
VALUES ('Electronics', 'GPS devices, solar chargers, and tech gear');
SELECT category_id, name FROM categories;

INSERT INTO customers (first_name, last_name, email) VALUES
    ('Eero', 'Lahtinen', 'eero.l@email.com'),
    ('Maria', 'Salminen', 'maria.s@email.com'),
    ('Petri', 'Kallio', 'petri.k@email.com');
SELECT customer_id, first_name, last_name, email FROM customers ORDER BY customer_id;

INSERT INTO products (name, price, stock)
VALUES ('NorthStar GPS', 229.99, 12)
RETURNING product_id, created_at;

INSERT INTO product_categories (product_id, category_id)
SELECT product_id, 6
FROM products
WHERE name = 'NorthStar GPS';
SELECT * FROM product_categories WHERE category_id = 6;

UPDATE customers
SET email = 'mikko.korhonen@newmail.com'
WHERE customer_id = 2;
SELECT customer_id, email FROM customers WHERE customer_id = 2;

UPDATE products
SET stock = stock - 1
WHERE stock > 0;
SELECT product_id, name, stock FROM products ORDER BY product_id;

ALTER TABLE orders ADD COLUMN cancelled_at TIMESTAMPTZ;
UPDATE orders
SET status = 'cancelled',
    cancelled_at = CURRENT_TIMESTAMP
WHERE order_id = 3;
SELECT * FROM orders ORDER BY order_id;

DELETE FROM orders
WHERE status = 'cancelled';
SELECT order_id, status FROM orders ORDER BY order_id;

ALTER TABLE products
ADD COLUMN discount_percent NUMERIC(5,2) DEFAULT 0
CHECK (discount_percent >= 0 AND discount_percent <= 100);

ALTER TABLE categories DROP COLUMN description;

ALTER TABLE product_reviews
ADD CONSTRAINT uq_product_reviews_customer_product UNIQUE (customer_id, product_id);
\d product_reviews

ROLLBACK;

\dt
SELECT COUNT(*) AS categories FROM categories;
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS products FROM products;
SELECT COUNT(*) AS orders FROM orders;
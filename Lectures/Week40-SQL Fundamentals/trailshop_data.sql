-- Week 40 - Task 1.3: Insert sample data
-- Run this ONLY ONCE, running it twice doubles the rows and shifts the IDs

-- Categories (5)
INSERT INTO categories (name, description) VALUES
    ('Footwear', 'Hiking boots, trail runners, and sandals'),
    ('Backpacks', 'Day packs, overnight packs, and expedition packs'),
    ('Tents', 'One-person to family-size tents'),
    ('Clothing', 'Outdoor clothing for all seasons'),
    ('Accessories', 'Water bottles, headlamps, trekking poles');

-- Customers (6)
INSERT INTO customers (first_name, last_name, email) VALUES
    ('Anna', 'Virtanen', 'anna.virtanen@email.com'),
    ('Mikko', 'Korhonen', 'mikko.korhonen@email.com'),
    ('Laura', 'Nieminen', 'laura.nieminen@email.com'),
    ('Jussi', 'Makinen', 'jussi.makinen@email.com'),
    ('Sara', 'Koskinen', 'sara.koskinen@email.com'),
    ('Timo', 'Laine', 'timo.laine@email.com');

-- Products (11)
INSERT INTO products (name, description, price, stock) VALUES
    ('Trail Runner Pro', 'Light trail running shoe with a grippy sole', 129.90, 25),
    ('Alpine Hiking Boots', 'Waterproof leather boots for rough terrain', 189.00, 12),
    ('Camp Sandals', NULL, 24.90, 50),
    ('Summit Daypack 25L', 'Comfy daypack for short hikes', 79.90, 30),
    ('Expedition Pack 65L', NULL, 249.00, 6),
    ('Ridge 2-Person Tent', 'Light tent for two, quick setup', 299.00, 8),
    ('Basecamp Family Tent', NULL, 489.00, 3),
    ('Storm Shell Jacket', 'Wind and rain proof shell jacket', 159.00, 18),
    ('Merino Base Layer', NULL, 69.90, 40),
    ('HydroFlask 1L', 'Insulated steel water bottle', 44.90, 60),
    ('Pro Trekking Poles', NULL, 89.00, 0);

-- Product categories (12 links, Camp Sandals is in Footwear and Accessories)
INSERT INTO product_categories (product_id, category_id) VALUES
    (1, 1), (2, 1), (3, 1),
    (4, 2), (5, 2),
    (6, 3), (7, 3),
    (8, 4), (9, 4),
    (3, 5), (10, 5), (11, 5);

-- Orders (6)
INSERT INTO orders (customer_id, order_date, status) VALUES
    (1, '2026-09-01 10:15', 'delivered'),
    (2, '2026-09-08 14:30', 'shipped'),
    (3, '2026-09-15 09:00', 'pending'),
    (4, '2026-09-18 18:45', 'cancelled'),
    (5, '2026-09-22 12:10', 'shipped'),
    (1, '2026-09-29 20:05', 'pending');

-- Order items (12)
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 129.90), (1, 10, 2, 44.90), (1, 9, 1, 69.90),
    (2, 6, 1, 299.00), (2, 11, 1, 89.00),
    (3, 4, 1, 79.90),
    (4, 8, 1, 159.00),
    (5, 5, 1, 249.00), (5, 3, 2, 24.90), (5, 10, 1, 44.90),
    (6, 2, 1, 189.00), (6, 9, 2, 69.90);

-- Verify
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM product_categories;
SELECT * FROM orders;
SELECT * FROM order_items;
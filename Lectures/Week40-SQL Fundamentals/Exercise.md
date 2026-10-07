# Week 40 — Exercises: SQL Fundamentals

> [!IMPORTANT]
> **_How to Complete These Exercises_**
> Write your answers directly in the highlighted **Your Answer** / **Your SQL** fields below each task. Replace the placeholder text with your own work before submitting.

## Exercise 1: TrailShop Project Task

This week you'll build the TrailShop database from scratch and practice manipulating data.

### Task 1.1: Create the Database

1. Open your PostgreSQL terminal (psql) or pgAdmin
2. Create a new database called `trailshop`
3. Connect to it

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- Ran in psql while connected to the default postgres database
> CREATE DATABASE trailshop;
> \c trailshop
> ```

### Task 1.2: Create All Tables

Write and execute the CREATE TABLE statements for all six TrailShop tables in the correct order:

- categories
- customers
- products
- product_categories
- orders
- order_items

**Requirements:**

- Use appropriate data types for each column
- Include all constraints from the theory (NOT NULL, UNIQUE, CHECK, FOREIGN KEY, DEFAULT)
- Use SERIAL for primary keys
- Ensure foreign keys reference the correct parent tables

**Verify** by running `\dt` in psql to list all tables.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> CREATE TABLE categories (
>     category_id  SERIAL PRIMARY KEY,
>     name         VARCHAR(100) NOT NULL UNIQUE,
>     description  TEXT
> );
>
> CREATE TABLE customers (
>     customer_id  SERIAL PRIMARY KEY,
>     first_name   VARCHAR(100) NOT NULL,
>     last_name    VARCHAR(100) NOT NULL,
>     email        VARCHAR(255) NOT NULL UNIQUE,
>     created_at   TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP
> );
>
> CREATE TABLE products (
>     product_id   SERIAL PRIMARY KEY,
>     name         VARCHAR(200) NOT NULL,
>     description  TEXT,
>     price        NUMERIC(10,2) NOT NULL CHECK (price > 0),
>     stock        INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
>     created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
> );
>
> CREATE TABLE product_categories (
>     product_id   INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
>     category_id  INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
>     PRIMARY KEY (product_id, category_id)
> );
>
> CREATE TABLE orders (
>     order_id     SERIAL PRIMARY KEY,
>     customer_id  INTEGER NOT NULL REFERENCES customers(customer_id),
>     order_date   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
>     status       VARCHAR(20) NOT NULL DEFAULT 'pending'
>                  CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'))
> );
>
> CREATE TABLE order_items (
>     order_item_id  SERIAL PRIMARY KEY,
>     order_id       INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
>     product_id     INTEGER NOT NULL REFERENCES products(product_id),
>     quantity       INTEGER NOT NULL CHECK (quantity > 0),
>     unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price > 0)
> );
>
> -- Checked with \dt, all 6 tables are listed
> ```

### Task 1.3: Insert Sample Data

Insert the following data:

**Categories** (at least 5):

- Footwear, Backpacks, Tents, Clothing, Accessories

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO categories (name, description) VALUES
>     ('Footwear', 'Hiking boots, trail runners, and sandals'),
>     ('Backpacks', 'Day packs, overnight packs, and expedition packs'),
>     ('Tents', 'One-person to family-size tents'),
>     ('Clothing', 'Outdoor clothing for all seasons'),
>     ('Accessories', 'Water bottles, headlamps, trekking poles');
>
> SELECT * FROM categories;
> ```

**Customers** (at least 5):

- Use easy to write names with realistic email addresses

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO customers (first_name, last_name, email) VALUES
>     ('Anna', 'Virtanen', 'anna.virtanen@email.com'),
>     ('Mikko', 'Korhonen', 'mikko.korhonen@email.com'),
>     ('Laura', 'Nieminen', 'laura.nieminen@email.com'),
>     ('Jussi', 'Makinen', 'jussi.makinen@email.com'),
>     ('Sara', 'Koskinen', 'sara.koskinen@email.com'),
>     ('Timo', 'Laine', 'timo.laine@email.com');
>
> SELECT * FROM customers;
> ```

**Products** (at least 10):

- At least 2 products per category
- At least one product assigned to **two or more** categories
- Prices ranging from €20 to €500
- Various stock levels

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO products (name, description, price, stock) VALUES
>     ('Trail Runner Pro', 'Light trail running shoe with a grippy sole', 129.90, 25),
>     ('Alpine Hiking Boots', 'Waterproof leather boots for rough terrain', 189.00, 12),
>     ('Camp Sandals', NULL, 24.90, 50),
>     ('Summit Daypack 25L', 'Comfy daypack for short hikes', 79.90, 30),
>     ('Expedition Pack 65L', NULL, 249.00, 6),
>     ('Ridge 2-Person Tent', 'Light tent for two, quick setup', 299.00, 8),
>     ('Basecamp Family Tent', NULL, 489.00, 3),
>     ('Storm Shell Jacket', 'Wind and rain proof shell jacket', 159.00, 18),
>     ('Merino Base Layer', NULL, 69.90, 40),
>     ('HydroFlask 1L', 'Insulated steel water bottle', 44.90, 60),
>     ('Pro Trekking Poles', NULL, 89.00, 0);
>
> SELECT * FROM products;
> ```

**Product categories:**

- Insert rows into `product_categories` so every sample product is linked to at least one category

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- Camp Sandals (product 3) is in two categories: Footwear (1) and Accessories (5)
> INSERT INTO product_categories (product_id, category_id) VALUES
>     (1, 1), (2, 1), (3, 1),
>     (4, 2), (5, 2),
>     (6, 3), (7, 3),
>     (8, 4), (9, 4),
>     (3, 5), (10, 5), (11, 5);
>
> SELECT * FROM product_categories;
> ```

**Orders** (at least 5):

- Different customers, different statuses

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO orders (customer_id, order_date, status) VALUES
>     (1, '2026-09-01 10:15', 'delivered'),
>     (2, '2026-09-08 14:30', 'shipped'),
>     (3, '2026-09-15 09:00', 'pending'),
>     (4, '2026-09-18 18:45', 'cancelled'),
>     (5, '2026-09-22 12:10', 'shipped'),
>     (1, '2026-09-29 20:05', 'pending');
>
> SELECT * FROM orders;
> ```

**Order Items** (at least 10):

- Multiple items in some orders, single items in others

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- unit_price is the price of the product at the time of the order
> INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
>     (1, 1, 1, 129.90), (1, 10, 2, 44.90), (1, 9, 1, 69.90),
>     (2, 6, 1, 299.00), (2, 11, 1, 89.00),
>     (3, 4, 1, 79.90),
>     (4, 8, 1, 159.00),
>     (5, 5, 1, 249.00), (5, 3, 2, 24.90), (5, 10, 1, 44.90),
>     (6, 2, 1, 189.00), (6, 9, 2, 69.90);
>
> SELECT * FROM order_items;
> ```

**Verify** each insert with `SELECT * FROM table_name;`

### Task 1.4: Practice UPDATE

> [!TIP]
> **Recommended practice.** Do Tasks 1.4–1.6. They are not required to finish the TrailShop project. They prepare you for the exams. Task 1.6 renames `stock` to `quantity_in_stock`. Later weeks still use `stock`, so after you practice the rename, change the column name back.

Perform the following updates and verify each one:

1. Increase the price of all products in the Footwear category by 10% (join through `product_categories`)
2. Change customer #3's email to a new address
3. Update the status of order #2 from 'shipped' to 'delivered'
4. Set the stock of 'HydroFlask 1L' to 85
5. Add a description to any product that currently has NULL in description

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> UPDATE products
> SET price = price * 1.10
> WHERE product_id IN (
>     SELECT pc.product_id
>     FROM product_categories pc
>     JOIN categories c ON c.category_id = pc.category_id
>     WHERE c.name = 'Footwear'
> );
> SELECT name, price FROM products WHERE product_id IN (1, 2, 3);
>
> UPDATE customers
> SET email = 'laura.nieminen@newmail.com'
> WHERE customer_id = 3;
> SELECT * FROM customers WHERE customer_id = 3;
>
> UPDATE orders
> SET status = 'delivered'
> WHERE order_id = 2 AND status = 'shipped';
> SELECT * FROM orders WHERE order_id = 2;
>
> UPDATE products
> SET stock = 85
> WHERE name = 'HydroFlask 1L';
> SELECT name, stock FROM products WHERE name = 'HydroFlask 1L';
>
> UPDATE products
> SET description = 'Description coming soon'
> WHERE description IS NULL;
> SELECT name, description FROM products;
> ```

### Task 1.5: Practice DELETE

1. Delete the most recently created order (and observe what happens to its order_items if you used CASCADE)
2. Try to delete a product that appears in `order_items` — what error do you get?
3. Delete a category that has products linked through `product_categories`. The products should remain; only the link rows should disappear. Confirm this.
4. Delete a customer who has no orders

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- 2. Ran this on its own first, it fails on purpose
> DELETE FROM products WHERE product_id = 1;
>
> -- 1, 3 and 4 inside a transaction so I can roll back and keep my data for Week 41
> BEGIN;
>
> -- 1. Most recent order (order 6)
> SELECT * FROM order_items WHERE order_id = 6;
> DELETE FROM orders
> WHERE order_id = (SELECT order_id FROM orders ORDER BY order_date DESC LIMIT 1);
> SELECT * FROM order_items WHERE order_id = 6;
>
> -- 3. Category with linked products
> DELETE FROM categories WHERE name = 'Tents';
> SELECT product_id, name FROM products WHERE product_id IN (6, 7);
> SELECT * FROM product_categories WHERE product_id IN (6, 7);
>
> -- 4. Customer with no orders (Timo)
> DELETE FROM customers WHERE customer_id = 6;
> SELECT * FROM customers;
>
> ROLLBACK;
> ```

> [!NOTE]
> **_Your Answer_**
>
> 1. Order 6 had 2 rows in `order_items`. After deleting the order, the same SELECT returned 0 rows, so `ON DELETE CASCADE` removed the items automatically.
> 2. I got: `ERROR: update or delete on table "products" violates foreign key constraint "order_items_product_id_fkey" on table "order_items"` and `DETAIL: Key (product_id)=(1) is still referenced from table "order_items".` The FK on `order_items.product_id` has no CASCADE, so PostgreSQL blocks the delete and nothing gets removed.
> 3. After deleting Tents, the two tent products were still in `products`, but their rows in `product_categories` were gone. So only the links got deleted, not the products.
> 4. Timo had no orders, so he was deleted without any error.
>
> I ran 1, 3 and 4 inside `BEGIN` / `ROLLBACK` so the deletes could be checked and then undone, which keeps the sample data complete for next week.

### Task 1.6: Practice ALTER TABLE

1. Add a column `phone VARCHAR(20)` to the customers table
2. Add a column `weight_grams INTEGER` to the products table
3. Add a CHECK constraint to ensure `weight_grams > 0` (allow NULL though — not all products have weight recorded yet)
4. Rename the `stock` column in products to `quantity_in_stock`

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- 1.
> ALTER TABLE customers ADD COLUMN phone VARCHAR(20);
>
> -- 2.
> ALTER TABLE products ADD COLUMN weight_grams INTEGER;
>
> -- 3. NULL still passes, a CHECK only fails when the result is FALSE
> ALTER TABLE products
> ADD CONSTRAINT chk_products_weight_positive CHECK (weight_grams > 0);
>
> -- 4.
> ALTER TABLE products RENAME COLUMN stock TO quantity_in_stock;
>
> -- Renamed back because later weeks use stock
> ALTER TABLE products RENAME COLUMN quantity_in_stock TO stock;
> ```

---

## Exercise 2: Theory Review Questions

Answer the following questions in your own words using the answer fields below:

1. What does SQL stand for, and why was the language designed to look like English?

> [!NOTE]
> **_Your Answer_**
>
> SQL stands for Structured Query Language. It was made to look like English so people who aren't programmers, like analysts or managers, could also use it. You just say what data you want and the database figures out how to get it. For example `SELECT name FROM products WHERE price < 50` reads almost like a normal sentence.

2. Explain the difference between DDL and DML. Give two example commands for each.

> [!NOTE]
> **_Your Answer_**
>
> DDL (Data Definition Language) is for the structure of the database, so creating and changing tables. DML (Data Manipulation Language) is for the actual data inside the tables. The way I remember it: DDL builds the shelves, DML puts stuff on them.
>
> DDL examples: `CREATE TABLE`, `ALTER TABLE`
>
> DML examples: `INSERT`, `UPDATE`

3. What is the difference between DCL and TCL? When would you use each?

> [!NOTE]
> **_Your Answer_**
>
> DCL (Data Control Language) is about permissions, who is allowed to do what. The commands are `GRANT` and `REVOKE`. I would use it when setting up users, for example giving an analyst read-only access to the products table.
>
> TCL (Transaction Control Language) groups changes together so they either all succeed or all get cancelled. The commands are `BEGIN`, `COMMIT` and `ROLLBACK`. I would use it when changes belong together, like creating an order and its order items, so you never end up with half an order saved.

4. Why must you create tables in a specific order? What determines that order?

> [!NOTE]
> **_Your Answer_**
>
> A foreign key can only reference a table that already exists, otherwise PostgreSQL gives an error. So the parent tables have to be created before the child tables. The foreign keys decide the order.
>
> In TrailShop I created `categories`, `customers` and `products` first because they don't reference anything. Then `product_categories` and `orders`, and `order_items` last because it needs both `orders` and `products`.

5. What is the difference between a column-level constraint and a table-level constraint? When _must_ you use a table-level constraint?

> [!NOTE]
> **_Your Answer_**
>
> A column-level constraint is written on the same line as the column and only covers that one column, for example `price NUMERIC(10,2) NOT NULL CHECK (price > 0)`. A table-level constraint is written after all the columns and can cover more than one column.
>
> You have to use a table-level constraint when the rule involves several columns together. For example the composite primary key `PRIMARY KEY (product_id, category_id)` in `product_categories`, a `UNIQUE` on two columns, or a CHECK that compares two columns like `CHECK (end_date >= start_date)`.

6. Explain the difference between `DELETE FROM products;` and `TRUNCATE TABLE products;`. When would you prefer each?

> [!NOTE]
> **_Your Answer_**
>
> `DELETE` removes rows one by one and can have a WHERE clause, so you can remove only some rows. Without WHERE it removes everything, but it's slow on big tables.
>
> `TRUNCATE` empties the whole table in one go. It has no WHERE and it's much faster. It also won't run if another table references this one with a foreign key, unless you add `CASCADE`.
>
> I'd use DELETE when I only want to remove specific rows or the table is small. I'd use TRUNCATE when I want to quickly empty a big table, like test data. Simple way to remember: DELETE is taking items off the shelf one at a time, TRUNCATE is tipping the whole box out.

7. What does `ON DELETE CASCADE` do on a foreign key? Give a real-world scenario where it's appropriate and one where it would be dangerous.

> [!NOTE]
> **_Your Answer_**
>
> When a row in the parent table is deleted, all the child rows that reference it get deleted automatically too.
>
> Good example: `orders` and `order_items`. If an order is deleted, its items don't mean anything anymore, so it makes sense to remove them with it.
>
> Dangerous example: `customers` and `orders`. If deleting a customer cascaded, their whole order history would disappear too, and the shop would lose sales records it needs for accounting.

8. Why should you store `unit_price` in the `order_items` table instead of just looking it up from the `products` table?

> [!NOTE]
> **_Your Answer_**
>
> Because product prices change over time, but what the customer paid should stay the same. `unit_price` saves the price at the moment of the purchase. If the HydroFlask goes from €44.90 to €49.90 next month and we always looked up the price from `products`, all the old orders would suddenly show the wrong total. It works like a receipt, it doesn't change when the shop changes the price tag.

9. What is the difference between SERIAL and GENERATED ALWAYS AS IDENTITY? Which would you use in a new project and why?

> [!NOTE]
> **_Your Answer_**
>
> `SERIAL` is a PostgreSQL shortcut that creates a sequence and uses it as the default value of the column. You can still insert your own ID manually, which can later clash with a number the sequence gives out.
>
> `GENERATED ALWAYS AS IDENTITY` is the official SQL standard way. The database fully controls the numbering and blocks manual IDs unless you specifically use `OVERRIDING SYSTEM VALUE`.
>
> In a new project I would use IDENTITY because it's the standard and it's harder to mess up the IDs by accident. In TrailShop I used SERIAL because the task asked for it.

10. Explain why `UPDATE products SET price = 9.99;` is dangerous. What steps should you take before running any UPDATE statement?

> [!NOTE]
> **_Your Answer_**
>
> There is no WHERE clause, so it changes the price of every single product to 9.99. The whole catalogue would be wrong after one command.
>
> Before running an UPDATE I should:
>
> 1. Write the WHERE clause first
> 2. Run a SELECT with the same WHERE to check which rows will be changed
> 3. Run the UPDATE inside a transaction (`BEGIN`), check the result, and then `COMMIT` if it's right or `ROLLBACK` if it's wrong

---

## Exercise 3: SQL Writing Exercises (Optional)

> [!TIP]
> **Recommended practice.** Do this section. It is not required to finish the TrailShop project. It prepares you for the exams.

Write the SQL statements for each task in the **Your SQL** fields below. Verify by running them when ready.

### 3.1 CREATE TABLE

Write a CREATE TABLE statement for a `suppliers` table with the following columns:

- supplier_id (auto-incrementing primary key)
- company_name (required, max 200 characters, must be unique)
- contact_name (max 150 characters)
- email (max 255 characters, required, unique)
- phone (max 20 characters)
- country (max 100 characters, required, default 'Finland')

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> CREATE TABLE suppliers (
>     supplier_id   SERIAL PRIMARY KEY,
>     company_name  VARCHAR(200) NOT NULL UNIQUE,
>     contact_name  VARCHAR(150),
>     email         VARCHAR(255) NOT NULL UNIQUE,
>     phone         VARCHAR(20),
>     country       VARCHAR(100) NOT NULL DEFAULT 'Finland'
> );
> ```

### 3.2 CREATE TABLE with Foreign Key

Write a CREATE TABLE statement for a `product_reviews` table:

- review_id (auto-incrementing primary key)
- product_id (required, references products)
- customer_id (required, references customers)
- rating (required integer, must be between 1 and 5 inclusive)
- review_text (optional, unlimited length)
- created_at (required, defaults to current timestamp)

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> CREATE TABLE product_reviews (
>     review_id    SERIAL PRIMARY KEY,
>     product_id   INTEGER NOT NULL REFERENCES products(product_id),
>     customer_id  INTEGER NOT NULL REFERENCES customers(customer_id),
>     rating       INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
>     review_text  TEXT,
>     created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
> );
> ```

### 3.3 INSERT — Single Row

Write an INSERT statement to add a new category called 'Electronics' with description 'GPS devices, solar chargers, and tech gear'.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO categories (name, description)
> VALUES ('Electronics', 'GPS devices, solar chargers, and tech gear');
> ```

### 3.4 INSERT — Multiple Rows

Write a single INSERT statement that adds three new customers:

- Eero Lahtinen, eero.l@email.com
- Maria Salminen, maria.s@email.com
- Petri Kallio, petri.k@email.com

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO customers (first_name, last_name, email) VALUES
>     ('Eero', 'Lahtinen', 'eero.l@email.com'),
>     ('Maria', 'Salminen', 'maria.s@email.com'),
>     ('Petri', 'Kallio', 'petri.k@email.com');
> ```

### 3.5 INSERT with RETURNING

Write an INSERT statement that adds a new product called 'NorthStar GPS' priced at €229.99 with stock of 12, then assign it to category 'Electronics' (assume `category_id = 6`) using `product_categories`. Return the product_id and created_at.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> INSERT INTO products (name, price, stock)
> VALUES ('NorthStar GPS', 229.99, 12)
> RETURNING product_id, created_at;
>
> INSERT INTO product_categories (product_id, category_id)
> SELECT product_id, 6
> FROM products
> WHERE name = 'NorthStar GPS';
> ```

### 3.6 UPDATE — Simple

Write an UPDATE statement that changes the email of the customer with customer_id = 2 to 'mikko.korhonen@newmail.com'.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> UPDATE customers
> SET email = 'mikko.korhonen@newmail.com'
> WHERE customer_id = 2;
> ```

### 3.7 UPDATE — Expression

Write an UPDATE statement that reduces the stock of all products by 1 where the stock is currently greater than 0.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> UPDATE products
> SET stock = stock - 1
> WHERE stock > 0;
> ```

### 3.8 UPDATE — Multiple Columns

Write an UPDATE statement that changes order #3 to status 'cancelled' and sets a (hypothetical) cancelled_at timestamp to the current time. (Assume you've already added a cancelled_at column.)

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- cancelled_at was added first with:
> -- ALTER TABLE orders ADD COLUMN cancelled_at TIMESTAMPTZ;
>
> UPDATE orders
> SET status = 'cancelled',
>     cancelled_at = CURRENT_TIMESTAMP
> WHERE order_id = 3;
> ```

### 3.9 DELETE — With Condition

Write a DELETE statement that removes all orders with status 'cancelled'.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> DELETE FROM orders
> WHERE status = 'cancelled';
> ```

### 3.10 ALTER TABLE

Write the ALTER TABLE statements to:
a) Add a `discount_percent NUMERIC(5,2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100)` column to products
b) Drop the `description` column from categories
c) Add a composite unique constraint on (customer_id, product_id) in the product_reviews table (preventing a customer from reviewing the same product twice)

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> -- a)
> ALTER TABLE products
> ADD COLUMN discount_percent NUMERIC(5,2) DEFAULT 0
> CHECK (discount_percent >= 0 AND discount_percent <= 100);
>
> -- b)
> ALTER TABLE categories DROP COLUMN description;
>
> -- c)
> ALTER TABLE product_reviews
> ADD CONSTRAINT uq_product_reviews_customer_product UNIQUE (customer_id, product_id);
> ```

---

## Exercise 4: Error Diagnosis (Optional)

> [!TIP]
> **Recommended practice.** Do this section. It is not required to finish the TrailShop project. It prepares you for the exams.

Each of the following SQL statements contains one or more errors. Identify the error(s) and write the corrected version.

### 4.1

```sql
CREATE TABLE warehouses
    warehouse_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100
);
```

> [!NOTE]
> **_Error(s) Identified_**
>
> Two brackets are missing. There's no opening `(` after `CREATE TABLE warehouses`, and `VARCHAR(100` on the city line is never closed.

> [!NOTE]
> **_Corrected SQL_**
>
> ```sql
> CREATE TABLE warehouses (
>     warehouse_id SERIAL PRIMARY KEY,
>     name VARCHAR(100) NOT NULL,
>     city VARCHAR(100)
> );
> ```

### 4.2

```sql
INSERT INTO products (name, price, stock)
VALUES ("Alpine Sleeping Bag", 89.99, 20);
```

> [!NOTE]
> **_Error(s) Identified_**
>
> The text value is in double quotes. In PostgreSQL double quotes are for names of columns and tables, so it thinks "Alpine Sleeping Bag" is a column and gives `column "Alpine Sleeping Bag" does not exist`. Text values need single quotes.

> [!NOTE]
> **_Corrected SQL_**
>
> ```sql
> INSERT INTO products (name, price, stock)
> VALUES ('Alpine Sleeping Bag', 89.99, 20);
> ```

### 4.3

```sql
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id)
    shipped_date DATE NOT NULL,
    carrier VARCHAR(100)
);
```

> [!NOTE]
> **_Error(s) Identified_**
>
> There's a missing comma after `REFERENCES orders(order_id)`. Without it PostgreSQL reads `shipped_date` as part of the order_id line and gives a syntax error.

> [!NOTE]
> **_Corrected SQL_**
>
> ```sql
> CREATE TABLE shipments (
>     shipment_id SERIAL PRIMARY KEY,
>     order_id INTEGER REFERENCES orders(order_id),
>     shipped_date DATE NOT NULL,
>     carrier VARCHAR(100)
> );
> ```

### 4.4

```sql
UPDATE products
SET price = price * 0.9
SET stock = stock + 10
WHERE product_id = 3;
```

> [!NOTE]
> **_Error(s) Identified_**
>
> `SET` is written twice. An UPDATE only has one SET, and when you change more than one column you separate them with commas.

> [!NOTE]
> **_Corrected SQL_**
>
> ```sql
> UPDATE products
> SET price = price * 0.9,
>     stock = stock + 10
> WHERE product_id = 3;
> ```

### 4.5

```sql
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, product_id)
);
```

> [!NOTE]
> **_Error(s) Identified_**
>
> The table has two primary keys, `wishlist_id SERIAL PRIMARY KEY` and `PRIMARY KEY (customer_id, product_id)`. A table can only have one, so PostgreSQL gives `multiple primary keys for table "wishlists" are not allowed`. Since customer + product already identifies a row, I removed `wishlist_id` and kept the composite key, same idea as `product_categories`. Another way to fix it would be keeping `wishlist_id` as the PK and making the pair `UNIQUE`.

> [!NOTE]
> **_Corrected SQL_**
>
> ```sql
> CREATE TABLE wishlists (
>     customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
>     product_id INTEGER NOT NULL REFERENCES products(product_id),
>     added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
>     PRIMARY KEY (customer_id, product_id)
> );
> ```

---

## Submission Checklist

**Required**

- [x] All 6 TrailShop tables created successfully
- [x] Sample data inserted (at least 5 categories, 5 customers, 10 products, product_categories links, 5 orders, 10 order items)
- [x] Theory review questions answered

**Recommended practice**

- [x] UPDATE exercises completed and verified
- [x] DELETE exercises completed and verified
- [x] ALTER TABLE exercises completed, then `quantity_in_stock` renamed back to `stock`
- [x] SQL writing exercises completed
- [x] Error diagnosis completed with corrections
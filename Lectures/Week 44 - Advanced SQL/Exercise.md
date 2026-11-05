# Week 44 — Advanced SQL: Exercises

> [!IMPORTANT]
> **_How to Complete These Exercises_**
> Write your answers directly in the highlighted **Your Answer** / **Your SQL** fields below each task. Replace the placeholder text with your own work before submitting.

All SQL below is also in `week44queries.sql`, run in psql with `\i`.

---

## 1. TrailShop Project Task

Continue building the TrailShop database. This week, use advanced query techniques to extract meaningful insights.

### Task 1.1: Subqueries

Write the following queries using subqueries:

1. Find all products priced above the average price (use a scalar subquery).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT name, price
   > FROM products
   > WHERE price > (SELECT AVG(price) FROM products)
   > ORDER BY price DESC;
   > ```
2. Find all customers who have placed more than 2 orders (use a subquery in WHERE with IN).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT first_name, last_name, email
   > FROM customers
   > WHERE customer_id IN (
   >     SELECT customer_id
   >     FROM orders
   >     GROUP BY customer_id
   >     HAVING COUNT(*) > 2
   > );
   > ```
   >
   > Returns 0 rows with my data, the most anyone has is 2 orders (Anna). Changing `> 2` to `> 1` shows Anna, so the query works.
3. Show each product's name, price, and how much it differs from its category's average price (use a correlated subquery or derived table).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT p.name,
   >        c.name AS category,
   >        p.price,
   >        ROUND(p.price - (
   >            SELECT AVG(p2.price)
   >            FROM products p2
   >            JOIN product_categories pc2 ON pc2.product_id = p2.product_id
   >            WHERE pc2.category_id = pc.category_id
   >        ), 2) AS diff_from_category_avg
   > FROM products p
   > JOIN product_categories pc ON pc.product_id = p.product_id
   > JOIN categories c ON c.category_id = pc.category_id
   > ORDER BY c.name, p.price DESC;
   > ```

### Task 1.2: EXISTS

1. Use `EXISTS` to find all customers who have ordered at least one product from the "Footwear" category.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT c.first_name, c.last_name
   > FROM customers c
   > WHERE EXISTS (
   >     SELECT 1
   >     FROM orders o
   >     JOIN order_items oi ON oi.order_id = o.order_id
   >     JOIN product_categories pc ON pc.product_id = oi.product_id
   >     JOIN categories cat ON cat.category_id = pc.category_id
   >     WHERE o.customer_id = c.customer_id
   >       AND cat.name = 'Footwear'
   > );
   > ```
2. Use `NOT EXISTS` to find all products that have never been ordered.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT p.name
   > FROM products p
   > WHERE NOT EXISTS (
   >     SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
   > );
   > ```

### Task 1.3: CASE Expressions

1. Add a `price_tier` column to a product query that labels products as 'Budget' (< €25), 'Standard' (€25–€74.99), or 'Premium' (≥ €75).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT name,
   >        price,
   >        CASE
   >            WHEN price < 25 THEN 'Budget'
   >            WHEN price < 75 THEN 'Standard'
   >            ELSE 'Premium'
   >        END AS price_tier
   > FROM products
   > ORDER BY price;
   > ```
2. Write a query that counts orders by status using CASE inside COUNT.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT COUNT(*) AS total_orders,
   >        COUNT(CASE WHEN status = 'pending'   THEN 1 END) AS pending,
   >        COUNT(CASE WHEN status = 'shipped'   THEN 1 END) AS shipped,
   >        COUNT(CASE WHEN status = 'delivered' THEN 1 END) AS delivered,
   >        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled
   > FROM orders;
   > ```

### Task 1.4: Create Three Views

Create the following views in your TrailShop database:

1. `v_product_catalog` — Shows product name, category name, price, and stock status ('In Stock', 'Low Stock' for < 5 units, 'Out of Stock' for 0). Join through `product_categories`. A product in two categories may appear twice (once per category).
2. `v_customer_summary` — Shows each customer's full name, email, number of orders, and total spent.
3. `v_monthly_revenue` — Shows revenue grouped by month.

Verify each view works with a simple SELECT.

> [!NOTE]
> **_Your SQL_**
>
> ```sql
> CREATE OR REPLACE VIEW v_product_catalog AS
> SELECT p.name AS product_name,
>        c.name AS category_name,
>        p.price,
>        CASE
>            WHEN p.stock = 0 THEN 'Out of Stock'
>            WHEN p.stock < 5 THEN 'Low Stock'
>            ELSE 'In Stock'
>        END AS stock_status
> FROM products p
> JOIN product_categories pc ON pc.product_id = p.product_id
> JOIN categories c ON c.category_id = pc.category_id;
>
> CREATE OR REPLACE VIEW v_customer_summary AS
> SELECT c.first_name || ' ' || c.last_name AS full_name,
>        c.email,
>        COUNT(DISTINCT o.order_id) AS order_count,
>        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
> FROM customers c
> LEFT JOIN orders o ON o.customer_id = c.customer_id
> LEFT JOIN order_items oi ON oi.order_id = o.order_id
> GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
>
> CREATE OR REPLACE VIEW v_monthly_revenue AS
> SELECT DATE_TRUNC('month', o.order_date)::date AS month,
>        SUM(oi.quantity * oi.unit_price) AS revenue
> FROM orders o
> JOIN order_items oi ON oi.order_id = o.order_id
> GROUP BY DATE_TRUNC('month', o.order_date)
> ORDER BY month;
>
> -- Verify
> SELECT * FROM v_product_catalog;
> SELECT * FROM v_customer_summary ORDER BY total_spent DESC;
> SELECT * FROM v_monthly_revenue;
> ```
>
> `v_customer_summary` uses LEFT JOIN so Timo (no orders) still shows up with 0 orders and 0 spent. `COUNT(DISTINCT o.order_id)` stops an order with 3 items being counted as 3 orders.

### Task 1.5: UNION

1. Write a UNION query that combines product names from two different categories into one list (without duplicates).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT p.name
   > FROM products p
   > JOIN product_categories pc ON pc.product_id = p.product_id
   > JOIN categories c ON c.category_id = pc.category_id
   > WHERE c.name = 'Footwear'
   > UNION
   > SELECT p.name
   > FROM products p
   > JOIN product_categories pc ON pc.product_id = p.product_id
   > JOIN categories c ON c.category_id = pc.category_id
   > WHERE c.name = 'Accessories';
   > ```
   >
   > Camp Sandals is in both categories but only shows once, because UNION removes duplicates.
2. Write a query using EXCEPT to find categories that have products but no orders.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > SELECT c.name
   > FROM categories c
   > JOIN product_categories pc ON pc.category_id = c.category_id
   > EXCEPT
   > SELECT c.name
   > FROM categories c
   > JOIN product_categories pc ON pc.category_id = c.category_id
   > JOIN order_items oi ON oi.product_id = pc.product_id;
   > ```
   >
   > Returns 0 rows with my data, every category has at least one ordered product.

### Task 1.6: CTE

1. Write a CTE that calculates total revenue per category, then use it to find categories with above-average revenue.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > WITH category_revenue AS (
   >     SELECT c.name AS category,
   >            SUM(oi.quantity * oi.unit_price) AS revenue
   >     FROM categories c
   >     JOIN product_categories pc ON pc.category_id = c.category_id
   >     JOIN order_items oi ON oi.product_id = pc.product_id
   >     GROUP BY c.name
   > )
   > SELECT category, revenue
   > FROM category_revenue
   > WHERE revenue > (SELECT AVG(revenue) FROM category_revenue)
   > ORDER BY revenue DESC;
   > ```
2. Write a query with two CTEs: one for customer order counts, another for average order count, then find "top customers" (above average).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > WITH customer_orders AS (
   >     SELECT c.customer_id,
   >            c.first_name || ' ' || c.last_name AS full_name,
   >            COUNT(o.order_id) AS order_count
   >     FROM customers c
   >     LEFT JOIN orders o ON o.customer_id = c.customer_id
   >     GROUP BY c.customer_id, c.first_name, c.last_name
   > ),
   > avg_orders AS (
   >     SELECT AVG(order_count) AS avg_count
   >     FROM customer_orders
   > )
   > SELECT co.full_name, co.order_count
   > FROM customer_orders co, avg_orders a
   > WHERE co.order_count > a.avg_count
   > ORDER BY co.order_count DESC;
   > ```

---

## 2. Theory Review Questions

Answer these in your own words (2–4 sentences each):

1. What is the difference between an INNER JOIN and a LEFT JOIN? When would you choose LEFT JOIN?

> [!NOTE]
> **_Your Answer_**
>
> INNER JOIN only keeps rows that have a match in both tables. LEFT JOIN keeps every row from the left table, and if there is no match the right side columns just become NULL. I pick LEFT JOIN when I don't want to lose anyone, like listing all customers with their orders and still showing Timo who never ordered.

2. Explain what a correlated subquery is. Why can it be slower than an uncorrelated subquery?

> [!NOTE]
> **_Your Answer_**
>
> A correlated subquery uses a column from the outer query, so it can't run on its own. Because of that it basically runs again for every row of the outer query, like asking "what is the average price of THIS product's category?" once per product. An uncorrelated subquery runs once and the result is reused, so it is usually cheaper on big tables.

3. What is the difference between `IN` and `EXISTS`? When might you prefer EXISTS?

> [!NOTE]
> **_Your Answer_**
>
> IN checks if a value is inside a list of values that the subquery returns. EXISTS only asks "is there at least one row?" and stops as soon as it finds one. I prefer EXISTS for correlated checks on bigger tables, and NOT EXISTS is safer than NOT IN because NOT IN returns nothing at all if the list has a NULL in it.

4. What rules must two SELECT statements follow to be combined with UNION?

> [!NOTE]
> **_Your Answer_**
>
> Both SELECTs must return the same number of columns, in the same order, with compatible data types (you can't stack text on top of a number column). The column names in the result come from the first SELECT, and ORDER BY goes only once at the very end.

5. Explain the difference between UNION and UNION ALL. When would you use each?

> [!NOTE]
> **_Your Answer_**
>
> UNION removes duplicate rows, UNION ALL keeps everything. UNION ALL is faster because the database doesn't need to sort or compare rows to find duplicates. I use UNION when I want a clean unique list (like product names from two categories), and UNION ALL when duplicates are real data or I know there can't be any.

6. What is a view? Name two advantages of using views.

> [!NOTE]
> **_Your Answer_**
>
> A view is a saved SELECT query that you can use like a table, but it doesn't store its own data, it runs the query every time. Two advantages: it hides complex joins so others just write `SELECT * FROM v_customer_summary`, and it helps security because you can give someone access to the view without showing them the full tables (like hiding emails or prices).

7. What does `WITH CHECK OPTION` do on an updatable view?

> [!NOTE]
> **_Your Answer_**
>
> It stops INSERTs or UPDATEs through the view that would create rows the view itself can't see. For example, if a view only shows products with `price < 25`, CHECK OPTION will reject an update that sets a price to 100, because that row would "disappear" from the view.

8. How does a CTE differ from a derived table (subquery in FROM)? What's the main advantage of CTEs?

> [!NOTE]
> **_Your Answer_**
>
> Both create a temporary result to query from, but a CTE is written at the top with `WITH name AS (...)` and a derived table is written inline inside FROM. The main advantage of a CTE is readability: it gets a clear name, you read the query top to bottom like steps, and you can reuse the same CTE more than once in the query (like I did with `category_revenue` and its average). CTEs can also be recursive, which derived tables can't.

---

## 3. Query Writing Exercises (Optional)

> [!TIP]
> **Recommended practice.** Do this section. It is not required to finish the TrailShop project. It prepares you for the exams.

Write SQL queries for the following (use the TrailShop schema):

1. Find the most expensive product in each category using a correlated subquery.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
2. List all customers along with their most recent order date. Include customers who have never ordered (show NULL).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
3. Find categories where the total revenue exceeds €500 (use a subquery or CTE).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
4. Write a query that shows each order's total and whether it's 'Small' (< €50), 'Medium' (€50–€149.99), or 'Large' (≥ €150).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
5. Create a view called `v_never_ordered` that shows products that have never appeared in an order_item.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
6. Use EXCEPT to find products that exist in the products table but have never been ordered.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
7. Write a CTE that ranks categories by number of products, then selects only the top 3.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
8. Use `NOT EXISTS` to find categories that have no products.
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
9. Write a query using CASE that creates a "customer loyalty" label: 'New' (1 order), 'Regular' (2–5 orders), 'VIP' (6+ orders).
   > [!NOTE]
   > **_Your SQL_**
   >
   > ```sql
   > -- Write your query here
   >
   >
   > ```
10. Use GREATEST to find the higher value between each product's current price and the average price of all products in its category.
    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > -- Write your query here
    >
    >
    > ```
11. Write a query using COALESCE that shows order shipping dates, substituting 'Not yet shipped' for NULL values.
    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > -- Write your query here
    >
    >
    > ```
12. Use a scalar subquery in the SELECT clause to show each product alongside the total number of times it has been ordered.
    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > -- Write your query here
    >
    >
    > ```

---

## 4. Query Comparison Exercise (Optional)

> [!TIP]
> **Recommended practice.** Do this section. It is not required to finish the TrailShop project. It prepares you for the exams.

For each pair of queries below, both produce the same result. Explain which approach you'd prefer and why (consider readability, performance, and maintainability).

> [!NOTE]
> **_Your Answer_**
>
> _(Write your answer here.)_

### Pair A: Finding customers with orders

**Version 1 — Subquery with IN:**

```sql
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);
```

**Version 2 — JOIN:**

```sql
SELECT DISTINCT c.first_name, c.last_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id;
```

### Pair B: Finding products never ordered

**Version 1 — LEFT JOIN + IS NULL:**

```sql
SELECT p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;
```

**Version 2 — NOT EXISTS:**

```sql
SELECT p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
);
```

### Pair C: Customer total spending

**Version 1 — Derived table (subquery in FROM):**

```sql
SELECT sub.full_name, sub.total_spent
FROM (
    SELECT c.first_name || ' ' || c.last_name AS full_name,
           SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) sub
WHERE sub.total_spent > 200;
```

**Version 2 — CTE:**

```sql
WITH customer_totals AS (
    SELECT c.first_name || ' ' || c.last_name AS full_name,
           SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT full_name, total_spent
FROM customer_totals
WHERE total_spent > 200;
```

For each pair, discuss: readability, performance (in PostgreSQL), and when you'd choose one over the other.

> [!NOTE]
> **_Your Answer_**
>
> _(Write your answer here.)_

---

## Submission Checklist

**Required**

- [x] TrailShop queries written for subqueries, EXISTS, and CASE expressions
- [x] Three views created (`v_product_catalog`, `v_customer_summary`, `v_monthly_revenue`)
- [x] UNION/EXCEPT and CTE queries written
- [x] Theory review questions answered

**Recommended practice**

- [ ] Query writing exercises completed
- [ ] Query comparison exercise completed
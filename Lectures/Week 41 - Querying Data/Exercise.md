# Week 41 — Exercises: Querying Data


## Exercise 1: TrailShop Project Task — Business Questions

Use the TrailShop database you created in Week 40. Write SQL queries to answer each business question below. Run each query and verify the results make sense.

### Basic Queries (SELECT + WHERE)

1. List all products in the 'Footwear' category (show name, price, stock).

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT p.name, p.price, p.stock
    > FROM products p
    > JOIN product_categories pc ON pc.product_id = p.product_id
    > JOIN categories c ON c.category_id = pc.category_id
    > WHERE c.name = 'Footwear';
    > ```

2. Find all products priced between €50 and €150, sorted by price ascending.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT name, price
    > FROM products
    > WHERE price BETWEEN 50 AND 150
    > ORDER BY price ASC;
    > ```

3. Show all customers whose last name starts with the letter 'M' or 'K'.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT first_name, last_name
    > FROM customers
    > WHERE last_name LIKE 'M%' OR last_name LIKE 'K%';
    > ```

4. List all orders with status 'pending' or 'shipped', sorted by order date (most recent first).

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT order_id, customer_id, order_date, status
    > FROM orders
    > WHERE status IN ('pending', 'shipped')
    > ORDER BY order_date DESC;
    > ```

5. Find all products that have the word 'Pro' or 'pro' somewhere in their name.
    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT name, price
    > FROM products
    > WHERE name ILIKE '%pro%';
    > ```

### Aggregate Queries

6. What is the total number of products in the database?

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT COUNT(*) AS total_products
    > FROM products;
    > ```

7. What is the average price of all products? Round to 2 decimal places.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT ROUND(AVG(price), 2) AS avg_price
    > FROM products;
    > ```

8. Which is the most expensive product and which is the cheapest? Show both in one query.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT name, price
    > FROM products
    > WHERE price = (SELECT MAX(price) FROM products)
    >    OR price = (SELECT MIN(price) FROM products)
    > ORDER BY price DESC;
    > ```

9. How many orders does each customer have? Show customer name and order count, sorted by count descending.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT c.first_name || ' ' || c.last_name AS customer,
    >        COUNT(o.order_id) AS order_count
    > FROM customers c
    > LEFT JOIN orders o ON o.customer_id = c.customer_id
    > GROUP BY c.customer_id, c.first_name, c.last_name
    > ORDER BY order_count DESC;
    > ```

10. What is the total revenue (sum of quantity × unit_price from order_items) for each order status?

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT o.status,
    >        SUM(oi.quantity * oi.unit_price) AS total_revenue
    > FROM orders o
    > JOIN order_items oi ON oi.order_id = o.order_id
    > GROUP BY o.status
    > ORDER BY total_revenue DESC;
    > ```

### JOIN Queries

11. List all products with their category names (join through `product_categories`). A product in two categories should appear twice. Sort by category name, then product name.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT c.name AS category, p.name AS product
    > FROM products p
    > JOIN product_categories pc ON pc.product_id = p.product_id
    > JOIN categories c ON c.category_id = pc.category_id
    > ORDER BY c.name, p.name;
    > ```

12. Show each order with the customer's full name, order date, and status.

    > [!NOTE]
    > **_Your SQL_**
    >
    > ```sql
    > SELECT o.order_id,
    >        c.first_name || ' ' || c.last_name AS customer,
    >        o.order_date,
    >        o.status
    > FROM orders o
    > JOIN customers c ON c.customer_id = o.customer_id
    > ORDER BY o.order_id;
    > ```

13. Show a detailed breakdown of order #1: product name, quantity, unit price, and line total.

    > [!NOTE]
    > **_Your SQL_**
    >   
    > ```sql
    > SELECT p.name AS product,
    >        oi.quantity,
    >        oi.unit_price,
    >        oi.quantity * oi.unit_price AS line_total
    > FROM order_items oi
    > JOIN products p ON p.product_id = oi.product_id
    > WHERE oi.order_id = 1;
    > ```

14. Find all customers who have NOT placed any orders. (Hint: use LEFT JOIN + IS NULL pattern.)

    > [!NOTE]
    > **_Your SQL_**    
    >
    > ```sql
    > SELECT c.first_name, c.last_name, c.email
    > FROM customers c
    > LEFT JOIN orders o ON o.customer_id = c.customer_id
    > WHERE o.order_id IS NULL;
    > ```


15. For each category, show the category name, number of products, average price, and total inventory value (price × stock summed). Only include categories with total inventory value greater than €500.
    > [!NOTE]
    > **_Your SQL_**    
    >
    > ```sql
    > SELECT c.name AS category,
    >        COUNT(p.product_id) AS product_count,
    >        ROUND(AVG(p.price), 2) AS avg_price,
    >        SUM(p.price * p.stock) AS inventory_value
    > FROM categories c
    > JOIN product_categories pc ON pc.category_id = c.category_id
    > JOIN products p ON p.product_id = pc.product_id
    > GROUP BY c.category_id, c.name
    > HAVING SUM(p.price * p.stock) > 500
    > ORDER BY inventory_value DESC;
    > ```

---

## Exercise 2: Theory Review Questions

Answer in your own words:

1. What is the logical execution order of a SQL query? Why does it matter?

> [!NOTE]
> **_Your Answer_**
>
> SQL doesn't actually run in the order we write it. The order it runs is: FROM/JOIN, then WHERE, GROUP BY, HAVING, SELECT, DISTINCT, ORDER BY and last LIMIT/OFFSET.
>
> It matters because each step can only use stuff from the steps before it. So for example you can't use an alias from SELECT in WHERE because SELECT hasn't happened yet. Same reason you can't put AVG or COUNT in WHERE, the groups aren't made yet. But you can use the alias in ORDER BY since that runs after SELECT.

2. What is the difference between WHERE and HAVING? Give an example of when you would use each.

> [!NOTE]
> **_Your Answer_**
>
> WHERE filters rows before they get grouped, HAVING filters the groups after GROUP BY. That's why HAVING can use things like COUNT or AVG and WHERE can't.
>
> I'd use WHERE if I only want products in stock, like `WHERE stock > 0`. I'd use HAVING if I want only categories where the average price is over 100, like `HAVING AVG(price) > 100`. You can also use both in the same query.

3. Explain the difference between COUNT(\*), COUNT(column), and COUNT(DISTINCT column).

> [!NOTE]
> **_Your Answer_**
>
> COUNT(*) counts all rows even if there are NULLs. COUNT(column) only counts rows where that column isn't NULL. COUNT(DISTINCT column) counts how many different values there are, also skipping NULLs.
>
> So if a column has A, A, B, NULL then COUNT(*) is 4, COUNT(col) is 3 and COUNT(DISTINCT col) is 2.


4. What is the difference between INNER JOIN and LEFT JOIN? When would you choose one over the other?

> [!NOTE]
> **_Your Answer_**
>
> INNER JOIN only gives rows that match in both tables. LEFT JOIN gives all rows from the left table and if there's no match the right side is just NULL.
>
> I'd use INNER JOIN when I only want things that are connected, like orders with the customer name. LEFT JOIN is for when I want everything from one table anyway, like all customers even the ones with no orders. Also LEFT JOIN with IS NULL is how you find customers who never ordered.

5. Why should you avoid SELECT \* in production code?

> [!NOTE]
> **_Your Answer_**
>
> Because if someone adds or removes columns in the table, the query starts returning different stuff and it can break things. It also gets more data than you actually need which is slower. And it's harder to see what columns the code really uses. It's ok for quick testing but in real code it's better to write the column names.

6. What does DISTINCT do? On what level does it operate (columns or entire rows)?

> [!NOTE]
> **_Your Answer_**
>
> DISTINCT removes duplicate rows from the result. It works on the whole row, not just one column, so all the selected columns have to be the same for it to count as a duplicate. Like `SELECT DISTINCT status FROM orders` shows each status once, but if I add customer_id too then the same status can come up many times.

7. Can you use a column alias in a WHERE clause? Why or why not?

> [!NOTE]
> **_Your Answer_**
>
> No you can't. WHERE runs before SELECT so the alias doesn't exist yet when WHERE is checked. You have to write the full expression again, like `WHERE price * 1.24 > 100` instead of using the alias. In ORDER BY it works though because that runs after SELECT.

8. Explain what happens when you GROUP BY a column and there's a column in SELECT that isn't aggregated and isn't in GROUP BY.

> [!NOTE]
> **_Your Answer_**
>
> PostgreSQL gives an error that the column must be in GROUP BY or used in an aggregate function. It's because one group can have lots of rows with different values in that column, so it doesn't know which one to show. So the rule is every column in SELECT has to be in GROUP BY or inside something like COUNT, SUM, AVG.
---

## Exercise 3: Query Writing Exercises (Optional)


## Exercise 4: Query Reading Exercise (Optional)


**Required**

- [*] All 15 business questions answered with working SQL
- [*] Theory review questions answered in your own words
- [*] Results of the business questions verified by running them against your TrailShop database

**Recommended practice**

- [*] All 15 query writing exercises completed
- [*] All 5 query reading explanations written
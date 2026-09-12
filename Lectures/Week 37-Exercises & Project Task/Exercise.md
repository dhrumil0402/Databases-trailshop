# Week 37 — Exercises & Project Task


---

## Part 1: TrailShop Project Task

### Task 1: Identify Keys

Using the `products`, `categories`, and `customers` tables shown in Section 2 of this week's Theory material, answer:

1. What is the primary key of the `products` table? Why is it a good choice?

> [!NOTE]
> ***Your Answer***
>
>**product_id.** *It's a good choice because it's a surrogate key: just a plain integer with no real-world meaning, and it's guaranteed to be unique and stable. Even if the product's name, price, or category changes, the ID never has to.*
>


2. What is the primary key of the `categories` table?

> [!NOTE]
> ***Your Answer***
>
> **category_id***, for the same reason. It's a simple, stable, unique integer that identifies each category.*
>


3. What is the foreign key in the `products` table? What does it reference?

> [!NOTE]
> ***Your Answer***
>
> **category_id***. It references **categories.category_id**, and that's what links each product to the category it belongs to.*
>


4. Is `name` in `products` a candidate key? Under what assumption? What would make it unsuitable as a primary key?


> [!NOTE]
> ***Your Answer***
>
> *Yes, but only under the assumption that no two products ever share the same name (which the Section 9.8 schema actually enforces, since **name** is marked **UNIQUE NOT NUL**L). It wouldn't make a good primary key though, because it's a natural attribute that could realistically change over time, for example if a product gets renamed or rebranded. It's also less efficient to index and join on compared to a plain integer, and there's always a risk that naming conventions slip and two products end up with the same name.*
>


5. Give an example of a **superkey** for the `products` table that is NOT a candidate key. Explain why it's not minimal.

> [!NOTE]
> ***Your Answer***
>
> **{product_id, name}***. This is a superkey since it definitely identifies each row uniquely, but it's not minimal because **product_id** alone already does the job. Adding **name** doesn't add any uniqueness, so it's redundant.*
>


6. Give an example of a **composite key** using a hypothetical `order_items` table. Explain why neither column alone would be sufficient.

> [!NOTE]
> ***Your Answer***
>
> **(order_id, product_id)***. Neither column works alone: **order_id** repeats for every product in that order, and **product_id** repeats across many different orders. But together, that combination shows up at most once, so the pair is what uniquely identifies each line item.*
>


7. Is `email` in `customers` a candidate key? What makes it different from `customer_id` as a PK choice? *(See Section 6.9 on natural vs surrogate keys.)*

> [!NOTE]
> ***Your Answer***
>
> *Yes. Section 9.8 defines **email** as **NOT NULL UNIQUE**, so it's both unique and minimal on its own, which makes it a candidate key. What separates it from **customer_id** as a PK choice is that email is a natural key: it has real business meaning and it can actually change if a customer updates their address. **customer_id** on the other hand is a surrogate key, meaningless on its own, but stable and never needing to change. That stability is exactly why **customer_id** is the better choice for primary key, while **email** still gets protected as an alternate key through the **UNIQUE** constraint.*
>


### Task 2: Define Business Rules

List **5 business rules** for TrailShop. For each rule, specify:
- The rule in plain English
- Which constraint type(s) would enforce it
- Which table and column the constraint applies to
- The SQL syntax for the constraint

Example:

| Business Rule | Constraint Type | Table.Column | SQL |
|---|---|---|---|
| Every product must have a price greater than zero | CHECK | products.price | `CHECK (price > 0)` |
| ... | ... | ... | ... |

Think about rules for customers, orders, and categories — not just products.
> [!NOTE]
> ***Your Answer***
>
> | Business Rule | Constraint Type | Table.Column | SQL |
> |---|---|---|---|
> | Every product must have a price greater than zero | CHECK | `products.price` | `CHECK (price > 0)` |
> | Customer email addresses must be unique | UNIQUE | `customers.email` | `email VARCHAR(255) UNIQUE` |
> | Every order must be placed by an existing customer | NOT NULL + FOREIGN KEY | `orders.customer_id` | `customer_id INTEGER NOT NULL REFERENCES customers(customer_id)` |
> | Category names must be unique | UNIQUE | `categories.category_name` | `category_name VARCHAR(50) NOT NULL UNIQUE` |
> | Each line item's quantity must be a positive number | CHECK | `order_items.quantity` | `CHECK (quantity > 0)` |
>
> 
### Task 3: Integrity Violations

For each SQL statement below, predict whether it will **succeed** or **fail**. If it fails, explain which integrity rule or constraint is violated and what error message you'd expect. Assume the schema from Section 9.8 of the Theory material.

```sql
-- Statement A
INSERT INTO categories (category_id, category_name)
VALUES (NULL, 'Cycling');

-- Statement B
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (109, 'AeroLite Tent', 279.00, 10, 2);

-- Statement C
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (110, 'BudgetBoots', -5.00, 25, 1);

-- Statement D
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (103, 'Duplicate Shoes', 99.99, 5, 3);

-- Statement E
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (111, 'CloudWalker Sandals', 65.00, 40, 10);

-- Statement F
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (112, NULL, 89.99, 20, 1);

-- Statement G
INSERT INTO products (product_id, name, price, stock_quantity, category_id)
VALUES (113, 'LightStep Shoes', 149.00, -3, 1);

-- Statement H
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1001, 101, 0, 189.50);
```
> [!NOTE]
> ***Your Answer***
>
> | # | Result | Explanation |
> |---|---|---|
> | **A** | **FAIL** | `category_id` is the primary key of `categories`, and a primary key can never be `NULL` (that's entity integrity). Expected error: `null value in column "category_id" of relation "categories" violates not-null constraint`. |
> | **B** | **SUCCESS** | `product_id` 109 is new, `category_id` 2 already exists, the name is unique, and the price and stock values are both valid. Nothing here breaks a rule. |
> | **C** | **FAIL** | A price of `-5.00` breaks the `CHECK (price > 0)` constraint. Expected error: `new row for relation "products" violates check constraint "products_price_check"`. |
> | **D** | **FAIL** | `product_id` 103 already exists (it's `GripWall Climbing Shoes`), so this breaks the primary key's uniqueness rule. Expected error: `duplicate key value violates unique constraint "products_pkey"`. |
> | **E** | **FAIL** | `category_id` 10 doesn't exist anywhere in `categories`, so this is an orphan record and a referential integrity violation. Expected error: `insert or update on table "products" violates foreign key constraint "products_category_id_fkey"`. |
> | **F** | **FAIL** | `name` is `NOT NULL`, and this statement tries to insert `NULL` for it. Expected error: `null value in column "name" of relation "products" violates not-null constraint`. |
> | **G** | **FAIL** | A stock quantity of `-3` breaks `CHECK (stock_quantity >= 0)`. Expected error: `new row for relation "products" violates check constraint "products_stock_quantity_check"`. |
> | **H** | **FAIL** | A quantity of `0` breaks `CHECK (quantity > 0)` on `order_items`. Expected error: `new row for relation "order_items" violates check constraint`. Worth noting: this would also depend on whether order 1001 actually exists in `orders`, but even if it did, the quantity check alone is enough to fail this insert. |

### Task 4: Foreign Key Actions

Consider the following scenario using the schema from Theory Section 9.8:

1. You want to delete category 2 ("Camping") from the `categories` table. Products 102 and 106 reference this category. What happens with:
   - `ON DELETE RESTRICT`?
   - `ON DELETE CASCADE`?
   - `ON DELETE SET NULL`? (Assume `category_id` in `products` allows NULL for this question)

2. Which foreign key action would you recommend for the TrailShop `products.category_id` → `categories.category_id` relationship? Justify your choice in 2–3 sentences.

> > [!NOTE]
> ***Your Answer***
>
>*With `ON DELETE RESTRICT`, the delete gets rejected outright. PostgreSQL throws a foreign key violation error, and category 2 stays exactly as it was, since products 102 and 106 still reference it.*
>
>*With `ON DELETE CASCADE`, category 2 gets deleted, and products 102 and 106 are automatically deleted right along with it.*
>
>*With `ON DELETE SET NULL` (assuming `category_id` allows NULL), category 2 gets deleted, but products 102 and 106 stick around, just with their `category_id` automatically switched to `NULL`, meaning they become uncategorized.*
>
> *For TrailShop, `ON DELETE RESTRICT` is the best choice. Products represent real inventory and sales data, so letting them disappear automatically (CASCADE) just because a category was deleted would be risky and hard to undo. RESTRICT forces whoever manages categories to make a deliberate decision first, like reassigning or explicitly deleting the affected products, instead of it happening as an automatic side effect.*




---

## Part 2: Theory Review Questions

Answer each question in 2–4 sentences unless otherwise specified. Reference the Theory material sections as needed.

### Short-Answer Questions

**Q1.** Define the following terms in your own words: relation, tuple, attribute, domain. Give one TrailShop example for each.

> > [!NOTE]
> ***Your Answer***
>
> A relation is the formal term for a table, a named structure made up of rows and columns that holds data about one type of thing. For example, the `products` table is a relation.
>
> A tuple is the formal term for a row, one single record inside a relation. For example, the row `(102, 'TrailMaster X4 Tent', 249.99, 15, 2)` is a tuple in the `products` relation.
>
> An attribute is the formal term for a column, a single property that every tuple in the relation has a value for. For example, `price` is an attribute of the `products` relation.
>
> A domain is the set of all values that are allowed for a given attribute. For example, the domain of `price` is positive decimal numbers, so a value like `-5.00` or the text `"free"` would not belong to that domain.

*(See Sections 2 and 3 of this week's Theory material.)*

**Q2.** What makes a candidate key different from a primary key? Can a table have more than one candidate key?


> [!NOTE]
> ***Your Answer***
>
> *A candidate key is any minimal set of attributes that uniquely identifies every row in a table, meaning nothing can be removed from it without losing that uniqueness. A primary key is simply the one candidate key that the designer chooses to actually serve as the official row identifier. Yes, a table can absolutely have more than one candidate key. For example, in `products`, both `product_id` and `name` (assuming names are unique) could work as candidate keys, but only `product_id` gets picked as the primary key, and `name` becomes what is called an alternate key.*
>

*(See Section 6 of this week's Theory material.)*

**Q3.** Explain entity integrity in your own words. Why can't a primary key be NULL?


> [!NOTE]
> ***Your Answer***
>
> *Entity integrity is the rule that every table must have a primary key, and no part of that primary key is allowed to be NULL. A primary key cannot be NULL because its entire purpose is to uniquely identify a row. If the value were missing, there would be no reliable way to find, reference, update, or delete that specific row, which would break the whole idea of having an identifiable record in the first place.*
>

*(See Section 8.1 of this week's Theory material.)*

**Q4.** What happens when referential integrity is violated? Give a concrete TrailShop example — show the SQL statement and the expected error.

> [!NOTE]
> ***Your Answer***
>
> *Referential integrity is violated when a foreign key value points to a row that does not exist in the referenced table, creating what is called an orphan record. For example:*
>
> *```sql*
> *INSERT INTO products (product_id, name, price, stock_quantity, category_id)*
> *VALUES (109, 'Ghost Product', 59.99, 5, 99);*
> *```*
>
> *Since category 99 does not exist in the `categories` table, PostgreSQL rejects the insert with an error like:*
>
> *```*
> *ERROR:  insert or update on table "products" violates foreign key constraint "products_category_id_fkey"*
> *DETAIL:  Key (category_id)=(99) is not present in table "categories".*
> *```*
>

*(See Section 8.2 of this week's Theory material.)*

**Q5.** Explain the difference between a surrogate key and a natural key. Give an example of each for a `books` table in a library database.

> [!NOTE]
> ***Your Answer***
>
> *A surrogate key is an artificial identifier with no real-world meaning, usually just an auto-incrementing number, whose only job is to uniquely identify a row. A natural key is drawn from real business data and actually means something in the real world. For a `books` table in a library database, a surrogate key example would be a system-generated `book_id`, while a natural key example would be the book's ISBN, since the ISBN is a real, meaningful identifier that already exists independently of the database*
>

*(See Section 6.8–6.9 of this week's Theory material.)*

**Q6.** What is a NULL value? Why is `WHERE price = NULL` wrong? What should you write instead?


> [!NOTE]
> ***Your Answer***
>
> *A NULL value represents something unknown or not applicable, it is not the same as zero, an empty string, or blank space. Writing `WHERE price = NULL` is wrong because comparing anything to NULL never returns TRUE, it returns UNKNOWN, so that query will silently return zero rows even if some prices genuinely are NULL. Instead, you should write `WHERE price IS NULL` to correctly check for missing values.*
>

*(See Section 7 of this week's Theory material.)*

**Q7.** What is a junction table? When is it needed? Give an example.

> [!NOTE]
> ***Your Answer***
>
> *A junction table (also called a linking or bridge table) is a table created specifically to implement a many to many relationship, since a plain foreign key can only express one to many. It is needed whenever two entities can each relate to multiple instances of the other. For example, `product_tags` is a junction table that connects `products` and `tags`, since one product can have many tags and one tag can apply to many products.*
>

*(See Section 12.3 of this week's Theory material.)*

**Q8.** Describe the three types of relationships (1:1, 1:N, M:N). For each, give one TrailShop example.

> [!NOTE]
> ***Your Answer***
>
> *A one to one relationship (1:1) means one row in a table relates to exactly one row in another, and vice versa. A TrailShop example would be `products` and `product_details`, where each product has exactly one detailed description record.*
>
> *A one to many relationship (1:N) means one row in a table can relate to many rows in another, but each of those rows only relates back to one row. A TrailShop example would be `categories` and `products`, where one category can have many products, but each product belongs to only one category.*
>
> *A many to many relationship (M:N) means rows on both sides can relate to multiple rows on the other side. A TrailShop example would be `products` and `tags`, where one product can have several tags and one tag can be applied to many products, which is why it needs the `product_tags` junction table.*
>

*(See Section 12 of this week's Theory material.)*

**Q9.** What is the difference between `ON DELETE CASCADE` and `ON DELETE RESTRICT`? When would you use each?


> [!NOTE]
> ***Your Answer***
>
> *`ON DELETE CASCADE` automatically deletes any rows that reference the row being deleted, while `ON DELETE RESTRICT` blocks the deletion entirely if any rows still reference it. CASCADE is useful when the dependent rows have no meaning without the parent, for example deleting an order and having its order_items disappear with it. RESTRICT is safer for cases like categories and products, where deleting a category should not be allowed to silently wipe out real inventory data, forcing the user to handle those products first.*
>

*(See Section 10 of this week's Theory material.)*

**Q10.** Explain what "atomic entries" means in the context of relation properties. Give an example of a violation.

> [!NOTE]
> ***Your Answer***
>
> *Atomic entries means that every single cell in a table must hold one indivisible value, not a list or a set of multiple values crammed together. A violation example would be a `products` table with a `categories` column containing the value `"Footwear, Hiking"` in one cell, since that is actually two separate values stored as one, which makes it difficult to search or filter properly with standard SQL.*
>

*(See Section 5.3 of this week's Theory material.)*

### True/False

For each statement, write **True** or **False** and correct any false statements.

1. A superkey is always a candidate key.
False. A superkey only needs to guarantee uniqueness, it does not need to be minimal, so a superkey is only a candidate key if no attribute can be removed from it without losing uniqueness.

2. A primary key can consist of more than one column.
True.

3. NULL = NULL evaluates to TRUE in SQL.
False. `NULL = NULL` evaluates to UNKNOWN, not TRUE.

4. A foreign key must always be NOT NULL.
False. A foreign key can be NULL if the business rule allows it, for example a product that has not been assigned a category yet.

5. Referential integrity ensures that every FK value matches an existing PK value (or is NULL).
True.

6. The degree of a relation is the number of rows.
False. The degree of a relation is the number of columns (attributes). The number of rows is called the cardinality.

### Matching Exercise

Match each term (1–12) with its definition (A–L).

| # | Term |
|---|---|
| 1 | Superkey |
| 2 | Candidate key |
| 3 | Composite key |
| 4 | Foreign key |
| 5 | Alternate key |
| 6 | Surrogate key |
| 7 | Natural key |
| 8 | Orphan record |
| 9 | Domain |
| 10 | Junction table |
| 11 | Cardinality |
| 12 | COALESCE |

| Letter | Definition |
|---|---|
| A | The set of all permitted values for an attribute |
| B | A key composed of two or more attributes |
| C | A row whose FK references a non-existent PK — forbidden by referential integrity |
| D | An artificial key with no business meaning (e.g., auto-generated ID) |
| E | A candidate key not chosen as the primary key |
| F | Any set of attributes that uniquely identifies every tuple |
| G | A minimal superkey — no attribute can be removed without losing uniqueness |
| H | A column that references the primary key of another table |
| I | The number of tuples (rows) in a relation |
| J | A key drawn from real-world data with business meaning |
| K | A table implementing a many-to-many relationship |
| L | A SQL function that returns the first non-NULL argument |


> [!NOTE]
> ***Your Answers***
>
> | # | Your Match |
> |---|---|
> | 1 | F |
> | 2 | G |
> | 3 | B |
> | 4 | H |
> | 5 | E |
> | 6 | D |
> | 7 | J |
> | 8 | C |
> | 9 | A |
> | 10 | K |
> | 11 | I |
> | 12 | L |
>

---

## Part 3: SQL Practice — Constraints in Action

These exercises test your understanding of constraints. You do NOT need to run these in PostgreSQL (but you may if you'd like to verify your answers).

### Exercise 3.1: Predict the Outcome

Given the following table definitions:

```sql
CREATE TABLE departments (
    dept_id   INTEGER      PRIMARY KEY,
    dept_name VARCHAR(50)  NOT NULL UNIQUE
);

CREATE TABLE employees (
    emp_id    INTEGER       PRIMARY KEY,
    name      VARCHAR(100)  NOT NULL,
    salary    NUMERIC(10,2) NOT NULL CHECK (salary >= 0),
    dept_id   INTEGER       NOT NULL REFERENCES departments(dept_id)
);
```

Assume these rows already exist:

```sql
INSERT INTO departments VALUES (1, 'Engineering');
INSERT INTO departments VALUES (2, 'Marketing');
INSERT INTO employees VALUES (100, 'Alice', 75000, 1);
INSERT INTO employees VALUES (101, 'Bob', 65000, 2);
```

For each statement below, predict: **SUCCESS** or **FAIL**? If fail, name the violated constraint.

```sql
-- 1
INSERT INTO employees VALUES (102, 'Carol', 70000, 1);

-- 2
INSERT INTO employees VALUES (103, 'Dan', -5000, 1);

-- 3
INSERT INTO employees VALUES (100, 'Eve', 80000, 2);

-- 4
INSERT INTO employees VALUES (104, 'Frank', 60000, 5);

-- 5
INSERT INTO departments VALUES (3, 'Engineering');

-- 6
INSERT INTO employees VALUES (105, NULL, 55000, 2);

-- 7
DELETE FROM departments WHERE dept_id = 1;

-- 8
INSERT INTO employees VALUES (106, 'Grace', 0, 2);
```
> [!NOTE]
> ***Your Answer***
>
> | # | Statement | Result | Explanation |
> |---|---|---|---|
> | 1 | `INSERT employees (102, 'Carol', 70000, 1)` | **SUCCESS** | `emp_id` 102 is new, `dept_id` 1 exists, and salary is positive. Nothing is violated. |
> | 2 | `INSERT employees (103, 'Dan', -5000, 1)` | **FAIL** | Salary of `-5000` violates `CHECK (salary >= 0)`. |
> | 3 | `INSERT employees (100, 'Eve', 80000, 2)` | **FAIL** | `emp_id` 100 already exists (Alice), so this violates the primary key's uniqueness constraint. |
> | 4 | `INSERT employees (104, 'Frank', 60000, 5)` | **FAIL** | `dept_id` 5 doesn't exist in `departments`, so this violates the foreign key constraint (referential integrity). |
> | 5 | `INSERT departments (3, 'Engineering')` | **FAIL** | `dept_id` 3 is new, but `dept_name` 'Engineering' already exists, and `dept_name` is `UNIQUE`. |
> | 6 | `INSERT employees (105, NULL, 55000, 2)` | **FAIL** | `name` is `NOT NULL`, and this tries to insert `NULL`. |
> | 7 | `DELETE FROM departments WHERE dept_id = 1` | **FAIL** | Employee 100 (Alice) still references `dept_id` 1, and no `ON DELETE` action was specified, so PostgreSQL defaults to `NO ACTION`, which behaves like `RESTRICT` and blocks the delete. |
> | 8 | `INSERT employees (106, 'Grace', 0, 2)` | **SUCCESS** | Salary of `0` satisfies `CHECK (salary >= 0)`, since the constraint allows zero, and `dept_id` 2 exists. |

### Exercise 3.2: Write the Constraints

Given these business rules for a **bookstore database**, write the `CREATE TABLE` statements with appropriate constraints:

1. Every book has a unique ISBN (13 characters), a title (required), a price (must be positive), and a publication year.
2. Every author has an ID, a first name (required), and a last name (required).
3. A book can have multiple authors, and an author can write multiple books.
4. Every book belongs to exactly one genre. Genres have an ID and a unique name.
5. Publication year must be between 1450 and the current year.

*(Hint: you'll need at least 4 tables, including a junction table for the M:N relationship.)*

> [!NOTE]
> ***Your SQL***
>
> ```sql
> CREATE TABLE genres (
>     genre_id   INTEGER      PRIMARY KEY,
>     genre_name VARCHAR(50)  NOT NULL UNIQUE
> );
>
> CREATE TABLE authors (
>     author_id  INTEGER      PRIMARY KEY,
>     first_name VARCHAR(50)  NOT NULL,
>     last_name  VARCHAR(50)  NOT NULL
> );
>
> CREATE TABLE books (
>     isbn              CHAR(13)      PRIMARY KEY,
>     title             VARCHAR(200)  NOT NULL,
>     price             NUMERIC(10,2) NOT NULL CHECK (price > 0),
>     publication_year  INTEGER       NOT NULL
>                       CHECK (publication_year BETWEEN 1450 AND EXTRACT(YEAR FROM CURRENT_DATE)),
>     genre_id          INTEGER       NOT NULL REFERENCES genres(genre_id)
> );
>
> CREATE TABLE book_authors (
>     isbn       CHAR(13) REFERENCES books(isbn),
>     author_id  INTEGER  REFERENCES authors(author_id),
>     PRIMARY KEY (isbn, author_id)
> );
> ```

---

## Part 4: Design Exercise — Library System

A small public library needs a database. Here is a description of their requirements:

> The library has a collection of **books**. Each book has an ISBN, a title, a publication year, and belongs to one genre (Fiction, Non-Fiction, Science, History, etc.). The library may own multiple **copies** of the same book — each copy has a unique barcode sticker.
>
> The library has registered **members**. Each member has a member number, name, email, and phone. Members can **borrow** copies. Each borrowing records which member borrowed which copy, the borrow date, the due date, and the return date (NULL if not yet returned).
>
> **Rules:**
> - A member can borrow at most 5 copies at any given time.
> - The due date is always 14 days after the borrow date.
> - A copy cannot be borrowed if it's currently not returned (return_date IS NULL).

### Your Tasks

1. **Identify the tables** you would need (list them with their columns).
2. **Identify the primary key** for each table. Are they surrogate or natural keys? Justify your choices.
3. **Identify all foreign keys** and the tables they reference.
4. **Identify any candidate keys** beyond the primary key (alternate keys).
5. **List the business rules** from the description and map each to a constraint type. Which rules cannot be enforced by simple constraints?

> [!NOTE]
> ***Your Answer***
>
> **1. Tables needed:**
>
> - `genres` (genre_id, genre_name)
> - `books` (isbn, title, publication_year, genre_id)
> - `copies` (copy_id, isbn, barcode)
> - `members` (member_id, member_number, name, email, phone)
> - `borrowings` (borrowing_id, member_id, copy_id, borrow_date, due_date, return_date)
>
> **2. Primary keys, surrogate vs natural:**
>
> - `genres.genre_id` — surrogate. A simple stable integer is enough; genre names could technically be reused or renamed later, so I didn't want the name itself as the identifier.
> - `books.isbn` — natural key. The description explicitly says every book has an ISBN, and ISBNs are already globally unique and never change, so there is no reason to invent a surrogate `book_id` on top of it.
> - `copies.copy_id` — surrogate. Even though each copy has a unique barcode (a natural key), I used a surrogate `copy_id` as the PK for simplicity and consistency with the other tables, and kept `barcode` as a `UNIQUE` alternate key instead.
> - `members.member_id` — surrogate. The description mentions a "member number," which sounds like a natural key, but member numbers can sometimes be reissued or reformatted by libraries over time, so a surrogate `member_id` is the safer long-term PK, with `member_number` enforced as a unique alternate key.
> - `borrowings.borrowing_id` — surrogate. I chose a single surrogate key here instead of a composite key like `(member_id, copy_id)`, because the same member can borrow the same copy more than once over time (borrow it, return it, borrow it again months later), so `(member_id, copy_id)` would not actually be unique across all rows.
>
> **3. Foreign keys:**
>
> - `books.genre_id` → `genres.genre_id`
> - `copies.isbn` → `books.isbn`
> - `borrowings.member_id` → `members.member_id`
> - `borrowings.copy_id` → `copies.copy_id`
>
> **4. Candidate/alternate keys beyond the primary key:**
>
> - `copies.barcode` — alternate key (unique, since every copy has a unique barcode sticker)
> - `members.member_number` — alternate key (unique, assuming the library assigns one per member)
> - `members.email` — alternate key (unique, assuming no two members share an email)
>
> **5. Business rules and how they map to constraints:**
>
> | Business Rule | Constraint Type | Can simple constraints enforce it? |
> |---|---|---|
> | A member can borrow at most 5 copies at a time | None available as a simple constraint | **No.** This requires counting a member's currently unreturned borrowings across multiple rows, which a single-row CHECK constraint cannot do. This needs a trigger or application-level logic. |
> | The due date is always 14 days after the borrow date | Generated column | **Yes**, using `due_date GENERATED ALWAYS AS (borrow_date + 14) STORED`, PostgreSQL computes it automatically and it can never drift out of sync. |
> | A copy cannot be borrowed if it's currently not returned | Partial unique index | **Yes**, a partial unique index on `borrowings(copy_id) WHERE return_date IS NULL` ensures a copy can only appear once among "currently active" borrowings, effectively preventing double-borrowing without needing a trigger. |

6. **Write the CREATE TABLE statements** for at least the `books`, `copies`, and `borrowings` tables with full constraints.

> [!NOTE]
> ***Your SQL***
>
> ```sql
> CREATE TABLE genres (
>     genre_id   INTEGER      PRIMARY KEY,
>     genre_name VARCHAR(50)  NOT NULL UNIQUE
> );
>
> CREATE TABLE books (
>     isbn              CHAR(13)      PRIMARY KEY,
>     title             VARCHAR(200)  NOT NULL,
>     publication_year  INTEGER       NOT NULL
>                       CHECK (publication_year BETWEEN 1450 AND EXTRACT(YEAR FROM CURRENT_DATE)),
>     genre_id          INTEGER       NOT NULL REFERENCES genres(genre_id)
> );
>
> CREATE TABLE members (
>     member_id     INTEGER      PRIMARY KEY,
>     member_number VARCHAR(20)  NOT NULL UNIQUE,
>     name          VARCHAR(100) NOT NULL,
>     email         VARCHAR(255) NOT NULL UNIQUE,
>     phone         VARCHAR(20)
> );
>
> CREATE TABLE copies (
>     copy_id  INTEGER      PRIMARY KEY,
>     isbn     CHAR(13)     NOT NULL REFERENCES books(isbn),
>     barcode  VARCHAR(30)  NOT NULL UNIQUE
> );
>
> CREATE TABLE borrowings (
>     borrowing_id INTEGER   PRIMARY KEY,
>     member_id    INTEGER   NOT NULL REFERENCES members(member_id),
>     copy_id      INTEGER   NOT NULL REFERENCES copies(copy_id),
>     borrow_date  DATE      NOT NULL DEFAULT CURRENT_DATE,
>     due_date     DATE      GENERATED ALWAYS AS (borrow_date + 14) STORED,
>     return_date  DATE
> );
>
> -- Enforces "a copy cannot be borrowed if it's currently not returned":
> -- only one active (unreturned) borrowing per copy is allowed at a time
> CREATE UNIQUE INDEX one_active_borrowing_per_copy
>     ON borrowings (copy_id)
>     WHERE return_date IS NULL;
> ```

---

## Submission Checklist

- [*] Task 1: Key identification answers (Part 1)
- [*] Task 2: Business rules table with 5 rules (Part 1)
- [*] Task 3: Integrity violation predictions with explanations (Part 1)
- [*] Task 4: Foreign key action analysis (Part 1)
- [*] Theory Review Questions answered (Part 2)
- [*] SQL Practice — constraint predictions and bookstore CREATE TABLE (Part 3)
- [*] Library System design exercise (Part 4)

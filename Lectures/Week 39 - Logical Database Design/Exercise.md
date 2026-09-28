# Week 39 — Logical Database Design: Exercises

> [!IMPORTANT]
> ***How to Complete These Exercises***
> Write your answers directly in the highlighted **Your Answer** / **Your SQL** fields below each task. Replace the placeholder text with your own work before submitting.

These exercises accompany the Week 39 Theory material. Refer to the theory sections indicated in brackets when you need help.

---

## Exercise 1: TrailShop Project Task — Build the Schema

**Goal:** Convert the TrailShop ER diagram (from Week 38) into a complete PostgreSQL relational schema.

### Instructions

Write `CREATE TABLE` statements for all six TrailShop tables:

1. `categories`
2. `customers`
3. `products`
4. `product_categories`
5. `orders`
6. `order_items`

### Requirements

For each table, you must:

- Choose appropriate PostgreSQL data types for every column (justify at least 3 choices in writing)
- Define primary keys (surrogate or composite as appropriate)
- Define foreign keys with explicit `ON DELETE` and `ON UPDATE` actions (justify each choice)
- Add `NOT NULL`, `UNIQUE`, `CHECK`, and `DEFAULT` constraints where appropriate
- Create tables in the correct dependency order
- Follow the naming conventions from Theory Section 8

### Deliverables

1. A single `.sql` file with all six `CREATE TABLE` statements (executable in PostgreSQL)
2. A short justification for data types, FK actions and design decisions:
   - Justification for 3 data type choices (e.g., why `NUMERIC(10,2)` for price instead of `REAL`)
   - Justification for each FK action choice (e.g., why CASCADE on `order_items.order_id`)
   - One design decision you made that wasn't specified in the requirements (e.g., whether shipping address is optional)


## Exercise 2: Theory Review Questions

Answer each question in 2–4 sentences. Reference the relevant theory section.

1. List the seven phases of the database development lifecycle in order. Which phase is this week's focus? *(Section 1)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>The order is: requirements, conceptual design, logical design, physical design, implementation, testing, maintenance. Easy way to remember it: plan it, draw it, structure it, tune it, build it, test it, look after it. This week is logical design, where the ER diagram turns into real tables with types, keys and constraints.
>
>
>

2. Explain the transformation rule for mapping a 1:N relationship to the relational model. Why is the foreign key placed on the "many" side? *(Section 3.2)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>The foreign key goes on the "many" side. Think of it like this: each child points to one parent, so one column is enough. If you put it on the parent, one cell would have to hold a whole list of IDs, and that breaks the one value per cell rule. Example: many orders, one customer, so `orders` gets `customer_id`.
>
>
>
>

3. What is a junction table? When is it needed? Give an example not from TrailShop. *(Section 3.3)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>A junction table is the middle table that connects two tables in a many-to-many relationship. It just holds the two foreign keys, and together they form the primary key. You need it whenever both sides can have many of the other. Example: students and courses. One `enrollments` table with `student_id` and `course_id` links them.
>
>
>
>

4. When mapping a 1:1 relationship, how do you decide which table gets the foreign key? *(Section 3.4)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
> Put the foreign key in one of the two tables and make it UNIQUE. To pick which one: if one side is mandatory, put it there because it will always have a value. If both are mandatory, pick whichever feels natural. If both are optional, put it on the side that will usually have a value and allow NULL.
>
>
>
>

5. How does the mapping of a weak entity differ from a strong entity? What happens to the primary key? *(Section 3.5)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
> A strong entity can stand on its own and has its own primary key, like `customers`. A weak entity can't be identified without its owner, so its primary key includes the owner's key. Example: `order_items` uses `(order_id, product_id)`, because an item means nothing without its order.
>
>
>

6. Why should you never use `REAL` or `DOUBLE PRECISION` for monetary values? What should you use instead? *(Section 4.1)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
> They store approximate numbers, so tiny rounding errors sneak in. For example, 0.1 + 0.2 in REAL gives 0.30000001, not exactly 0.3. With money, even small errors are a problem. Use `NUMERIC(10,2)` instead, because it is exact.
>
>
>

7. What is the difference between `TIMESTAMP` and `TIMESTAMPTZ`? Which should you prefer and why? *(Section 4.3)*
> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>`TIMESTAMP` has no timezone, so the same value can mean different things in different places. `TIMESTAMPTZ` saves the time in UTC and shows it in the user's timezone. So I would always pick `TIMESTAMPTZ`, because it avoids timezone mix-ups




8. Explain the difference between `CASCADE` and `RESTRICT` as foreign key delete actions. Give a scenario where each is appropriate. *(Section 6)*
> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>CASCADE means delete the parent and the children go with it. RESTRICT means you can't delete the parent while children exist. Use CASCADE when children are useless without the parent, like order items when an order is deleted. Use RESTRICT when the history matters, like a customer who already has orders.
>




9. What is an insertion anomaly? Give an example and explain how proper schema design prevents it. *(Section 7)*
> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>An insertion anomaly is when you can't add one thing without adding something unrelated. Example: if products and categories sit in one table, you can't add a new category like "Cycling" until you have a product for it. Good design fixes this by giving categories their own table.




10. What is the difference between a surrogate key and a natural key? Give one advantage of each. *(Section 9)*
> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>A surrogate key is a made-up ID with no meaning, like SERIAL. A natural key is a real world value, like an email or ISBN. Surrogate advantage: it never changes and it is small and fast. Natural advantage: it already has meaning, so people recognise it.




11. Why does PostgreSQL fold unquoted identifiers to lowercase? How does `snake_case` naming help? *(Section 8)*

> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>PostgreSQL turns unquoted names into lowercase, so `OrderItems` becomes `orderitems`. To keep capitals you would have to use double quotes every time. With snake_case, like `order_items`, it is already lowercase, so you never need quotes.
>
>
>

12. What does `SET NULL` do as a foreign key action? When would you use it instead of `CASCADE`? *(Section 6)*
> [!NOTE]
> ***Your Answer***
>
> *(Write your answer here.)*
>SET NULL keeps the child row but clears its foreign key to NULL when the parent is deleted. Use it instead of CASCADE when the child should survive without the link. Example: a manager leaves, their employees stay, they just have no manager for now. The column must allow NULL for this to work.




---

## Exercise 3: Transformation Exercise — Hotel Booking System

### Given ER Diagram

A hotel booking system has the following entities and relationships:

**Entities:**

1. **Hotel** — hotel_id (PK), name, city, star_rating, phone
2. **Room** (weak entity, owned by Hotel) — room_number (partial key), room_type, floor, price_per_night, has_balcony
3. **Guest** — guest_id (PK), first_name, last_name, email, phone, passport_number
4. **Booking** — booking_id (PK), check_in_date, check_out_date, total_amount, status
5. **Service** — service_id (PK), name, description, price (e.g., "Room Service", "Spa", "Airport Shuttle")

**Relationships:**

- Hotel (1) → Room (N): A hotel has many rooms. Each room belongs to exactly one hotel. (Identifying relationship — Room is weak.)
- Guest (1) → Booking (N): A guest can make many bookings. Each booking belongs to one guest.
- Booking (M) ↔ Room (N): A booking can include multiple rooms, and a room can appear in many bookings (over time). The junction records the specific dates.
- Booking (M) ↔ Service (N): A booking can use multiple services, and a service can be used by many bookings. The junction records the date used and quantity.

### Task

1. Write `CREATE TABLE` statements for ALL tables (including junction tables).
2. For each table:
   - Choose appropriate data types
   - Define PK, FK, NOT NULL, UNIQUE, CHECK, and DEFAULT constraints
   - Specify ON DELETE and ON UPDATE actions for all FKs
3. Create the tables in the correct dependency order.
4. Explain why Room is a weak entity and how its PK reflects this.

> [!NOTE]
> ***Your SQL***
>
> ```sql
> -- Write your CREATE TABLE statements here
>

-- Hotel Booking System

CREATE TABLE hotels (
    hotel_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    city        VARCHAR(50)  NOT NULL,
    star_rating SMALLINT     NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
    phone       VARCHAR(20)
);

CREATE TABLE guests (
    guest_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(254) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    passport_number VARCHAR(20)  UNIQUE
);

CREATE TABLE services (
    service_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description TEXT,
    price       NUMERIC(8,2)  NOT NULL CHECK (price >= 0)
);

-- Weak entity: owned by hotels
CREATE TABLE rooms (
    hotel_id        INTEGER       NOT NULL
                    REFERENCES hotels(hotel_id)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE,
    room_number     VARCHAR(10)   NOT NULL,
    room_type       VARCHAR(20)   NOT NULL
                    CHECK (room_type IN ('single', 'double', 'suite', 'family')),
    floor           SMALLINT      NOT NULL CHECK (floor >= 0),
    price_per_night NUMERIC(8,2)  NOT NULL CHECK (price_per_night > 0),
    has_balcony     BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY (hotel_id, room_number)
);

CREATE TABLE bookings (
    booking_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    guest_id       INTEGER        NOT NULL
                   REFERENCES guests(guest_id)
                   ON DELETE RESTRICT
                   ON UPDATE CASCADE,
    check_in_date  DATE           NOT NULL,
    check_out_date DATE           NOT NULL,
    total_amount   NUMERIC(10,2)  NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    status         VARCHAR(20)    NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'confirmed', 'checked_in', 'completed', 'cancelled')),
    CHECK (check_out_date > check_in_date)
);

-- Junction: Booking M:N Room
CREATE TABLE booking_rooms (
    booking_id  INTEGER      NOT NULL
                REFERENCES bookings(booking_id)
                ON DELETE CASCADE
                ON UPDATE CASCADE,
    hotel_id    INTEGER      NOT NULL,
    room_number VARCHAR(10)  NOT NULL,
    stay_from   DATE         NOT NULL,
    stay_to     DATE         NOT NULL,
    PRIMARY KEY (booking_id, hotel_id, room_number),
    FOREIGN KEY (hotel_id, room_number)
        REFERENCES rooms(hotel_id, room_number)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (stay_to > stay_from)
);

-- Junction: Booking M:N Service
CREATE TABLE booking_services (
    booking_id INTEGER  NOT NULL
               REFERENCES bookings(booking_id)
               ON DELETE CASCADE
               ON UPDATE CASCADE,
    service_id INTEGER  NOT NULL
               REFERENCES services(service_id)
               ON DELETE RESTRICT
               ON UPDATE CASCADE,
    date_used  DATE     NOT NULL,
    quantity   INTEGER  NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (booking_id, service_id, date_used)
);
>
> ```

> [!NOTE]
> ***Your Answer***
>
> *(Explain why Room is a weak entity and how its PK reflects this.)*
>
> Room is a weak entity because a room number on its own doesn't identify anything. Room 101 exists in almost every hotel, so `room_number` alone is not unique. A room only makes sense when you say which hotel it belongs to. Because of that, the primary key of `rooms` is a composite key of `(hotel_id, room_number)`. The `hotel_id` part is also a foreign key pointing to `hotels`, so the owner's key is built into the weak entity's key. I used `ON DELETE CASCADE` on it, because if a hotel is deleted, its rooms should go with it.
>
>

---

## Exercise 4: Data Type Selection

> [!NOTE]
> ***Your Answers***
> Fill in the **Your Data Type** and **Justification** columns in the table below.
>

For each column described below, choose the best PostgreSQL data type and write a brief justification (1–2 sentences). Do NOT just pick `VARCHAR` or `TEXT` for everything — think carefully about validation, storage, and query needs.

| # | Column Description | Your Data Type | Justification |
|---|---|---|---|
| 1 | Employee salary (exact, up to €999,999.99) | NUMERIC(8,2) | Exact decimal required for money; NUMERIC avoids floating-point rounding and 8,2 covers up to 999,999.99 |
| 2 | Number of items in stock (never negative, max ~50,000) | INTEGER | Whole number type; add CHECK (stock_quantity >= 0) to enforce non-negative values |
| 3 | Whether a user's email is verified | BOOLEAN | True/false value fits naturally in a BOOLEAN column |
| 4 | Customer's date of birth | DATE | Stores only the date (no time) which is appropriate for birthdays |
| 5 | Product description (variable length, could be several paragraphs) | TEXT | Variable-length, potentially large content — TEXT is appropriate and efficient for long descriptions |
| 6 | Country code (always exactly 2 letters, like "FI", "US") | CHAR(2) | Fixed-length two-character codes — CHAR(2) enforces exact length and is space-efficient |
| 7 | IP address of a login attempt | INET | PostgreSQL's INET type stores IPv4/IPv6 addresses and supports network functions |
| 8 | Order total (exact, up to €9,999,999.99) | NUMERIC(10,2) | Monetary value requiring exact precision; NUMERIC(10,2) covers up to 9,999,999.99 |
| 9 | GPS latitude of a store location | NUMERIC(9,6) | Decimal with sufficient precision for coordinates; six decimal places gives meter-level accuracy |
| 10 | A unique identifier for API tokens that must be globally unique across distributed systems | UUID | UUID is designed for globally unique identifiers and is standard for tokens/IDs in distributed systems |
| 11 | Duration of a video in seconds (always a whole number) | INTEGER | Integer seconds are sufficient and efficient |
| 12 | Timestamp of when a record was last modified (users in multiple time zones) | TIMESTAMPTZ | Timezone-aware timestamp is required when users operate in multiple time zones |
| 13 | A Finnish phone number like "+358 40 123 4567" | VARCHAR(20) | Phone numbers include symbols and spaces; VARCHAR allows flexible formatting while limiting length |
| 14 | A percentage discount (0.00% to 100.00%) | NUMERIC(5,2) | Exact decimal percentage; NUMERIC(5,2) supports values from 0.00 to 100.00 |
| 15 | A product's color options (e.g., a product comes in "red", "blue", "green") | VARCHAR(30) | Short textual values; better design is a separate colors table, but VARCHAR(30) is acceptable for a single field |

---

## Exercise 5: Constraint Design

For each business rule below, write the appropriate PostgreSQL constraint. Provide the constraint as it would appear inside a `CREATE TABLE` statement or as an `ALTER TABLE` statement.

### Part A: Single-Column Constraints

1. "A product's weight must be greater than zero (if provided)."

2. "Every customer must have an email address."

3. "Product names must be unique."

4. "An employee's hire date defaults to today if not specified."

5. "Order status can only be one of: 'new', 'confirmed', 'shipped', 'delivered', 'returned'."

> [!NOTE]
> ***Your SQL***
>
> ```sql
> -- Write constraints 1–5 here
> 1. weight NUMERIC(6,2) CHECK (weight IS NULL OR weight > 0)
> 2. email VARCHAR(254) NOT NULL
> 3. product_name VARCHAR(100) NOT NULL UNIQUE
> 4. hire_date DATE NOT NULL DEFAULT CURRENT_DATE
> 5. status VARCHAR(20) NOT NULL
    CHECK (status IN ('new', 'confirmed', 'shipped', 'delivered', 'returned'))
> ```

### Part B: Multi-Column Constraints

6. "A flight's arrival time must be after its departure time."

7. "In the `enrollments` table, the combination of `student_id` and `course_id` must be unique (a student can only enroll in a course once)."

8. "A discount percentage must be between 0 and 100, inclusive."

> [!NOTE]
> ***Your SQL***
>
> ```sql
> -- Write constraints 6–8 here
> 6. CHECK (arrival_time > departure_time)
> 7. UNIQUE (student_id, course_id)
> 8. CHECK (discount BETWEEN 0 AND 100)
>
> ```

### Part C: Foreign Key Constraints with Actions

9. "When a department is deleted, all employees in that department should have their `department_id` set to NULL (they become unassigned)."

10. "When a customer is deleted, prevent the deletion if the customer has any orders."

11. "When an author is deleted, all their blog posts should be deleted automatically."

12. "When a course is deleted, all enrollments for that course should be removed."

> [!NOTE]
> ***Your SQL***
>
> ```sql
> -- Write constraints 9–12 here
> 9.
 CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    department_id INTEGER,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
);
> 10.
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT
);
> 11.
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE blog_posts (
    post_id SERIAL PRIMARY KEY,
    author_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON DELETE CASCADE
);
> 12.
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);
>
> ```

---

## Submission Checklist

- [*] Exercise 1: `.sql` file with all CREATE TABLE statements + written justifications
- [*] Exercise 2: All 12 theory review answers
- [*] Exercise 3: Hotel booking schema with all tables and explanations
- [*] Exercise 4: Data type selections with justifications for all 15 columns
- [*] Exercise 5: All 12 constraints written in valid PostgreSQL syntax
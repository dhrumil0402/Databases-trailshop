# Week 36 — Exercises & Project Task

> [!IMPORTANT]
> ***How to Complete These Exercises***
> Write your answers directly in the highlighted **Your Answer** / **Your SQL** fields below each task. Replace the placeholder text with your own work before submitting.

These exercises accompany the Week 36 Theory material. Complete all sections.

---

## Part 1: TrailShop Project Task

### Task 1: Set Up PostgreSQL

Goal: install a working PostgreSQL server on your computer and confirm you can start `psql` (or an equivalent client).

---

### Local installation

**Step 1 — Download the installer**

1. Open [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/).
2. Click **Download the installer** (EDB installer is fine).
3. Choose a recent stable version (e.g. 16 or 17) for **Windows x86-64**.
4. Save the `.exe` file and run it.

_(macOS / Linux: start from [https://www.postgresql.org/download/](https://www.postgresql.org/download/) and follow the OS-specific guide.)_

**Step 2 — Run the setup wizard**

Work through the wizard. Suggested choices for this course:

1. **Installation directory** — leave the default.
2. **Select components** — keep at least **PostgreSQL Server**, **pgAdmin 4**, **Command Line Tools**, and **Stack Builder** (Stack Builder can be skipped later).
3. **Data directory** — leave the default.
4. **Password** — set a password for the superuser account `postgres`.
   **Write it down.** You will need it every time you connect.
5. **Port** — leave **5432** (default) unless that port is already in use.
6. **Locale** — leave the default.
7. Finish the install. You can decline launching Stack Builder if prompted.

**Step 3 — Confirm the service is running (Windows)**

1. Press `Win`, type **Services**, open **Services**.
2. Find a service named like `postgresql-x64-16` (version number may differ).
3. Status should be **Running**. If not, right-click → **Start**.

**Step 4 — Open a terminal where** `psql` **is available**

On Windows, the easiest reliable options are:

- **Option 4a:** Start Menu → **SQL Shell (psql)** (installed with PostgreSQL), **or**
- **Option 4b:** Open **PowerShell** or **Command Prompt**.

If `psql` is not found in PowerShell, either use **SQL Shell (psql)** or add the PostgreSQL `bin` folder to your PATH, for example:

```
C:\Program Files\PostgreSQL\16\bin
```

(Adjust `16` to match your installed version.)

**Step 5 — Verify the installation**

In PowerShell / Command Prompt, run:

```
psql --version
```

You should see something like `psql (PostgreSQL) 16.x`.

If you used **SQL Shell (psql)** instead, you can skip `--version` and go straight to connecting in Task 2 — successful connection also proves the install works.

**Step 6 — Capture evidence for submission**

Take a screenshot of `psql --version` output (or of a successful `psql` connection prompt).

---

### Task 2: Create the TrailShop Database

Goal: create an empty database named `trailshop` and confirm you are connected to it.

Complete these steps after Task 1 succeeds.

**Step 1 — Connect to the PostgreSQL server as** `postgres`

**If you use SQL Shell (psql) on Windows**, press Enter to accept defaults for Server, Database, Port, and Username (`postgres`), then type the password you set during install when prompted.

**If you use PowerShell / Command Prompt**, run:

```
psql -U postgres -h localhost -p 5432
```

Enter the `postgres` password when asked.

You should see a prompt similar to:

```
postgres=#
```

That means you are connected to the default `postgres` maintenance database — which is normal before creating `trailshop`.

**Step 2 — List existing databases (optional but useful)**

At the `postgres=#` prompt, run:

```
\l
```

Scan the list. If `trailshop` already exists from an earlier attempt, skip Step 3 and go to Step 4.

**Step 3 — Create the database**

Still at the `postgres=#` prompt, run exactly:

```sql
CREATE DATABASE trailshop;
```

Expected result:

```
CREATE DATABASE
```

If you see `ERROR: database "trailshop" already exists`, the database is already there — continue to Step 4.

**Step 4 — Connect to** `trailshop`

In `psql`, run:

```
\c trailshop
```

Expected result (wording may vary slightly):

```
You are now connected to database "trailshop" as user "postgres".
```

**Step 5 — Confirm the prompt and that the database is empty**

1. Check that your prompt shows `trailshop`, for example:

```
trailshop=#
```

1. List tables:

```
\dt
```

You should see **no tables** (or a message that no relations were found). That is expected in Week 36 — tables come later.

1. Confirm the current database name with SQL:

```sql
SELECT current_database();
```

Expected: one row with `trailshop`.

**Step 6 — Quit psql (when finished)**

```
\q
```

**Step 7 — Capture evidence for submission**

Take a screenshot showing:

- successful `\c trailshop` (or the `trailshop=#` prompt), **and**
- `\dt` with an empty result / “Did not find any relations”

---

### Troubleshooting (Tasks 1–2)

| Problem                                | What to try                                                                                                                  |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `psql` is not recognized               | Use **SQL Shell (psql)**, or add PostgreSQL’s `bin` folder to PATH and open a **new** terminal                               |
| Password authentication failed         | Use the password set for user `postgres` during install; check Caps Lock                                                     |
| Connection refused / could not connect | Confirm the PostgreSQL Windows service is **Running**; confirm port **5432**                                                 |
| Port already in use                    | Either stop the other service using 5432, or reinstall/reconfigure PostgreSQL to another port and always pass `-p` that port |
| Permission denied to create database   | Connect as `postgres` (superuser), not as a limited role                                                                     |

---

### Task 3: Reflection Worksheet

Answer the following in your own words (write 2–3 sentences per point):

1. List **3 specific problems** TrailShop would face if they kept using spreadsheets as their product catalog grows to 5,000+ items with 10 staff members.

> [!NOTE]
> ***Your Answer***
> 
>First, they would face data inconsistency; if staff update a product's price on the sales sheet but forget to update the inventory sheet, no one will know which price is correct. Second, there is a lack of concurrent access control, meaning if several employees try to edit the file at once, they will either get locked out or accidentally overwrite each other's work. Third, they would experience poor scalability and slow searching, because standard spreadsheets struggle to filter or query 5,000+ rows efficiently without freezing.

2. List **3 benefits** of switching to a database system, explaining how each one solves a problem from your list above.

> [!NOTE]
> ***Your Answer***
>
> First, a database provides a centralized source of truth, eliminating redundancy so that when a price is updated once, it is automatically correct everywhere. Second, databases have built-in concurrency control, allowing all 10 staff members to safely read and write data at the exact same time without corrupting the files. Finally, databases use indexes and a powerful query engine (SQL), which allows users to instantly search and filter millions of rows without the system slowing down.

3. Explain the three-schema architecture in your own words. Why is the separation into three levels useful?

> [!NOTE]
> ***Your Answer***
>
> The three-schema architecture divides a database into three levels: the internal level (how data is physically stored on the hard drive), the conceptual level (the logical map of all tables and relationships), and the external level (customized views for different users). This separation is useful because it provides data independence; for example, the database administrator can change the physical storage hardware without breaking the software applications that the staff use to view the data.

---

## Part 2: Theory Review Questions

Answer each question in 2–4 sentences. Reference the Theory material sections as needed.

### Short-Answer Questions

**Q1.** What is the difference between data and information? Give a concrete example using TrailShop data.
_(See Section 1 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> Data consists of raw, unorganized facts, whereas information is data that has been processed to have meaning and context. For example, a raw number like "150" in a table is just data, but processing it into a report that says "TrailShop sold 150 sleeping bags last month, resulting in a 20% profit increase" turns it into useful information.

**Q2.** List and explain three disadvantages of file-based data management systems. For each, describe how it would affect TrailShop specifically.
_(See Section 2 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> Data redundancy: TrailShop would have to save a customer's address in both the billing file and the shipping file, wasting space and risking mismatched data.

> Data isolation: It would be very difficult for TrailShop to generate a report combining data from the "Orders" file and the "Customers" file because they are stored separately.

> Program-data dependence: If TrailShop wanted to add a new "shoe size" field to their customer files, they would have to completely rewrite the software applications used to open and read those files.

**Q3.** What is a DBMS? List four of its core functions.
_(See Sections 3 and 4 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> A DBMS (Database Management System) is a software system that allows users to create, maintain, and control access to a database. Four of its core functions include storing and retrieving data, managing concurrent user access, providing a data dictionary (catalog), and ensuring transaction integrity and recovery in case of a crash.

**Q4.** Explain program-data independence with a concrete example. Why is it important?
_(See Section 5.2 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> Program-data independence means that the structure of the data can be modified without having to rewrite the application programs that use it. For example, if we change a TrailShop product code from a number format to a text format in the database, the website's front-end code doesn't necessarily need to be rewritten. This is important because it makes maintaining, updating, and scaling the system much cheaper and less prone to breaking.

**Q5.** What is metadata? Give two examples of metadata for a `products` table.
_(See Section 8 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> Metadata is "data about data"; it describes the structure, constraints, and format of the data stored in the database. Two examples of metadata for a products table would be the data type for the price column (e.g., indicating it must be a decimal number) and a constraint stating that the product_id cannot be left blank (NOT NULL).

**Q6.** What is the three-schema architecture? Name and briefly describe each level.
_(See Section 3.3 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> It is a framework used to separate the user applications from the physical database. It consists of the Internal level (describing physical storage and access paths), the Conceptual level (describing the logical structure, entities, and relationships of the whole database), and the External level (describing the specific views that different user groups are allowed to see).

**Q7.** Explain the difference between logical data independence and physical data independence.
_(See Section 3.4 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> Logical data independence is the ability to change the conceptual schema (like adding new tables or columns) without having to change the external user views or applications. Physical data independence is the ability to change the internal schema (like upgrading hard drives or adding an index) without affecting the conceptual schema or the applications.

**Q8.** What is a transaction? Why is atomicity important? Give a TrailShop example.
_(See Section 5.5 of this week's Theory material.)_

> [!NOTE]
> ***Your Answer***
>
> A transaction is a logical unit of work that consists of one or more database operations. Atomicity ensures that the entire transaction must either complete fully or fail completely, with no middle ground. For example, if a TrailShop customer buys a tent, deducting the money from their account and removing the tent from the inventory must happen together; if the system crashes halfway through, atomicity ensures the money is returned so the database remains accurate.

### True/False

For each statement, write **True** or **False** and correct any false statements.

1. A DBMS stores only data, not information about the data's structure.
2. In a file-based system, changing the format of a data file requires updating every program that reads it.
3. Data redundancy means the same data is stored in multiple places.
4. PostgreSQL is a commercial, closed-source database system.
5. The conceptual level of the three-schema architecture describes how data is physically stored on disk.

> [!NOTE]
> ***Your Answer***
>
> 1. False. A DBMS stores both the data and the metadata (the data dictionary/system catalog).
> 2. True.
> 3. True.
> 4. False. PostgreSQL is a free, open-source relational database system, not a commercial/closed-source one.
> 5. False. The conceptual level describes the logical structure of the entire database. The internal level describes how data is physically stored on disk.

### Matching Exercise

Match each term (1–10) with its definition (A–J).

| #   | Term              |
| --- | ----------------- |
| 1   | Data dictionary   |
| 2   | RDBMS             |
| 3   | Concurrency       |
| 4   | View              |
| 5   | Schema            |
| 6   | Data isolation    |
| 7   | Transaction       |
| 8   | SQL               |
| 9   | Data independence |
| 10  | ACID              |

| Letter | Definition                                                                          |
| ------ | ----------------------------------------------------------------------------------- |
| A      | A virtual table defined by a query, showing a subset of data                        |
| B      | Multiple users accessing data at the same time                                      |
| C      | The formal definition of a database's structure (tables, columns, types)            |
| D      | A logical unit of work that must complete fully or not at all                       |
| E      | The standard language for querying and managing relational databases                |
| F      | The system catalog storing metadata about the database                              |
| G      | Data trapped in separate files/formats that are hard to combine                     |
| H      | A DBMS based on the relational model, using tables and SQL                          |
| I      | The ability to change storage or structure without affecting applications           |
| J      | Atomicity, Consistency, Isolation, Durability — properties of reliable transactions |

> [!NOTE]
> ***Your Answers***
>
> | #   | Your Match |
> | --- | ---------- |
> | 1   |       F     |
> | 2   |       H     |
> | 3   |       B     |
> | 4   |       A     |
> | 5   |       C     |
> | 6   |       G     |
> | 7   |       D     |
> | 8   |       E     |
> | 9   |       I     |
> | 10  |       J     |

---

## Part 3: Practical Exercises

These exercises require a working PostgreSQL installation. See Part 1, Task 1 if you haven't set it up yet.

### Exercise 3.1: Explore psql

Connect to PostgreSQL using psql and complete the following. Write down the command you used and the output (or a summary of it).

1. List all databases on your server.
2. Connect to the `trailshop` database.
3. List all tables in the `trailshop` database.
4. Use `\?` to display the list of psql meta-commands. Find and write down the commands for:

- Describing a specific table's structure
- Listing all users/roles
- Showing help for a specific SQL command

5. Quit psql.

> [!NOTE]
> ***Your Answer***
>
> 1. List all databases: \l
> 2. Connect to trailshop: \c trailshop (Output: You are now connected to database "trailshop" as user "postgres".).
> 3. List all tables: \dt (Output: Did not find any tables. since the database was just created).
> 4. Meta-commands found via \?:
>    Describing a specific table's structure: \d [table_name]
>    Listing all users/roles: \du
>    Showing help for a specific SQL command: \h [command]
> 5. Quit psql: \q

### Exercise 3.2: Explore the System Catalog

While connected to `trailshop`, run the following queries and write down what they return:

```sql
SELECT current_database();
```

```sql
SELECT version();
```

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

Why does the last query return no rows? What would you expect to see after creating tables in future weeks?

> [!NOTE]
> ***Your Answer***
>
> SELECT current_database(); returned:

   current_database
  ------------------
   trailshop
  (1 row)
SELECT version(); returned: PostgreSQL 18.6 (along with the specific system architecture details).

SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'; returned: (0 rows).

Why it returns no rows: The query returns empty because the trailshop database was only just created. We have not yet defined or created any actual tables in the public schema. In future weeks, once the CREATE TABLE command is executed, this query will output a list containing the names of those new tables.


### Exercise 3.3: Create and Drop a Test Database

Practice database creation and deletion:

```sql
-- Create a test database
CREATE DATABASE test_playground;

-- List databases to confirm it exists
\l

-- Drop (delete) the test database
DROP DATABASE test_playground;

-- List databases again to confirm it's gone
\l
```

**Warning:** `DROP DATABASE` permanently deletes a database and all its data. Always double-check the database name before running this command.

---

## Submission Checklist

- [*] PostgreSQL installed and working (screenshot of `psql --version` or equivalent)
- [*] `trailshop` database created (screenshot of `\c trailshop` showing successful connection)
- [*] Reflection Worksheet answers (Part 1, Task 3)
- [*] Theory Review Questions answered (Part 2)
- [*] Practical Exercise outputs documented (Part 3)

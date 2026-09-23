## Exercise 1: TrailShop Project Task — Create the ER Diagram

 **ASCII reference for building the diagram (crow's foot notation):**

 ```
 Category ──||──────O<── Product
 Customer ──||──────O<── Order
 Order    ──||──────|<── OrderItem
 Product  ──||──────O<── OrderItem
 ```
dbdiagram link: https://dbdiagram.io/d/Trailshop-6ab3d43b5869425612722b90

 Entities: Category, Product, Customer, Order, OrderItem (weak entity).

 Attributes:
 - Category: category_id (PK), category_name, description
 - Product: product_id (PK), name, description, price, weight_kg, stock_quantity, created_at, category_id (FK)
 - Customer: customer_id (PK), first_name, last_name, email, phone, street, city, postal_code, country, registered_at
 - Order: order_id (PK), order_date, status, shipping_address
 - OrderItem: order_id (PK, FK), product_id (PK, FK), quantity, unit_price

 OrderItem is marked as a weak entity, shown with a double-bordered box, since it can't be identified without its owner (Order).

 > [!NOTE]
 > ***Your Answer***
 >
 > I marked OrderItem as a weak entity because a line item has no meaning on its own. Its identity only exists in relation to a specific order — "quantity 2" or "line 1" means nothing without knowing which order it belongs to. That's why its primary key is composite: `(order_id, product_id)`, combining the owner's key with a partial key. I also chose to store `unit_price` directly on OrderItem instead of looking it up from Product, because product prices change over time and an order needs to preserve the price the customer actually paid at the moment of purchase. If I only referenced the current product price, historical orders would silently show the wrong totals every time a price changed.

 ---

 ## Exercise 2: Theory Review Questions

 1. **Why should you create a conceptual data model before writing SQL?**
 > [!NOTE]
 > ***Your Answer***
 >
 > First, it lets you validate the understanding of the business with non-technical stakeholders before committing to any implementation — the founders can look at an ER diagram and say "yes, one customer can have many orders" without knowing any SQL. Second, it separates design mistakes from implementation mistakes: if you jump straight to CREATE TABLE statements, you conflate "did I understand the business correctly" with "did I write correct SQL," and fixing a wrong table structure after data has been loaded is far more expensive than fixing a diagram.

 2. **Difference between the conceptual level and the logical level?**
 > [!NOTE]
 > ***Your Answer***
 >
 > The conceptual level is a technology-independent model of the business — entities, attributes, and relationships, with no mention of tables, data types, or a specific DBMS. The logical level translates that conceptual model into the structures of a particular type of database (for us, relational): tables, columns, primary keys, and foreign keys. The conceptual level answers "what does the business need to track," and the logical level answers "how do we represent that as relational tables."

 3. **Explain logical data independence with an example.**
 > [!NOTE]
 > ***Your Answer***
 >
 > Logical data independence means you can change the conceptual schema without breaking the external views/applications built on top of it. For example, if TrailShop splits the `products` table into `products` and `product_details`, the warehouse team's existing view can be redefined to join the two tables internally, and the warehouse application keeps working exactly as before without any code changes.

 4. **Explain physical data independence with an example.**
 > [!NOTE]
 > ***Your Answer***
 >
 > Physical data independence means you can change how data is physically stored without affecting the logical structure or the applications querying it. For example, adding an index on `products.name`, or moving the database to a faster disk, speeds up queries but doesn't require changing a single SQL query or application.

 5. **Strong vs weak entity, one example of each (not TrailShop).**
 > [!NOTE]
 > ***Your Answer***
 >
 > A strong entity can be uniquely identified by its own attributes and doesn't depend on another entity to exist — for example, an Employee, identified by employee_id. A weak entity can't be identified on its own and depends on an owner entity — for example, a Dependent on an insurance policy, identified only through the Employee they're attached to (employee_id + dependent_name), since "Dependent #1" means nothing without knowing whose dependent it is.

 6. **Composite vs multivalued attribute, example of each.**
 > [!NOTE]
 > ***Your Answer***
 >
 > A composite attribute can be broken down into smaller meaningful sub-parts, like `address` splitting into street, city, postal_code, and country. A multivalued attribute can hold more than one value for a single entity instance, like a customer having several phone numbers (home, work, mobile). Composite attributes get flattened into separate columns on the same table; multivalued attributes get moved into their own table with a foreign key back to the owner.

 7. **What is a derived attribute? Why isn't it usually stored?**
 > [!NOTE]
 > ***Your Answer***
 >
 > A derived attribute is a value that can be calculated from other attributes already in the database, like `age` from `date_of_birth`, or an order's total from summing its line items. It's usually not stored because storing it creates redundancy — if the source data changes, the derived value can become stale or inconsistent unless you remember to update it everywhere. It's safer to compute it in a query when needed.

> 8. **Binary vs unary (recursive) relationship, example of each.**
 > [!NOTE]
 > ***Your Answer***
 >
 > A binary relationship connects two different entity types, like Customer places Order. A unary (recursive) relationship connects an entity type to itself, like Employee manages Employee, where a manager is also an employee.

 9. **Identifying vs non-identifying relationship, effect on child PK.**
 > [!NOTE]
 > ***Your Answer***
 >
 > In an identifying relationship, the child entity is weak and the parent's primary key becomes part of the child's own primary key — for example, `order_items.order_id` is both a foreign key and part of the composite primary key. In a non-identifying relationship, the child is a strong entity with its own independent primary key, and the foreign key is just a regular column — for example, `products.category_id` is a foreign key but not part of the product's primary key.

 10. **Circle followed by a crow's foot (fork) — what does it mean?**
 > [!NOTE]
 > ***Your Answer***
 >
 > It means "zero or many" — optional participation (minimum 0) combined with a maximum of many. An entity on this end can be related to zero, one, or multiple instances of the other entity.

 11. **Why can't M:N be implemented directly? What's the solution?**
 > [!NOTE]
 > ***Your Answer***
 >
 > A foreign key column can only hold one value, so it can't represent "this row relates to many rows on the other side." You can't put a single order_id in the products table (a product appears in many orders) or a single product_id in the orders table (an order contains many products). The solution is a junction table (associative entity) that sits between the two tables and holds a foreign key to each, turning one M:N relationship into two 1:N relationships.

 12. **Min-max notation: every employee belongs to exactly one department, every department has at least one employee.**
 > [!NOTE]
 > ***Your Answer***
 >
 > Employee (1,1) ──── belongs to ──── (1,N) Department
 >
 > Employee participates 1 to 1 times (every employee has exactly one department, mandatory). Department participates 1 to N times (every department has at least one employee, and can have many).

 ---

 ## Exercise 3: ER Diagram Reading Exercise

 ### Diagram A: Library System

 a) **Can an author exist without having written any books?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Yes. The end of the relationship nearest Book is `O<` (zero or many), meaning an author can be linked to zero books. So the diagram allows an author record to exist with no books attached — useful for tracking an author before their first title is catalogued.

 b) **Can a book exist without being loaned?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Yes. The end nearest Loan is `O<` (zero or many), so a book can have zero loans. A brand-new book that's never been checked out can still exist in the system.

 c) **What type of entity is Loan? Is it a junction/associative entity?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Loan is a junction (associative) entity. It sits between Book and Member, connected to each through its own relationship, and its purpose is to record a specific association between one book and one member at a point in time — effectively resolving the underlying many-to-many relationship (a book can be loaned to many members over time, a member can borrow many books) while also carrying its own attributes, like dates.

 d) **Cardinality of Author-Book — is it realistic?**
 > [!NOTE]
 > ***Your Answer***
 >
 > As drawn, it's 1:N — one author can write many books, but each book has exactly one author (the end nearest Author is `||`, exactly one). That's not realistic, since many books have multiple co-authors. A more accurate model would make Author-Book a true M:N relationship, resolved with a junction table like BookAuthors (book_id, author_id), which would also let you record things like author order or contribution type.

 e) **What attributes would you add to the Loan entity?**
 > [!NOTE]
 > ***Your Answer***
 >
 > loan_date, due_date, and return_date (nullable, since a loan may not yet be returned). Optionally also a renewal_count or a fine_amount if the library charges late fees.

 ### Diagram B: School System

 a) **Can a student exist without being enrolled in any course?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Yes. The relationship is explicitly described as "a student may have zero or many enrollments," so a student record can exist before they enroll in anything, or even if they never enroll.

 b) **Can a course exist without having any enrolled students?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Based on the crow's foot shown on the Enrollment side of the Enrollment-Course link (one-or-many, mandatory), this diagram actually requires a course to have at least one enrollment to exist — which is arguably a modelling flaw, since in practice you'd want to create a course before anyone enrolls. A more realistic design would make Course's participation optional (zero or many enrollments) rather than mandatory.

 c) **Cardinality between Student and Course (through Enrollment)?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Many-to-many. A student can enroll in many courses, and a course can have many students, with Enrollment acting as the junction entity that resolves this M:N relationship and records extra detail per enrollment.

 d) **Can a teacher exist without teaching any courses?**
 > [!NOTE]
 > ***Your Answer***
 >
 > Yes. The end nearest Course is `O<` (zero or many), meaning a teacher can be linked to zero courses — so a newly hired teacher who hasn't been assigned a course yet can still exist in the system.

 e) **Is Teacher-Course 1:1 or 1:N? What does this imply about team teaching?**
 > [!NOTE]
 > ***Your Answer***
 >
 > It's 1:N — one teacher can teach many courses, but each course has exactly one teacher (the end nearest Teacher is `||`, exactly one). This means team teaching isn't supported: the model has no way to assign two teachers to the same course. Supporting that would require turning Teacher-Course into an M:N relationship via a junction table, like CourseTeachers.

 ---

 ## Exercise 4: ER Diagram Creation — Gym/Fitness Center

 ### 1. Entities and attributes

 > [!NOTE]
 > ***Your Answer***
 >
 > **Member**: member_id (PK), first_name, last_name, email, phone, date_of_birth, membership_start_date, plan_id (FK)
 >
 > **MembershipPlan**: plan_id (PK), plan_name, monthly_price, description
 >
 > **Trainer**: trainer_id (PK), first_name, last_name, specialization, hire_date
 >
 > **Class**: class_id (PK), class_name, day_of_week, start_time, end_time, max_capacity, trainer_id (FK)
 >
 > **Registration** (junction entity): member_id (PK, FK), class_id (PK, FK), registration_date
 >
 > **Equipment**: equipment_id (PK), name, type, purchase_date, status
 >
 > **MaintenanceRequest**: request_id (PK), equipment_id (FK), request_date, description, status, resolution_date

 ### 2. Relationships, cardinality, and participation

 > [!NOTE]
 > ***Your Answer***
 >
 > - MembershipPlan (1) — Member (N): every member subscribes to exactly one plan (mandatory on Member's side); a plan can have zero or many members (optional on Plan's side, in case a new plan hasn't been picked up yet).
 > - Trainer (1) — Class (N): every class is led by exactly one trainer (mandatory); a trainer can lead zero or many classes (optional, in case a trainer hasn't been assigned a class yet).
 > - Member (M) — Class (N), resolved via Registration: a member can register for many classes and a class can have many registered members, both sides optional (zero or many) since neither requires the other to exist.
 > - Equipment (1) — MaintenanceRequest (N): every maintenance request is for exactly one piece of equipment (mandatory); a piece of equipment can have zero or many maintenance requests over time (optional).

 ### 3. ER diagram

 > [!NOTE]
 > ***(Add a link to your image here)*
 >Diagram built in dbdiagram.io: https://dbdiagram.io/d/FitZone-Gym-6ab109b1bd4073ff512a41dc


 > Build this in draw.io/dbdiagram.io using the entities and relationships listed above. Cardinality notation to use:
 > MembershipPlan ──||──────O<── Member
 > Trainer ──||──────O<── Class
 > Member ──O<──────O<── Registration ──>O──||── Class *(M:N via Registration)*
 > Equipment ──||──────O<── MaintenanceRequest

 ### 4. Weak or junction/associative entities

 > [!NOTE]
 > ***Your Answer***
 >
 > Registration is a junction (associative) entity — it resolves the M:N relationship between Member and Class and carries its own attribute (registration_date). Its primary key is the composite of member_id and class_id, so in that sense it also behaves like a weak entity: a registration has no independent identity outside the specific member-class pairing it represents. MaintenanceRequest is a dependent entity (it needs equipment_id to make sense) but not weak, since it has its own surrogate key (request_id) and doesn't need to borrow part of Equipment's key.

 ### 5. Any M:N relationships?

 > [!NOTE]
 > ***Your Answer***
 >
 > Yes — Member and Class have a many-to-many relationship (a member can register for many classes, a class can have many registered members), resolved by the Registration junction table.

 ---

 ## Exercise 5: Find and Correct the Errors

 **Error 1 — Multivalued attribute**
 > [!NOTE]
 > ***Your Answer***
 >
 > a) The `genres` column in Books stores a comma-separated string ("Fiction, Mystery, Thriller") instead of a single atomic value.
 >
 > b) This violates First Normal Form (Theory Section 6.4 on multivalued attributes / Week 45's 1NF rule). A cell should hold one indivisible value; a comma-separated list makes it impossible to filter, join, or index by individual genre without string parsing.
 >
 > c) Fix: create a separate Genre entity (genre_id, genre_name) and a junction table BookGenres (book_id, genre_id), since a book can have multiple genres and a genre applies to many books — a genuine M:N relationship.

 **Error 2 — M:N implemented directly**
 > [!NOTE]
 > ***Your Answer***
 >
 > a) The relationship "Books to Customer: M:N (implemented directly — no junction table)" is stated as implemented without a junction table.
 >
 > b) This is a modelling error (Theory Section 10.1–10.2). A many-to-many relationship cannot be represented with a simple foreign key on either side — you'd need to store multiple values in one column, which isn't possible relationally.
 >
 > c) Fix: don't link Books to Customer directly at all — route the relationship through Purchase instead (see Error 4), giving Customer –1:N– Purchase –M:N– Books via a proper junction table.

 **Error 3 — Entity naming convention**
 > [!NOTE]
 > ***Your Answer***
 >
 > a) "Books" is named as a plural noun while "Customer" and "Purchase" are singular — the naming convention is inconsistent across entities.
 >
 > b) This is a problem (Theory Section 11.1) because ER entity names should be consistent, typically singular nouns representing one instance of the thing (Book, not Books), so the model reads predictably and translates cleanly into naming conventions at the logical/implementation stage.
 >
 > c) Fix: rename "Books" to "Book" so all three entities follow the same singular naming pattern.

 **Error 4 — Missing relationship**
 > [!NOTE]
 > ***Your Answer***
 >
 > a) "Books to Purchase: no relationship defined," even though a purchase inherently involves buying specific book(s).
 >
 > b) This is a critical gap — without linking Purchase to Book, there's no way to know what was actually bought in a given purchase, which defeats the purpose of the Purchase entity.
> >
> > c) Fix: add a junction entity, e.g., PurchaseItems (purchase_id FK, book_id FK, quantity, unit_price), forming the M:N between Purchase and Book. This also naturally replaces the incorrect direct Book–Customer relationship from Error 2, since customers now connect to books indirectly through their purchases.

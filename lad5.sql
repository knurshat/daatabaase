-- Student: Nurshat Kazimov
-- Student ID: 24B031825


-- Task 1.1: employees
CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65), -- возраст должен быть 18..65
    salary NUMERIC CHECK (salary > 0)           -- зарплата > 0
);

-- Task 1.2: products_catalog
CREATE TABLE IF NOT EXISTS products_catalog (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3: bookings
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4: correct and incorrect Insert

--for table 1.1
--successfully insert
INSERT INTO employees(employee_id, first_name, last_name, age, salary) VALUES
(1, 'Aibek', 'Suleimen', 25, 500.00),
(2, 'Madina', 'Tulegen', 34, 1200.50);

-- incorrect insert
-- 1) age < 18
INSERT INTO employees(employee_id, first_name, last_name, age, salary) VALUES (3, 'Test', 'Young', 16, 300.00);
-- EXPECTED: CHECK violation on age BETWEEN 18 AND 65
-- 2) salary <= 0
INSERT INTO employees(employee_id, first_name, last_name, age, salary) VALUES (4, 'Test', 'Zero', 30, 0);
-- EXPECTED: CHECK violation salary > 0

--for table 1.2
--successfully insert
INSERT INTO products_catalog(product_id, product_name, regular_price, discount_price) VALUES
(101, 'Coffee Beans 1kg', 20.00, 15.00),
(102, 'Wireless Mouse', 25.00, 20.00);

--incorrect insert
--1)regular_price <= 0
INSERT INTO products_catalog(product_id, product_name, regular_price, discount_price) VALUES (103, 'Bad', 0, 0);
-- EXPECTED: valid_discount violated (regular_price > 0)

--2) discount_price >= regular_price
INSERT INTO products_catalog(product_id, product_name, regular_price, discount_price) VALUES (104, 'NoSale', 10.00, 12.00);
-- EXPECTED: valid_discount violated (discount_price < regular_price)


--for table 1.3
--successfully insert
INSERT INTO bookings(booking_id, check_in_date, check_out_date, num_guests) VALUES
(201, '2025-11-01', '2025-11-05', 2),
(202, '2025-12-20', '2025-12-25', 4);

--incorrect insert
-- 1) num_guests = 0
INSERT INTO bookings(booking_id, check_in_date, check_out_date, num_guests) VALUES (203, '2025-11-10', '2025-11-12', 0);
-- EXPECTED: CHECK violation num_guests BETWEEN 1 AND 10

-- 2) check_out_date <= check_in_date
INSERT INTO bookings(booking_id, check_in_date, check_out_date, num_guests) VALUES (204, '2025-11-10', '2025-11-09', 2);
-- EXPECTED: CHECK violation check_out_date > check_in_date


-- Task 2.1: customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER NOT NULL PRIMARY KEY,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
--successfully insert
INSERT INTO customers(customer_id, email, phone, registration_date) VALUES
(301, 'n.kazimov@example.com', '+77001234567', '2025-01-15'),
(302, 'a.akhmetova@example.com', NULL, '2025-02-10');

-- error (NULL в NOT NULL):
INSERT INTO customers(customer_id, email, phone, registration_date) VALUES (303, NULL, '+77001112233', '2025-03-01');
-- EXPECTED: NOT NULL violation on email

-- Task 2.2: inventory
CREATE TABLE IF NOT EXISTS inventory (
    item_id INTEGER NOT NULL PRIMARY KEY,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

--successfully insert
INSERT INTO inventory(item_id, item_name, quantity, unit_price, last_updated) VALUES
(401, 'Notebook 100 pages', 50, 1.50, '2025-09-01 10:00:00'),
(402, 'Pen Blue', 200, 0.50, '2025-09-02 09:30:00');

--error
-- 1) quantity < 0
INSERT INTO inventory(item_id, item_name, quantity, unit_price, last_updated) VALUES (403, 'BadItem', -5, 2.00, now());
-- EXPECTED: CHECK violation quantity >= 0

-- 2) unit_price <= 0
INSERT INTO inventory(item_id, item_name, quantity, unit_price, last_updated) VALUES (404, 'Freebie', 10, 0, now());
-- EXPECTED: CHECK violation unit_price > 0

-- 3) NULL в NOT NULL столбце
INSERT INTO inventory(item_id, item_name, quantity, unit_price, last_updated) VALUES (405, NULL, 5, 2.00, now());
-- EXPECTED: NOT NULL violation on item_name


-- Task 3.1: users (username и email уникальны)
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP
);

--successfully insert
INSERT INTO users(user_id, username, email, created_at) VALUES
(501, 'nurshat', 'n.k@example.com', now()),
(502, 'aidana', 'a.t@example.com', now());

-- Task 3.2: course_enrollments
CREATE TABLE IF NOT EXISTS course_enrollments (
    enrollment_id INTEGER PRIMARY KEY,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment UNIQUE(student_id, course_code, semester)
);

--successfully insert
INSERT INTO course_enrollments(enrollment_id, student_id, course_code, semester) VALUES
(601, 1001, 'CS101', '2025-Fall'),
(602, 1002, 'CS101', '2025-Fall');

-- Нарушение дубликата комбинации
-- INSERT INTO course_enrollments(enrollment_id, student_id, course_code, semester) VALUES (603, 1001, 'CS101', '2025-Fall');
-- EXPECTED: UNIQUE violation on (student_id, course_code, semester)

-- Task 3.3: именованные UNIQUE constraints для users
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE(username),
    ADD CONSTRAINT unique_email UNIQUE(email);

-- testing duplicate
INSERT INTO users(user_id, username, email, created_at) VALUES (503, 'Aziza', 'other@gmail.com', now());
-- EXPECTED: unique_username violated
INSERT INTO users(user_id, username, email, created_at) VALUES (504, 'Union', 'n.k@kaka.com', now());
-- EXPECTED: unique_email violated

-- Task 4.1: departments (single-column PK)
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments(dept_id, dept_name, location) VALUES
(701, 'Sales', 'Almaty'),
(702, 'R&D', 'Nur-Sultan'),
(703, 'HR', 'Almaty');

-- Errors:
-- 1) duplicate dept_id
INSERT INTO departments(dept_id, dept_name, location) VALUES (701, 'Marketing', 'Almaty');
-- EXPECTED: PRIMARY KEY violation (duplicate dept_id)

-- 2) NULL в PK
INSERT INTO departments(dept_id, dept_name, location) VALUES (NULL, 'Temp', 'City');
-- EXPECTED: NOT NULL violation на dept_id (PK не может быть NULL)


-- Task 4.2: student_courses (composite PK)
CREATE TABLE IF NOT EXISTS student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses(student_id, course_id, enrollment_date, grade) VALUES
(1001, 2001, '2025-09-01', 'A'),
(1002, 2002, '2025-09-02', 'B');

-- Task 4.3: Comparison (description left in the comments below)
-- 1) PRIMARY KEY guarantees uniqueness and NOT NULL, serving as a row identifier.
-- 2) UNIQUE enforces uniqueness but allows NULL (in PostgreSQL, you can have multiple NULLs in a UNIQUE).
-- 3) Use a composite PK when the identity of an entity is determined by a combination of fields.
-- 4) A table can have only one PRIMARY KEY (logical constraint), but can have multiple UNIQUEs.


-- Task 5.1: employees_dept
CREATE TABLE IF NOT EXISTS employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

-- Insert
INSERT INTO employees_dept(emp_id, emp_name, dept_id, hire_date) VALUES
(801, 'Dias', 701, '2024-06-10'),
(802, 'Saule', 702, '2023-04-20');

-- Error: non-existent dept_id
INSERT INTO employees_dept(emp_id, emp_name, dept_id, hire_date) VALUES (803, 'Bad', 999, '2025-01-01');
-- EXPECTED: FOREIGN KEY violation (referential integrity)


-- Task 5.2: Library schema (authors, publishers, books)
CREATE TABLE IF NOT EXISTS authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE IF NOT EXISTS publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE IF NOT EXISTS books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

-- Inserts
INSERT INTO authors(author_id, author_name, country) VALUES
(901, 'Orhan Pamuk', 'Turkey'),
(902, 'Chingiz Aitmatov', 'Kyrgyzstan');

INSERT INTO publishers(publisher_id, publisher_name, city) VALUES
(1001, 'Penguin Random House', 'London'),
(1002, 'Almaty Books', 'Almaty');

INSERT INTO books(book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
(1101, 'My Name Is Red', 901, 1001, 1998, '978-0143112312'),
(1102, 'Jamila', 902, 1002, 1958, '978-9967000001');


-- Task 5.3: ON DELETE behaviors
CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Insert for test
INSERT INTO categories(category_id, category_name) VALUES
(1201, 'Electronics');

INSERT INTO products_fk(product_id, product_name, category_id) VALUES
(1301, 'Bluetooth Speaker', 1201);

INSERT INTO orders(order_id, order_date) VALUES
(1401, '2025-10-01');

INSERT INTO order_items(item_id, order_id, product_id, quantity) VALUES
(1501, 1401, 1301, 2);

-- tests:
-- 1) Trying to delete a category with products -> RESTRICT should prevent deletion
DELETE FROM categories WHERE category_id = 1201;
-- EXPECTED: ERROR (RESTRICT)
-- 2) Deleting an order -> CASCADE will delete the associated order_items
DELETE FROM orders WHERE order_id = 1401;
-- EXPECTED: order_items с order_id = 1401 deleted

CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

-- Таблица orders
CREATE TABLE IF NOT EXISTS orders_ecom(
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE SET NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

-- Таблица order_details
CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

-- Вставки: по 5 записей в таблицы (customers уже содержит 2 записи выше, добавим ещё)
INSERT INTO customers(customer_id, email, phone, registration_date) VALUES
(303, 'b.imenov@example.com', '+77007778899', '2025-03-05'),
(304, 'o.kanat@example.com', '+77009998877', '2025-04-12'),
(305, 's.erkebayev@example.com', NULL, '2025-05-20');

INSERT INTO products(product_id, name, description, price, stock_quantity) VALUES
(2001, 'Wireless Headphones', 'Over-ear, noise cancelling', 80.00, 25),
(2002, 'USB-C Charger', '65W fast charger', 30.00, 100),
(2003, 'Mechanical Keyboard', 'Blue switches', 120.00, 10),
(2004, 'Laptop Stand', 'Aluminum foldable', 25.00, 50),
(2005, 'Webcam 1080p', 'Built-in microphone', 45.00, 15);

INSERT INTO orders_ecom(order_id, customer_id, order_date, total_amount, status) VALUES
(3001, 301, '2025-09-10', 110.00, 'processing'),
(3002, 302, '2025-09-11', 30.00, 'shipped'),
(3003, 303, '2025-09-12', 200.00, 'pending'),
(3004, 304, '2025-09-13', 25.00, 'delivered'),
(3005, 305, '2025-09-14', 45.00, 'cancelled');

INSERT INTO order_details(order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(4001, 3001, 2001, 1, 80.00),
(4002, 3001, 2002, 1, 30.00),
(4003, 3003, 2003, 1, 120.00),
(4004, 3004, 2004, 1, 25.00),
(4005, 3005, 2005, 1, 45.00);

-- E-commerce Constraint Tests
-- 1) Attempt to insert an order with a status not in the list
INSERT INTO orders_ecom(order_id, customer_id, order_date, total_amount, status) VALUES (3010, 301, '2025-10-01', 50.00, 'awaiting');
-- EXPECTED: CHECK violation status IN (...)

-- 2) Attempt to insert a negative price into products
INSERT INTO products(product_id, name, description, price, stock_quantity) VALUES (2006, 'BadProduct', 'bad', -1.00, 5);
-- EXPECTED: CHECK violation price >= 0

-- 3) Attempt to insert order_details with quantity = 0
INSERT INTO order_details(order_detail_id, order_id, product_id, quantity, unit_price) VALUES (4006, 3001, 2002, 0, 30.00);
-- EXPECTED: CHECK violation quantity > 0

-- 4) Attempt to insert duplicate email in customers (UNIQUE requirement for e-commerce)
-- (Add email uniqueness for the e-commerce portion)
ALTER TABLE customers ADD CONSTRAINT unique_customer_email UNIQUE(email);
INSERT INTO customers(customer_id, email, phone, registration_date) VALUES (306, 'n.kazimov@example.com', '+77000000000', '2025-10-01');
-- EXPECTED: UNIQUE violation (if email already exists)










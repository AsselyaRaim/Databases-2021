/*
 1. DDL defines data structures, specifies information about relations (the schemas of relations, integrity constraints, etc.)
 DML manipulates the data inside of relation.
 a) DDL commands: CREATE, ALTER, DROP
 b) DML commands: UPDATE, INSERT, DELETE, SELECT
 */

 -- #2
CREATE DATABASE lab_2_database;

CREATE TABLE customers (
    id integer PRIMARY KEY,
    full_name varchar(50) NOT NULL,
    timestamp timestamp NOT NULL,
    delivery_address text NOT NULL
);

CREATE TABLE products (
    id varchar PRIMARY KEY,
    name varchar UNIQUE NOT NULL,
    description text,
    price double precision NOT NULL CHECK (price > 0)
);

CREATE TABLE orders (
    code integer PRIMARY KEY,
    customer_id integer REFERENCES customers (id),
    total_sum double precision NOT NULL CHECK (total_sum > 0),
    is_paid boolean NOT NULL
);

CREATE TABLE order_items (
    order_code integer REFERENCES orders (code),
    product_id varchar REFERENCES products (id),
    quantity integer NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_code, product_id)
);


-- #3
CREATE TABLE students (
    full_name text PRIMARY KEY,
    age integer NOT NULL,
    birth_date date NOT NULL,
    gender char(1) NOT NULL,
    average_grade numeric(3, 2) NOT NULL,
    personal_info text,
    need_dormitory boolean NOT NULL,
    additional_info text
);


CREATE TABLE instructors (
    full_name text PRIMARY KEY,
    work_experience double precision NOT NULL,
    can_work_remotely boolean NOT NULL
);

CREATE TABLE languages (
    full_name text REFERENCES instructors (full_name),
    language text,
    PRIMARY KEY (full_name, language)
);

CREATE TABLE lesson_teaches (
    lesson_title        text PRIMARY KEY,
    teaching_instructor text UNIQUE REFERENCES instructors (full_name),
    room_number         integer NOT NULL
);

CREATE TABLE lesson_participants (
    lesson_title      text REFERENCES lesson_teaches (lesson_title),
    studying_students text REFERENCES students (full_name),
    PRIMARY KEY (lesson_title, studying_students)
);


--#4
INSERT INTO customers VALUES (1, 'Tanya', '2017-07-23', 'Almaty');
INSERT INTO customers VALUES (2, 'Alexandra', '2018-07-23', 'Almaty');
INSERT INTO customers VALUES (3, 'Kamila', '2019-07-23', 'Nur-Sultan');

SELECT * FROM customers;

UPDATE customers SET delivery_address = 'Almaty' WHERE delivery_address != 'Almaty';

DELETE from customers WHERE delivery_address = 'Almaty';


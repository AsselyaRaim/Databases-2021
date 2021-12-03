--Task 1
CREATE FUNCTION inc(val integer) RETURNS integer AS
    $$BEGIN
    RETURN val + 1;
    END; $$
    LANGUAGE plpgsql;

SELECT inc(10);

CREATE FUNCTION sum_of_two_numbers(val1 integer, val2 integer) RETURNS integer AS
    $$BEGIN
    RETURN val1 + val2;
    END; $$
    LANGUAGE plpgsql;

SELECT sum_of_two_numbers(1, 2);

CREATE FUNCTION divisible_by_two(val integer) RETURNS bool AS
    $$BEGIN
    RETURN val % 2 = 0;
    END; $$
    LANGUAGE plpgsql;

SELECT divisible_by_two(15);

CREATE FUNCTION is_valid_password(password text) RETURNS bool AS
    $$BEGIN
    RETURN length(password) >= 8 AND password SIMILAR TO '[a-zA-Z0-9]+';
    END; $$
    LANGUAGE plpgsql;

SELECT is_valid_password('qwerty123456789');

CREATE OR REPLACE FUNCTION two_outputs(word text, OUT length_of_word integer, OUT contains_numbers bool) AS
    $$BEGIN
        length_of_word := length(word);
        contains_numbers := word SIMILAR TO '%[0-9]+%';
    END $$
    LANGUAGE plpgsql;

SELECT * FROM two_outputs('hello98');

--Task 2
CREATE TABLE employees(
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name VARCHAR(40) NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   PRIMARY KEY(id)
);
CREATE TABLE employee_audits (
   id INT GENERATED ALWAYS AS IDENTITY,
   employee_id INT NOT NULL,
   change text,
   change_on timestamp
);

--logs changes on employees
CREATE OR REPLACE FUNCTION log_changes() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
    BEGIN
    IF (TG_OP = 'DELETE') THEN
            INSERT INTO employee_audits (employee_id, change, change_on) VALUES (OLD.id, 'DELETE', now());
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO employee_audits (employee_id, change, change_on) VALUES (OLD.id, 'UPDATE', now());
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO employee_audits (employee_id, change, change_on) VALUES(NEW.id, 'INSERT', now());
        END IF;
        RETURN NULL;
    END;
    $$;

CREATE TRIGGER changes
    AFTER INSERT OR DELETE OR UPDATE
    ON employees
    FOR EACH ROW
    EXECUTE PROCEDURE log_changes();

--logs changes in database
CREATE OR REPLACE FUNCTION log_any_command()
  RETURNS event_trigger
 LANGUAGE plpgsql
  AS $$
BEGIN
  RAISE NOTICE 'command % occurred on %', tg_tag, now();
END;
$$;

CREATE EVENT TRIGGER abort_ddl ON ddl_command_start
   EXECUTE FUNCTION log_any_command();


INSERT INTO employees (first_name, last_name)
VALUES ('John', 'Doe');

INSERT INTO employees (first_name, last_name)
VALUES ('Lily', 'Bush');

--b
CREATE TABLE students (
    id INT GENERATED ALWAYS AS IDENTITY,
    first_name text,
    last_name text,
    date_of_birth date,
    age integer
);
CREATE OR REPLACE FUNCTION get_age()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    BEGIN
        UPDATE students SET age = EXTRACT(YEAR FROM age(now(), NEW.date_of_birth))
        WHERE students.id = NEW.id;
        RETURN NEW;
    END;
    $$;
CREATE TRIGGER age
    AFTER INSERT
    ON students
    FOR EACH ROW
    EXECUTE PROCEDURE get_age();

INSERT INTO students (first_name, last_name, date_of_birth)
VALUES ('John', 'Doe', '2002-01-01');
INSERT INTO students (first_name, last_name, date_of_birth)
VALUES ('Lily', 'Bush', '2003-02-08');

--c
CREATE TABLE products (
    id INT GENERATED ALWAYS AS IDENTITY,
    name text,
    price integer
);
CREATE OR REPLACE FUNCTION add_tax()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    BEGIN
        NEW.price = NEW.price + NEW.price * 0.12;
        RETURN NEW;
    END;
    $$;
CREATE TRIGGER tax
    BEFORE INSERT
    ON products
    FOR EACH ROW
    EXECUTE PROCEDURE add_tax();

INSERT INTO products(name, price) VALUES ('Cola', 100);
INSERT INTO products(name, price) VALUES ('Fanta', 150);

--d
CREATE OR REPLACE FUNCTION prevent_deletion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    BEGIN
        RAISE NOTICE 'Cannot delete rows from this table';
        RETURN NEW;
    END;
    $$;

CREATE TRIGGER cant_delete
    BEFORE DELETE
    ON products
    FOR EACH ROW
    EXECUTE PROCEDURE prevent_deletion();


DELETE FROM products
WHERE id = 1;

--e
ALTER TABLE students
ADD COLUMN password text;

CREATE OR REPLACE FUNCTION is_valid_password1() RETURNS trigger AS $$
    DECLARE
        is_valid bool;
    BEGIN
        is_valid = is_valid_password(new.password);
        IF not is_valid THEN
       raise notice 'This password is not valid';
        END IF;
        RETURN NEW;
    END; $$
    LANGUAGE plpgsql;


CREATE TRIGGER valid_password
    BEFORE INSERT OR UPDATE
    ON students
    FOR EACH ROW
    EXECUTE FUNCTION is_valid_password1();


UPDATE students SET password = 'sdsds123456789' WHERE id = 1;
UPDATE students SET password = '1234' WHERE id = 2;


CREATE OR REPLACE FUNCTION two_outputs1() RETURNS trigger AS $$
    DECLARE
        l integer;
        c bool;
    BEGIN
        l = (two_outputs(new.password)).length_of_word;
        c = (two_outputs(new.password)).contains_numbers;
        RAISE NOTICE 'The length of password is %', l;
        RAISE NOTICE 'It contains numbers: %', c;
        RETURN NEW;
    END; $$
    LANGUAGE plpgsql;

CREATE TRIGGER add_two_outputs
    BEFORE INSERT OR UPDATE
    ON students
    FOR EACH ROW
    EXECUTE FUNCTION two_outputs1();


UPDATE students SET password = '12345678' WHERE id = 1;
UPDATE students SET password = 'sdssewddddssdsdds' WHERE id = 2;

--Task 3
--In PostgreSQL functions and procedures are the same, except that procedures support transactions.

--Task 4
CREATE TABLE task4 (
    id integer PRIMARY KEY,
    name varchar,
    date_of_birth date,
    age integer,
    salary integer,
    workexperience integer,
    discount integer
);

DROP TABLE task4;

INSERT INTO task4 VALUES (1, 'Lily', '2002-03-03', 19, 100000, 3, 0);
INSERT INTO task4 VALUES (2, 'Joe', '2000-03-03', 21, 200000, 6, 10);
INSERT INTO task4 VALUES (3, 'Katya', '1981-03-03', 40, 200000, 15, 15);
INSERT INTO task4 VALUES (4, 'Sasha', '1973-03-03', 48, 300000, 15, 10);

CREATE OR REPLACE PROCEDURE inc_salary()
LANGUAGE plpgsql
AS $$
    DECLARE
        f record;
        new_salary integer default 0;
        new_discount integer;
    BEGIN
        FOR f IN SELECT id, salary, workexperience, discount
            FROM task4
        LOOP
            new_salary = f.salary;
            FOR counter in 1..(f.workexperience/2) LOOP
                new_salary = new_salary + new_salary * 0.1;
            END LOOP;
            new_discount = f.discount + 10 + (f.workexperience/5);
            UPDATE task4 SET salary = new_salary WHERE id = f.id;
            UPDATE task4 SET discount = new_discount WHERE id = f.id;
        END LOOP;
    END;
    $$;

CALL inc_salary();

CREATE OR REPLACE PROCEDURE inc_salary1()
LANGUAGE plpgsql
AS $$
    DECLARE
        f record;
        new_salary integer default 0;
        new_discount integer;
    BEGIN
        FOR f IN SELECT id, age, salary, workexperience, discount
            FROM task4
        LOOP
            new_salary = f.salary;
            new_discount = f.discount;
            IF f.age >= 40 THEN
                new_salary = new_salary + new_salary * 0.15;
            END IF;
            IF f.workexperience > 8 THEN
                new_salary = new_salary + new_salary * 0.15;
                new_discount = 20;
            end if;
            UPDATE task4 SET salary = new_salary WHERE id = f.id;
            UPDATE task4 SET discount = new_discount WHERE id = f.id;
        END LOOP;
    END;
    $$;

CALL inc_salary1();

--Task 5
CREATE TABLE members (
    memid integer PRIMARY KEY ,
    surname character varying(200),
    firstname character varying(200),
    address character varying(300),
    zipcode integer,
    telephone character varying(20),
    recommendedby integer REFERENCES members(memid),
    joindate timestamp
);

INSERT INTO members (
	memid,
	firstname,
    surname,
	recommendedby
)
VALUES
	(1, 'Michael', 'North', NULL),
	(2, 'Megan', 'Berry', 1),
	(3, 'Sarah', 'Berry', 1),
	(4, 'Zoe', 'Black', 2),
	(5, 'Tim', 'James', 2),
	(12, 'Bella', 'Tucker', 2),
	(13, 'Ryan', 'Metcalfe', 3),
	(14, 'Max', 'Mills', 13),
	(15, 'Benjamin', 'Glover', 14),
	(22, 'Carolyn', 'Henderson', 15);

WITH RECURSIVE recommenders AS (
	SELECT
		memid,
	    recommendedby
	FROM
		members
	WHERE
	    memid = 22
	UNION
		SELECT
			m.memid,
            m.recommendedby
		FROM
			members m
		INNER JOIN recommenders r ON r.recommendedby = m.memid
) SELECT
	memid as member,
    recommendedby as recommender
FROM
	recommenders
ORDER BY memid asc,
         recommendedby desc;
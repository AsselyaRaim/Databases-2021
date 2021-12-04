CREATE TABLE brands (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    web_site varchar,
    vendor_id integer REFERENCES vendors(id)
);

CREATE TABLE vendors (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    city varchar NOT NULL,
    phone_number varchar(12)
);

CREATE TABLE products (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    size float NOT NULL,
    size_units varchar NOT NULL,
    upc_code varchar(12) UNIQUE NOT NULL,
    packaging_type varchar NOT NULL,
    category_id integer REFERENCES category(id),
    brand_id integer REFERENCES brands(id)
);

CREATE TABLE inventory (
    product_id integer REFERENCES products(id),
    store_id integer REFERENCES stores(id),
    price integer NOT NULL,
    quantity integer NOT NULL,
    PRIMARY KEY (product_id, store_id)
);

CREATE TABLE category (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    super_category varchar NOT NULL
);

CREATE TABLE orders (
    id integer PRIMARY KEY,
    total_sum integer DEFAULT 0,
    final_sum float DEFAULT 0,
    discount float DEFAULT 0,
    store_id integer REFERENCES stores(id),
    customer_id integer REFERENCES customers(id)
);

CREATE TABLE order_items (
    order_id integer REFERENCES orders(id),
    product_id integer REFERENCES products(id),
    quantity integer NOT NULL,
    PRIMARY KEY (product_id, order_id)
);

CREATE TABLE online_orders (
    id integer PRIMARY KEY,
    shipping_date date NOT NULL,
    required_date date NOT NULL,
    address varchar NOT NULL,
    city varchar NOT NULL,
    order_id integer UNIQUE REFERENCES orders(id)
);

CREATE TABLE stores (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    address varchar NOT NULL,
    city varchar NOT NULL,
    phone_number varchar(12),
    opening_hour time NOT NULL,
    closing_hour time NOT NULL
);

CREATE TABLE store_statistics(
    id integer PRIMARY KEY,
    store_id integer REFERENCES stores(id),
    product_id integer REFERENCES products(id),
    quantity integer NOT NULL
);

CREATE TABLE customers (
    id integer PRIMARY KEY,
    name varchar NOT NULL,
    address varchar,
    city varchar,
    phone_number varchar(12),
    e_mail text
);
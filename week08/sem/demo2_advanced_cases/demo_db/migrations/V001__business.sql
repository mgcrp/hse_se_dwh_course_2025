DROP SCHEMA IF EXISTS business CASCADE;
CREATE SCHEMA business;

-- customers
CREATE TABLE business.customers (
    customer_id SERIAL PRIMARY KEY,
    customer_fname VARCHAR(100) NOT NULL,
    customer_lname VARCHAR(100) NOT NULL
);
COPY business.customers
    FROM '/var/lib/postgresql/example_data/customers.csv' DELIMITER ',' CSV HEADER;

-- stores
CREATE TABLE business.stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL
);
COPY business.stores
    FROM '/var/lib/postgresql/example_data/stores.csv' DELIMITER ',' CSV HEADER;

-- manufacturers
CREATE TABLE business.manufacturers (
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL
);
COPY business.manufacturers
    FROM '/var/lib/postgresql/example_data/manufacturers.csv' DELIMITER ',' CSV HEADER;

-- categories
CREATE TABLE business.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
COPY business.categories
    FROM '/var/lib/postgresql/example_data/categories.csv' DELIMITER ',' CSV HEADER;

-- products
CREATE TABLE business.products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER
        REFERENCES business.categories (category_id) ON DELETE RESTRICT,
    manufacturer_id INTEGER
        REFERENCES business.manufacturers (manufacturer_id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL
);
COPY business.products
    FROM '/var/lib/postgresql/example_data/products.csv' DELIMITER ',' CSV HEADER;

-- purchases
CREATE TABLE business.purchases (
    purchase_id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL
        REFERENCES business.stores (store_id) ON DELETE RESTRICT,
    customer_id INTEGER NOT NULL
        REFERENCES business.customers (customer_id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,
    purchase_date TIMESTAMPTZ NOT NULL
);
COPY business.purchases
    FROM '/var/lib/postgresql/example_data/purchases.csv' DELIMITER ',' CSV HEADER;

-- purchase_items
CREATE TABLE business.purchase_items (
    product_id INTEGER NOT NULL
        REFERENCES business.products (product_id) ON DELETE RESTRICT,
    purchase_id INTEGER NOT NULL
        REFERENCES business.purchases (purchase_id) ON DELETE RESTRICT,
    product_count BIGINT NOT NULL CHECK (product_count > 0),
    product_price NUMERIC(9, 2) NOT NULL
);
COPY business.purchase_items
    FROM '/var/lib/postgresql/example_data/purchase_items.csv' DELIMITER ',' CSV HEADER;

-- deliveries
CREATE TABLE business.deliveries (
    store_id INTEGER
        REFERENCES business.stores (store_id) ON DELETE RESTRICT,
    product_id INTEGER NOT NULL
        REFERENCES business.products (product_id) ON DELETE RESTRICT,
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL CHECK (product_count > 0)
);
COPY business.deliveries
    FROM '/var/lib/postgresql/example_data/deliveries.csv' DELIMITER ',' CSV HEADER;

-- price_change
CREATE TABLE business.price_change (
    product_id INTEGER NOT NULL
        REFERENCES business.products (product_id) ON DELETE RESTRICT,
    price_change_ts TIMESTAMPTZ NOT NULL,
    new_price NUMERIC(9, 2) NOT NULL
);
COPY business.price_change
    FROM '/var/lib/postgresql/example_data/price_change.csv' DELIMITER ',' CSV HEADER;


-- gmv view
CREATE VIEW business.gmv_by_store_category AS
WITH GMV_Calc AS (
    SELECT
        p.store_id,
        pr.category_id,
        SUM(pi.product_count * pi.product_price) AS sales_sum
    FROM
        business.purchases p
    JOIN
        business.purchase_items pi ON p.purchase_id = pi.purchase_id
    JOIN
        business.products pr ON pi.product_id = pr.product_id
    GROUP BY
        p.store_id,
        pr.category_id
)
SELECT
    store_id,
    category_id,
    sales_sum
FROM
    GMV_Calc
ORDER BY
    store_id,
    category_id;

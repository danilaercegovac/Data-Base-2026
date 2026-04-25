CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    address TEXT UNIQUE NOT NULL
);

ALTER TABLE products ADD COLUMN category_id INTEGER REFERENCES categories(category_id);

ALTER TABLE orders ADD COLUMN address_id INTEGER REFERENCES addresses(address_id);

INSERT INTO categories (name)
VALUES
    ('Электроника'),
    ('Аксессуары');

INSERT INTO addresses (address)
SELECT DISTINCT delivery_address
FROM orders_1nf;

UPDATE products
SET category_id =
    CASE
        WHEN name IN ('Ноутбук', 'Клавиатура') THEN 1 -- Электроника
        WHEN name IN ('Мышь', 'Коврик') THEN 2 -- Аксессуары
    END;

UPDATE orders
SET address_id = a.address_id
FROM addresses a
WHERE orders.delivery_address = a.address;

ALTER TABLE orders DROP COLUMN delivery_address;

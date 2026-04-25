CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    delivery_address TEXT NOT NULL,
    total_amount NUMERIC NOT NULL,
    status TEXT NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    price NUMERIC NOT NULL
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL
);

INSERT INTO customers (name, email, phone)
SELECT DISTINCT customer_name, customer_email, customer_phone
FROM orders_1nf;

INSERT INTO orders (order_id, order_date, customer_id, delivery_address, total_amount, status)
select
	o.order_id,
    o.order_date,
    c.customer_id,
    o.delivery_address,
    o.total_amount,
    o.status
FROM orders_1nf o
JOIN customers c ON o.customer_email = c.email
group by o.order_id, o.order_date, c.customer_id, o.delivery_address, o.total_amount, o.status; 

INSERT INTO products (name, price)
SELECT DISTINCT product_name, product_price
FROM orders_1nf;


INSERT INTO order_items (order_id, product_id, quantity)
SELECT
    o.order_id,
    p.product_id,
    oi.product_quantity
FROM orders_1nf oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_name = p.name;


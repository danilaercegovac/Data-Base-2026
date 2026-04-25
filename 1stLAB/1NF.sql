CREATE TABLE orders_1nf (
    order_id INTEGER,
    order_date DATE,
    customer_name TEXT,
    customer_email TEXT,
    customer_phone TEXT,
    delivery_address TEXT,
    product_name TEXT,
    product_price NUMERIC,
    product_quantity INTEGER,
    total_amount NUMERIC,
    status TEXT
);
INSERT INTO orders_1nf (
    order_id, order_date, customer_name, customer_email, customer_phone,
    delivery_address, product_name, product_price, product_quantity, total_amount, status
)
SELECT
    r.order_id,
    r.order_date,
    r.customer_name,
    r.customer_email,
    r.customer_phone,
    r.delivery_address,
    TRIM(unnest(string_to_array(r.product_names, ','))) AS product_name,
    unnest(string_to_array(r.product_prices, ','))::NUMERIC AS product_price,
    unnest(string_to_array(r.product_quantities, ','))::INTEGER AS product_quantity,
    r.total_amount,
    r.status
FROM orders_raw r;

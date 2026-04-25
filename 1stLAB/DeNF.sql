ALTER TABLE order_items
ADD COLUMN price_at_order NUMERIC NOT NULL DEFAULT 0;

CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT
    date_trunc('month', o.order_date) AS month,
    p.name AS product_name,
    c.name AS category_name,
    SUM(oi.quantity) AS total_qty,
    SUM(oi.quantity * oi.price_at_order) AS total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY
    date_trunc('month', o.order_date),
    p.name,
    c.name;

EXPLAIN ANALYZE
SELECT
    date_trunc('month', o.order_date) AS month,
    p.name AS product_name,
    c.name AS category_name,
    SUM(oi.quantity) AS total_qty,
    SUM(oi.quantity * oi.price_at_order) AS total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY
    date_trunc('month', o.order_date),
    p.name,
    c.name
ORDER BY month, category_name, product_name;

EXPLAIN ANALYZE
SELECT
    month,
    product_name,
    category_name,
    total_qty,
    total_revenue
FROM mv_monthly_sales
ORDER BY month, category_name, product_name;

ALTER TABLE orders
ADD COLUMN customer_name TEXT;

UPDATE orders o
SET customer_name = c.name
FROM customers c
WHERE c.customer_id = o.customer_id;

EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.order_date,
    c.name AS customer_name,
    o.total_amount,
    o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

EXPLAIN ANALYZE
SELECT
    order_id,
    order_date,
    customer_name,
    total_amount,
    status
FROM orders;
EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.customer_id,
    c.name AS customer_name,
    c.email,
    oi.order_item_id,
    oi.quantity,
    p.product_id,
    p.name AS product_name,
    p.price
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_id = 1;
EXPLAIN ANALYZE
SELECT
    p.product_id,
    p.name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * p.price) AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_quantity DESC
LIMIT 10;
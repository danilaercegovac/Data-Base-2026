EXPLAIN ANALYZE
UPDATE orders
SET status = 'shipped'
WHERE order_id = 1;
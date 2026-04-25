ALTER TABLE customers DROP CONSTRAINT customers_email_key;

DROP INDEX IF EXISTS idx_customers_name_trgm;

EXPLAIN ANALYZE
SELECT
    customer_id,
    name,
    email,
    phone
FROM customers
WHERE email = 'test@example.com';

CREATE INDEX idx_customers_name
ON customers(name);

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE name LIKE '%ivan%';


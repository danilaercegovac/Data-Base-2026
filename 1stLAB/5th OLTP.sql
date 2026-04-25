--CREATE INDEX idx_customers_email ON customers(email);

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_customers_name_trgm
ON customers USING gin (name gin_trgm_ops);

EXPLAIN ANALYZE
SELECT
    customer_id,
    name,
    email,
    phone
FROM customers
WHERE email = 'test@example.com';

EXPLAIN ANALYZE
SELECT
    customer_id,
    name,
    email,
    phone
FROM customers
WHERE name ILIKE '%ivan%';
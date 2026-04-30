-- Создание таблицы без tsv
CREATE TABLE pg_products (
    id SERIAL PRIMARY KEY,
    title TEXT,
    description TEXT,
    category TEXT,
    brand TEXT,
    price DECIMAL(10,2),
    rating DECIMAL(2,1),
    reviews_count INTEGER,
    in_stock INTEGER,
    tags JSONB
);

-- Добавление tsv-колонки
ALTER TABLE pg_products
ADD COLUMN tsv tsvector
GENERATED ALWAYS AS (to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(description, ''))) STORED;

-- Создание gin-индекса
CREATE INDEX idx_tsv ON pg_products USING GIN(tsv);

\timing on

-- Базовый поиск
SELECT title, ts_rank(tsv, q) AS rank
FROM pg_products, to_tsquery('english', 'wireless & bluetooth & headphones') q
WHERE tsv @@ q
ORDER BY rank DESC
LIMIT 10;

-- Фразовый поиск
SELECT title, ts_rank(tsv, phraseto_tsquery('english', 'noise cancelling')) AS rank
FROM pg_products
WHERE tsv @@ phraseto_tsquery('english', 'noise cancelling')
LIMIT 10;

-- Proximity-поиск
SELECT title, ts_rank(tsv, to_tsquery('english', 'portable <-> speaker')) AS rank
FROM pg_products
WHERE tsv @@ to_tsquery('english', 'portable <-> speaker')
LIMIT 10;

-- Поиск с фильтрацией
SELECT title, price, rating
FROM pg_products, to_tsquery('english', 'laptop') q
WHERE tsv @@ q
  AND price BETWEEN 30000 AND 80000
  AND rating >= 4.0
ORDER BY rating DESC
LIMIT 10;

-- Поиск по JSON
SELECT title, tags
FROM pg_products, to_tsquery('english', 'phone') q
WHERE tsv @@ q
  AND tags->>'color' = 'black'
LIMIT 10;

-- Агрегация
SELECT category, COUNT(*) AS cnt, AVG(price) AS avg_price
FROM pg_products, to_tsquery('english', 'gaming') q
WHERE tsv @@ q
GROUP BY category
ORDER BY cnt DESC;

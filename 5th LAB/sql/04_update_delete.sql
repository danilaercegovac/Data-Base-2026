-- Выберем какой-нибудь id товара - получился 7065342866398164061
SELECT id, title, price, rating
FROM products
LIMIT 1
OFFSET 345;

-- Обновляем конкретный товар по id
UPDATE products
SET price = 99999.99, rating = 5.0
WHERE id = 7065342866398164061;

-- Результат UPDATE
SELECT id, title, price, rating
FROM products
WHERE id = 7065342866398164061;

-- Выполняем замену документа с определенным ID
REPLACE INTO products
(id, title, description, category, brand, price, rating, reviews_count, in_stock, tags, created_at)
VALUES (
    7065342866398164061,
    'NEW NAME',
    'NEW DESCRIPTION',
    'Ultra Gaming',
    'ASUS ROG',
    199999.99,
    5.0,
    9999,
    1,
    '{"color":"black","material":"titanium","rgb":true}',
    7065342866398164061
);

-- Проверяем результат
SELECT id, title, description, brand, price, rating, tags
FROM products
WHERE id = 7065342866398164061;

-- Удаляем этот товар
DELETE
FROM products
WHERE id = 7065342866398164061;

-- Проверяем,что удаление успешное
SELECT id, title
FROM products
WHERE id = 7065342866398164061;

-- Также убедимся, что товара нет в поиске
SELECT id, title
FROM products
WHERE MATCH('NEW NAME');

-- Топ 10
SELECT 
    product_id,
    product_name,
    SUM(line_total) AS total_revenue
FROM lab.orders_flat
GROUP BY product_id, product_name
ORDER BY total_revenue DESC
LIMIT 10;

--Ежемесячная динамика
SELECT 
    toStartOfMonth(order_date) AS month,
    category,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(quantity) AS total_quantity,
    SUM(line_total) AS total_revenue,
    AVG(line_total) AS avg_order_value
FROM lab.orders_flat
GROUP BY month, category
ORDER BY month, category;

-- Процентиль p95/p99
WITH order_totals AS (
    SELECT 
        order_id,
        SUM(line_total) AS order_total
    FROM lab.orders_flat
    GROUP BY order_id
)
SELECT 
    quantileExact(0.95)(order_total) AS p95_exact,
    quantileExact(0.99)(order_total) AS p99_exact
FROM order_totals;

-- Поиск клиента по подстроке email
SELECT DISTINCT
    customer_id,
    customer_name,
    customer_email,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(line_total) AS total_spent
FROM lab.orders_flat
WHERE customer_email LIKE 'customer2099@mail.com'
GROUP BY customer_id, customer_name, customer_email
ORDER BY total_spent DESC
LIMIT 100;

-- Сравнение результата из orders_flat и monthly_sales

-- Запрос из orders_flat (с ручной агрегацией)
SELECT
    toStartOfMonth(order_date) AS month,
    category,
    region,
    sum(line_total) AS revenue,
    sum(quantity) AS quantity
FROM orders_flat
GROUP BY month, category, region
ORDER BY month, category, region
LIMIT 10;

-- Запрос из monthly_sales
SELECT
    month,
    category,
    region,
    sum(revenue) AS revenue,
    sum(quantity) AS quantity
FROM monthly_sales
GROUP BY month, category, region
ORDER BY month, category, region
LIMIT 10;

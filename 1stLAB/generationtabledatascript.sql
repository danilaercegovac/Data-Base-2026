INSERT INTO orders_raw (order_id, order_date, customer_name, customer_email, customer_phone, delivery_address, product_names, product_prices, product_quantities, total_amount, status)
SELECT
    gs AS order_id,
    CURRENT_DATE - (random() * 30)::int AS order_date,
    CONCAT('Клиент ', gs) AS customer_name,
    CONCAT('client', gs, '@example.com') AS customer_email,
    CONCAT('+7 (999) ', lpad((random() * 999999)::text, 6, '0')) AS customer_phone,
    CONCAT('г. Санкт-Петербург, ул. ИТМО, д. ', (random() * 100)::int) AS delivery_address,
    CASE
        WHEN gs % 3 = 0 THEN 'Ноутбук'
        WHEN gs % 3 = 1 THEN 'Мышь, Коврик'
        ELSE 'Клавиатура, Ноутбук'
    END AS product_names,
    CASE
        WHEN gs % 3 = 0 THEN '85000'
        WHEN gs % 3 = 1 THEN '1500, 500'
        ELSE '3000, 85000'
    END AS product_prices,
    CASE
        WHEN gs % 3 = 0 THEN '1'
        WHEN gs % 3 = 1 THEN '2, 3'
        ELSE '1, 1'
    END AS product_quantities,
    CASE
        WHEN gs % 3 = 0 THEN 85000
        WHEN gs % 3 = 1 THEN (1500 * 2) + (500 * 3)  -- 4500
        ELSE (3000 * 1) + (85000 * 1)  -- 88000
    END AS total_amount,
    CASE (random() * 3)::int
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'delivered'
        ELSE 'cancelled'
    END AS status
FROM generate_series(1, 1000) AS gs;
	
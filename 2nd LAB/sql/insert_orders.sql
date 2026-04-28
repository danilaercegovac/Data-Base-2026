INSERT INTO orders_flat
SELECT
    toDate('2025-01-01') + (number % 365) AS order_date,
    toDateTime(order_date) + (number % 86400) AS order_datetime,

    number + 1 AS order_id,
    1000 + (number % 50000) AS customer_id,
    concat('Customer ', toString(customer_id)) AS customer_name,
    concat('customer', toString(customer_id), '@mail.com') AS customer_email,

    arrayElement(['EU', 'CIS', 'US', 'ASIA'], 1 + (number % 4)) AS region,

    10000 + (number % 10000) AS product_id,
    concat('Product ', toString(product_id)) AS product_name,

    arrayElement(['Electronics', 'Food', 'Clothes', 'Furniture', 'Books'], 1 + (number % 5)) AS category,

    toUInt32(1 + (number % 5)) AS quantity,
    toDecimal64(10 + (number % 1000), 2) AS price,
    toDecimal64(quantity * price, 2) AS line_total,

    arrayElement(['created', 'paid', 'shipped', 'cancelled'], 1 + (number % 4)) AS order_status
FROM numbers(1000000);
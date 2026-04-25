BEGIN;
WITH new_order AS (
    INSERT INTO orders (
        order_date,
        customer_id,
        address_id,
        total_amount,
        status
    )
    VALUES (
        CURRENT_DATE,
        1,
        1,
        100.00,
        'created'
    )
    RETURNING order_id
)
INSERT INTO order_items (
    order_id,
    product_id,
    quantity
)
SELECT
    new_order.order_id,
    1,
    2
FROM new_order;
commit;

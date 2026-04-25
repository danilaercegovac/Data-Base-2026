|QUERY PLAN|
|----------|
|Insert on order_items  (cost=0.02..0.04 rows=1 width=16) (actual time=0.304..0.304 rows=0 loops=1)|
|  CTE new_order|
|    ->  Insert on orders  (cost=0.00..0.02 rows=1 width=88) (actual time=0.221..0.221 rows=1 loops=1)|
|          ->  Result  (cost=0.00..0.02 rows=1 width=88) (actual time=0.042..0.042 rows=1 loops=1)|
|  ->  CTE Scan on new_order  (cost=0.00..0.03 rows=1 width=16) (actual time=0.238..0.239 rows=1 loops=1)|
|Planning Time: 0.104 ms|
|Trigger for constraint order_items_order_id_fkey on order_items: time=0.059 calls=1|
|Trigger for constraint order_items_product_id_fkey on order_items: time=0.052 calls=1|
|Trigger for constraint orders_customer_id_fkey on orders: time=0.305 calls=1|
|Trigger for constraint orders_address_id_fkey on orders: time=0.136 calls=1|
|Execution Time: 0.959 ms|

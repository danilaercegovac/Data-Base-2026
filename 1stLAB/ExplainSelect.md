|QUERY PLAN|
|----------|
|Nested Loop  (cost=0.70..63.81 rows=2 width=140) (actual time=0.050..0.157 rows=2 loops=1)|
|  ->  Nested Loop  (cost=0.55..47.46 rows=2 width=76) (actual time=0.045..0.150 rows=2 loops=1)|
|        ->  Nested Loop  (cost=0.55..16.60 rows=1 width=64) (actual time=0.037..0.051 rows=1 loops=1)|
|              ->  Index Scan using orders_pkey on orders o  (cost=0.28..8.29 rows=1 width=27) (actual time=0.032..0.045 rows=1 loops=1)|
|                    Index Cond: (order_id = 1)|
|              ->  Index Scan using customers_pkey on customers c  (cost=0.28..8.29 rows=1 width=41) (actual time=0.004..0.004 rows=1 loops=1)|
|                    Index Cond: (customer_id = o.customer_id)|
|        ->  Seq Scan on order_items oi  (cost=0.00..30.84 rows=2 width=16) (actual time=0.007..0.098 rows=2 loops=1)|
|              Filter: (order_id = 1)|
|              Rows Removed by Filter: 1670|
|  ->  Index Scan using products_pkey on products p  (cost=0.15..8.17 rows=1 width=68) (actual time=0.002..0.002 rows=1 loops=2)|
|        Index Cond: (product_id = oi.product_id)|
|Planning Time: 0.283 ms|
|Execution Time: 0.192 ms|

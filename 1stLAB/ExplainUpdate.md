|QUERY PLAN|
|----------|
|Update on orders  (cost=0.28..8.29 rows=1 width=68) (actual time=2.487..2.488 rows=0 loops=1)|
|  ->  Index Scan using orders_pkey on orders  (cost=0.28..8.29 rows=1 width=68) (actual time=0.387..0.391 rows=1 loops=1)|
|        Index Cond: (order_id = 1)|
|Planning Time: 0.831 ms|
|Execution Time: 2.792 ms|

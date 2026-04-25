|QUERY PLAN|
|----------|
|Limit  (cost=107.76..107.78 rows=10 width=76) (actual time=1.077..1.080 rows=4 loops=1)|
|  ->  Sort  (cost=107.76..109.78 rows=810 width=76) (actual time=1.076..1.078 rows=4 loops=1)|
|        Sort Key: (sum(oi.quantity)) DESC|
|        Sort Method: quicksort  Memory: 25kB|
|        ->  HashAggregate  (cost=80.13..90.26 rows=810 width=76) (actual time=1.050..1.054 rows=4 loops=1)|
|              Group Key: p.product_id|
|              Batches: 1  Memory Usage: 49kB|
|              ->  Hash Join  (cost=28.23..59.29 rows=1667 width=72) (actual time=0.177..0.585 rows=1672 loops=1)|
|                    Hash Cond: (oi.product_id = p.product_id)|
|                    ->  Seq Scan on order_items oi  (cost=0.00..26.67 rows=1667 width=8) (actual time=0.015..0.144 rows=1672 loops=1)|
|                    ->  Hash  (cost=18.10..18.10 rows=810 width=68) (actual time=0.038..0.038 rows=4 loops=1)|
|                          Buckets: 1024  Batches: 1  Memory Usage: 9kB|
|                          ->  Seq Scan on products p  (cost=0.00..18.10 rows=810 width=68) (actual time=0.010..0.012 rows=4 loops=1)|
|Planning Time: 0.372 ms|
|Execution Time: 1.377 ms|

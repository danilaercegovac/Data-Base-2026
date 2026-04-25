|QUERY PLAN|
|----------|
|Hash Join  (cost=34.50..91.22 rows=1007 width=39) (actual time=0.220..0.434 rows=1007 loops=1)|
|  Hash Cond: (o.customer_id = c.customer_id)|
|  ->  Seq Scan on orders o  (cost=0.00..54.07 rows=1007 width=27) (actual time=0.008..0.111 rows=1007 loops=1)|
|  ->  Hash  (cost=22.00..22.00 rows=1000 width=20) (actual time=0.205..0.205 rows=1000 loops=1)|
|        Buckets: 1024  Batches: 1  Memory Usage: 63kB|
|        ->  Seq Scan on customers c  (cost=0.00..22.00 rows=1000 width=20) (actual time=0.003..0.096 rows=1000 loops=1)|
|Planning Time: 0.389 ms|
|Execution Time: 0.479 ms|

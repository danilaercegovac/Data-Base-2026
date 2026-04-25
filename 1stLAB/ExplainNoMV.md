|QUERY PLAN|
|----------|
|GroupAggregate  (cost=270.70..333.21 rows=1667 width=112) (actual time=2.205..2.565 rows=8 loops=1)|
|  Group Key: (date_trunc('month'::text, (o.order_date)::timestamp with time zone)), c.name, p.name|
|  ->  Sort  (cost=270.70..274.87 rows=1667 width=108) (actual time=2.176..2.235 rows=1672 loops=1)|
|        Sort Key: (date_trunc('month'::text, (o.order_date)::timestamp with time zone)), c.name, p.name|
|        Sort Method: quicksort  Memory: 262kB|
|        ->  Hash Join  (cost=133.30..181.49 rows=1667 width=108) (actual time=0.345..1.553 rows=1672 loops=1)|
|              Hash Cond: (p.category_id = c.category_id)|
|              ->  Hash Join  (cost=94.72..130.19 rows=1667 width=76) (actual time=0.304..0.971 rows=1672 loops=1)|
|                    Hash Cond: (oi.product_id = p.product_id)|
|                    ->  Hash Join  (cost=66.50..97.57 rows=1667 width=44) (actual time=0.293..0.723 rows=1672 loops=1)|
|                          Hash Cond: (oi.order_id = o.order_id)|
|                          ->  Seq Scan on order_items oi  (cost=0.00..26.67 rows=1667 width=44) (actual time=0.006..0.178 rows=1672 loops=1)|
|                          ->  Hash  (cost=54.00..54.00 rows=1000 width=8) (actual time=0.279..0.280 rows=1007 loops=1)|
|                                Buckets: 1024  Batches: 1  Memory Usage: 48kB|
|                                ->  Seq Scan on orders o  (cost=0.00..54.00 rows=1000 width=8) (actual time=0.006..0.166 rows=1007 loops=1)|
|                    ->  Hash  (cost=18.10..18.10 rows=810 width=40) (actual time=0.007..0.007 rows=4 loops=1)|
|                          Buckets: 1024  Batches: 1  Memory Usage: 9kB|
|                          ->  Seq Scan on products p  (cost=0.00..18.10 rows=810 width=40) (actual time=0.005..0.006 rows=4 loops=1)|
|              ->  Hash  (cost=22.70..22.70 rows=1270 width=36) (actual time=0.021..0.021 rows=2 loops=1)|
|                    Buckets: 2048  Batches: 1  Memory Usage: 17kB|
|                    ->  Seq Scan on categories c  (cost=0.00..22.70 rows=1270 width=36) (actual time=0.016..0.016 rows=2 loops=1)|
|Planning Time: 0.380 ms|
|Execution Time: 2.670 ms|

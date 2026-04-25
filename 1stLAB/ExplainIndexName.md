|QUERY PLAN|
|----------|
|Bitmap Heap Scan on customers  (cost=12.00..16.01 rows=1 width=57) (actual time=0.077..0.077 rows=0 loops=1)|
|  Recheck Cond: (name ~~* '%ivan%'::text)|
|  ->  Bitmap Index Scan on idx_customers_name_trgm  (cost=0.00..12.00 rows=1 width=0) (actual time=0.075..0.075 rows=0 loops=1)|
|        Index Cond: (name ~~* '%ivan%'::text)|
|Planning Time: 0.116 ms|
|Execution Time: 0.093 ms|

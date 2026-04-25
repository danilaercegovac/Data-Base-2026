|QUERY PLAN|
|----------|
|Seq Scan on customers  (cost=0.00..24.50 rows=1 width=57) (actual time=0.079..0.080 rows=0 loops=1)|
|  Filter: (email = 'test@example.com'::text)|
|  Rows Removed by Filter: 1000|
|Planning Time: 0.087 ms|
|Execution Time: 0.091 ms|

|QUERY PLAN|
|----------|
|Seq Scan on customers  (cost=0.00..24.50 rows=1 width=57) (actual time=0.412..0.412 rows=0 loops=1)|
|  Filter: (name ~~* '%ivan%'::text)|
|  Rows Removed by Filter: 1000|
|Planning Time: 0.120 ms|
|Execution Time: 0.429 ms|

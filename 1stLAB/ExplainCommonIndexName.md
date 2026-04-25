|QUERY PLAN|
|----------|
|Seq Scan on customers  (cost=0.00..24.50 rows=1 width=57) (actual time=2.264..2.279 rows=0 loops=1)|
|  Filter: (name ~~ '%ivan%'::text)|
|  Rows Removed by Filter: 1000|
|Planning Time: 5.727 ms|
|Execution Time: 3.066 ms|

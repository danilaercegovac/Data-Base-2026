|QUERY PLAN|
|----------|
|Sort  (cost=42.42..43.87 rows=580 width=112) (actual time=0.089..0.091 rows=8 loops=1)|
|  Sort Key: month, category_name, product_name|
|  Sort Method: quicksort  Memory: 26kB|
|  ->  Seq Scan on mv_monthly_sales  (cost=0.00..15.80 rows=580 width=112) (actual time=0.035..0.037 rows=8 loops=1)|
|Planning Time: 0.081 ms|
|Execution Time: 0.187 ms|

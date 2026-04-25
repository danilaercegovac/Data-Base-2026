|QUERY PLAN|
|----------|
|Index Scan using customers_email_key on customers  (cost=0.28..8.29 rows=1 width=57) (actual time=0.042..0.042 rows=0 loops=1)|
|  Index Cond: (email = 'test@example.com'::text)|
|Planning Time: 0.133 ms|
|Execution Time: 0.070 ms|

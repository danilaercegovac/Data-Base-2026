SELECT '1. count through Distributed' AS check_name;
SELECT count() AS distributed_rows FROM events_distributed;

SELECT '2. local rows by host' AS check_name;
SELECT
    hostName() AS host,
    count() AS rows
FROM clusterAllReplicas('cluster_2x2', default.events_local)
GROUP BY host
ORDER BY host;

SELECT '3. top 10 users by events' AS check_name;
SELECT
    user_id,
    count() AS events
FROM events_distributed
GROUP BY user_id
ORDER BY events DESC
LIMIT 10;

SELECT '4. top 10 pages by visits' AS check_name;
SELECT
    page_url,
    count() AS visits
FROM events_distributed
GROUP BY page_url
ORDER BY visits DESC
LIMIT 10;

SELECT '5. JOIN with user dictionary' AS check_name;
SELECT
    d.segment,
    count() AS events
FROM events_distributed AS e
INNER JOIN user_dict_distributed AS d ON e.user_id = d.user_id
GROUP BY d.segment
ORDER BY events DESC;

SELECT '6. GLOBAL JOIN variant' AS check_name;
SELECT
    d.segment,
    count() AS events
FROM events_distributed AS e
GLOBAL INNER JOIN user_dict_distributed AS d ON e.user_id = d.user_id
GROUP BY d.segment
ORDER BY events DESC;

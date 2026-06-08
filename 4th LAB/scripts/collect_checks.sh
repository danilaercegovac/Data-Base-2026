```bash
#!/usr/bin/env bash
set -euo pipefail

MAIN_CONTAINER="idz4_ch_s1r1"

mkdir -p checks

echo "Collecting cluster info..."

docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
SELECT
    cluster,
    shard_num,
    replica_num,
    host_name,
    host_address,
    port,
    is_local
FROM system.clusters
WHERE cluster = 'cluster_2x2'
ORDER BY shard_num, replica_num
FORMAT PrettyCompact
" > checks/cluster_info.txt

echo "Collecting data distribution info..."

{
    echo "=== Rows on every replica ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        hostName() AS host,
        count() AS rows
    FROM clusterAllReplicas('cluster_2x2', default.events_local)
    GROUP BY host
    ORDER BY host
    FORMAT PrettyCompact
    "

    echo
    echo "=== Unique users and rows on every replica ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        hostName() AS host,
        uniq(user_id) AS unique_users,
        count() AS rows
    FROM clusterAllReplicas('cluster_2x2', default.events_local)
    GROUP BY host
    ORDER BY host
    FORMAT PrettyCompact
    "

    echo
    echo "=== Total rows from distributed table ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        count() AS total_rows,
        uniqExact(user_id) AS unique_users
    FROM events_distributed
    FORMAT PrettyCompact
    "

    echo
    echo "=== Users placed on more than one host, should be empty ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        user_id,
        uniq(hostName()) AS hosts_count,
        groupArrayDistinct(hostName()) AS hosts
    FROM clusterAllReplicas('cluster_2x2', default.events_local)
    GROUP BY user_id
    HAVING hosts_count > 1
    LIMIT 10
    FORMAT PrettyCompact
    "
} > checks/data_distribution.txt

echo "Collecting distributed queries info..."

{
    echo "=== Global COUNT from Distributed table ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT count() AS distributed_rows
    FROM events_distributed
    FORMAT PrettyCompact
    "

    echo
    echo "=== Sum of local rows from replicas ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT sum(rows) AS local_rows_sum
    FROM
    (
        SELECT
            hostName() AS host,
            count() AS rows
        FROM clusterAllReplicas('cluster_2x2', default.events_local)
        GROUP BY host
    )
    FORMAT PrettyCompact
    "

    echo
    echo "=== Top 10 users by events ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        user_id,
        count() AS events_count
    FROM events_distributed
    GROUP BY user_id
    ORDER BY events_count DESC
    LIMIT 10
    FORMAT PrettyCompact
    "

    echo
    echo "=== Top 10 pages by visits ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        page_url,
        count() AS visits
    FROM events_distributed
    GROUP BY page_url
    ORDER BY visits DESC
    LIMIT 10
    FORMAT PrettyCompact
    "

    echo
    echo "=== JOIN with user_dict ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        d.segment,
        count() AS events_count
    FROM events_distributed AS e
    INNER JOIN user_dict AS d
        ON e.user_id = d.user_id
    GROUP BY d.segment
    ORDER BY events_count DESC
    FORMAT PrettyCompact
    "

    echo
    echo "=== GLOBAL JOIN with user_dict ==="
    docker exec -i "$MAIN_CONTAINER" clickhouse-client --query "
    SELECT
        d.segment,
        count() AS events_count
    FROM events_distributed AS e
    GLOBAL INNER JOIN user_dict AS d
        ON e.user_id = d.user_id
    GROUP BY d.segment
    ORDER BY events_count DESC
    FORMAT PrettyCompact
    "
} > checks/distributed_queries.txt

cat > checks/reshard_demo.txt <<'EOF'
Третий шард на этом этапе ещё не добавлен.

После добавления третьего шарда нужно:
1. обновить конфигурацию cluster.xml;
2. добавить макросы для новых реплик;
3. перезапустить docker compose;
4. пересоздать Distributed-таблицу под cluster_3x2;
5. вставить новые данные с event_type = 'new_shard_test';
6. повторно собрать проверку распределения.
EOF

echo "Done. Results saved to checks/"
```

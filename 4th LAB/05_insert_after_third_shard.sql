#!/usr/bin/env bash
set -euo pipefail

ROWS="${1:-2000000}"
CONTAINER="${CLICKHOUSE_CONTAINER:-ch-s1-r1}"

docker exec -i "$CONTAINER" clickhouse-client --query "
INSERT INTO events_distributed
SELECT
    today() - toIntervalDay(rand() % 30) AS event_date,
    now() - toIntervalSecond(rand() % 2592000) AS event_time,
    rand() % 10000 + 1 AS user_id,
    toString(generateUUIDv4()) AS session_id,
    ['click', 'view', 'scroll', 'purchase', 'logout'][rand() % 5 + 1] AS event_type,
    concat('/page/', toString(rand() % 100 + 1)) AS page_url,
    rand() % 5000 AS duration_ms
FROM numbers($ROWS);
"

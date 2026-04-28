CREATE TABLE monthly_sales (
    month      Date,
    category   LowCardinality(String),
    region     LowCardinality(String),
    revenue    Decimal(14,2),
    quantity   UInt64
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(month)
ORDER BY (month, category, region);
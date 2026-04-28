# 2ая лабораторная работа.
## Описание работы
### Часть 1. Установка и начальная настройка
- *Docker Desktop установлен*
- Устанавливаем образ ClickHouse: `docker pull clickhouse/clickhouse-server`
  - Если возникла проблема при загрузке, может помочь `docker system prune` - очистит неиспользуемые файлы (осторожно)
- Создаем директорию `kdir clickhouse-2lab` -> `cd clickhouse-2lab`
- Создаём пустой конфигурационный файл докера `type nul > docker-compose.yml`
- Открываем .yml через `notepad docker-compose.yml` и указываем описание сервиса
  - Порты:
    - Порт 8123:8123 открываем для http-запросов, например, `curl "http://localhost:8123/?query=SELECT%201"`
    - Порт 9000:9000 открываем для для подключения через clickhouse-client и native-протокол, например, `docker exec -it clickhouse clickhouse-client`
  - Volumes. Указываем сопоставление локальных директорий и директорий кликхауса. При запуске Кликхаус их сопоставит и будет применять
```
services:
  clickhouse:
    image: clickhouse/clickhouse-server:latest
    container_name: clickhouse
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - ./config.d:/etc/clickhouse-server/config.d
      - ./users.d:/etc/clickhouse-server/users.d
      - clickhouse_data:/var/lib/clickhouse

volumes:
  clickhouse_data:
```
- Создаём пустой конфигурационный файл для метода прослушивания Кликхауса `mkdir config.d` -> `type nul > config.d/listen.xml`
- Открываем listen.xml через `notepad config.d/listen.xml` и указываем метод прослушивания
  - `<listen_host>0.0.0.0</listen_host>` означает, что Кликхаус слушает подключения на всех сетевых интерфейсах контейнера, то есть все указанные в докер конфиге типа 8123:8123 и 9000:9000
```
<clickhouse>
    <listen_host>0.0.0.0</listen_host>
</clickhouse>
```
- Создаём пустой конфигурационный файл для пользователей через `mkdir users.d` -> `type nul > users.d/users.xml` и указываем профиль readonly и пользователей default и analyst
  - `<ip>::/0</ip>` означает, что пользователь может заходить с любого ip
  - default - пользователь с админскими правами доступа
  - analyst - пользователь с правами на чтение
```
<clickhouse>
    <profiles>
        <readonly>
            <readonly>1</readonly>
        </readonly>
    </profiles>

    <users>
        <analyst>
            <password></password>
            <profile>readonly</profile>
            <networks>
                <ip>::/0</ip>
            </networks>
        </analyst>

        <default>
            <networks>
                <ip>::/0</ip>
            </networks>
        </default>
    </users>
</clickhouse>
```
- Запускаем докер `docker compose up -d`
- Подключаемся за default пользователя `docker exec -it clickhouse clickhouse-client -u default`
- Исполняем запросы `SELECT version(); CREATE DATABASE lab; SHOW DATABASES;`. Ожидаем показ версии, успешное создание таблицы
- Выходим через Ctrl + D
- Подключаемся за аналитика `docker exec -it clickhouse clickhouse-client -u analyst`
- Исполняем запросы `SELECT version(); CREATE DATABASE test_readonly;`. Ожидаем показ версии и ошибку при создании таблицы.
### Часть 2. Проектирование схемы — плоская денормализованная таблица
#### Почему нет JOIN-ов на лету
Что происходит во время JOIN:
- Читаются все таблицы
- Строится хеш-таблица для JOIN
- Ищутся совпадения по ключам
- Собирается временная широкая таблица
- И только после происходит фильтрация/агрегация
Это дорого, так как затрачивается дополнительные ресурсы:
- CPU для сравнения ключей, построения хеш-таблицы
- RAM для хранения правой таблицы JOIN
- I/O для чтения нескольких таблиц вместо одной
- Network если в кластере данные лежат на разных шардах
- Время, т к JOIN выполняется каждый раз заново
КликХаус используется для чтения миллиона строк
#### Почему избыточность данных компенсируется сжатием
Когда идут повторяющиеся значения, Кликхаус их сжимает посредством назначения им чисел. Из [bed, bed, door] -> [1, 1, 2]. Числа легче хранить, + они ещё сжимаются по LZ4/ZSTD.
#### LowCardinality заменяет справочные таблицы
Как из предыдущего пункта, значениям присваивается число
#### Таблицы
- Подкючиться к default пользователю `docker exec -it clickhouse clickhouse-client -u default`
- Переключиться на созданную бд `USE lab;`
- Выполнить запросы на создание таблиц
  - MergeTree() - базовый движок ClickHouse, хранит данные кусками, сортирует их по ORDER BY, умеет быстро читать нужные диапазоны
  - TTL добавляет данным свойство изменения состояния спустя время (удаление или переезд)
  - SummingMergeTree - движок для агрегатов, при слиянии строк складывает числовые поля, если совпадает ключ ORDER BY
```
CREATE TABLE orders_flat (
    order_date       Date,
    order_datetime   DateTime,
    order_id         UInt64,
    customer_id      UInt64,
    customer_name    String,
    customer_email   LowCardinality(String),
    region           LowCardinality(String),
    product_id       UInt64,
    product_name     String,
    category         LowCardinality(String),
    quantity         UInt32,
    price            Decimal(12,2),
    line_total       Decimal(12,2),
    order_status     LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_date)
ORDER BY (category, toStartOfHour(order_datetime), order_status);
```
```
CREATE TABLE orders_ttl (
    order_date       Date,
    order_datetime   DateTime,
    order_id         UInt64,
    customer_id      UInt64,
    customer_name    String,
    customer_email   LowCardinality(String),
    region           LowCardinality(String),
    product_id       UInt64,
    product_name     String,
    category         LowCardinality(String),
    quantity         UInt32,
    price            Decimal(12,2),
    line_total       Decimal(12,2),
    order_status     LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_date)
ORDER BY (category, toStartOfHour(order_datetime), order_status)
TTL order_date + INTERVAL 90 DAY DELETE;
```
```
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
```
### Часть 3. Загрузка данных
Скрипт [insert_orders.sql](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/sql/insert_orders.sql) сделан по аналогии со скриптом из первой лабы. Структура из 1000000 строк, с помощью которой рандомно сгенерированы данные. Что здесь было дополнительно - это перевод в нужный формат.
- Создаем скрипт локально в папке контейнера
- Копируем скрипт с компьютера в контейнер `docker cp insert_orders.sql clickhouse:/insert_orders.sql`
- Запускаем `docker exec -it clickhouse clickhouse-client -d lab --queries-file /insert_orders.sql`
- Заходим в кликхаус и проверяем `docker exec -it clickhouse clickhouse-client -u default` -> `USE lab;` -> `SELECT count() FROM orders_flat;`. Ожидаем 1000000
### Часть 4. Те же бизнес-запросы, другой движок
Все квери [здесь](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/sql/05_queries.sql).
Для последнего сравнения, скопируем данные из `orders_flat` в `monthly_sales`:
```
INSERT INTO monthly_sales
SELECT
    toStartOfMonth(order_date) AS month,
    category,
    region,
    sum(line_total) AS revenue,
    sum(quantity) AS quantity
FROM orders_flat
GROUP BY month, category, region;
```
- Топ 10 - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/top10.txt), 0.307 sec
- Ежемесячная динамика - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/monthly.txt), 6.657 sec
- Процентиль p95/p99 - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/procentil.txt), 0.303 sec
- Поиск клиента - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/sort1.txt), 0.035 sec
- Сравнение результата
  - orders_flat - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/comparison1st.txt), 0.662 sec
  - monthly_sales - [выход](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/comparison2nd.txt), 0.015 sec
### Часть 5. Демонстрация TTL
- Внесём старые строки
```
INSERT INTO orders_ttl
SELECT
    toDate('2025-01-01') AS order_date,
    toDateTime('2025-01-01 12:00:00') AS order_datetime,
    number + 1 AS order_id,
    1000 + number AS customer_id,
    concat('Old Customer ', toString(number)) AS customer_name,
    concat('old', toString(number), '@mail.com') AS customer_email,
    'EU' AS region,
    10000 + number AS product_id,
    concat('Old Product ', toString(number)) AS product_name,
    'Electronics' AS category,
    1 AS quantity,
    toDecimal64(100, 2) AS price,
    toDecimal64(100, 2) AS line_total,
    'paid' AS order_status
FROM numbers(1000);
```
- Выполняем `SELECT * FROM orders_ttl`. Получаем
Ok.
0 rows in set. Elapsed: 0.003 sec.
- То есть устаревшие строки сразу удалились при вставке -> `OPTIMIZE TABLE orders_ttl FINAL` не необходим для отображения удаления. [Здесь](https://github.com/danilaercegovac/Data-Base-2026/blob/main/2nd%20LAB/checks/system%20parts.txt) отображена история устаревания данных
### Часть 6. Системные таблицы и сжатие
- Повторяющиеся значения в одной колонке эффективне сжимаются, так как они приравниваются к одному числовому значению.
- LowCardinality дополнительно заменяет строки числовыми кодами. 
- ORDER BY улучшает сжатие, так как физически группирует похожие строки рядом.
### Часть 7. Сравнение с PostgreSQL
| Запрос / Операция | PostgreSQL (3NF) | ClickHouse (flat) | Вывод |
|-------------------|------------------|--------------------|-------|
| Вставка 1 строки | 0.959 мс | 0.919 мс | PostgreSQL лучше для одиночных вставок |
| Топ-10 товаров (1M строк) | 1.377 мс | 0.307 мс | ClickHouse быстрее для аналитики |
| JOIN 4 таблиц | 0.479 мс | не нужен | В ClickHouse данные уже денормализованы |
| Обновление статуса | 2.792 мс | не поддерживается нативно | PostgreSQL лучше для частых UPDATE |
| Размер на диске (1M строк) | (Не сохранилась информация) MB | 56.15 MB | ClickHouse лучше сжимает данные |
| Поиск по подстроке | 0.192 | 4.30 | Оба варианта не идеальны без спец. индексов |

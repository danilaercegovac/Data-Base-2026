# 1 лабораторная работа 
## Описание работы
### Часть 1. ClickHouse Keeper / ZooKeeper
- *Docker Desktop установлен*
- Устанавливаем образ ClickHouse: docker pull clickhouse/clickhouse-server
  - Если возникла проблема при загрузке, может помочь docker system prune - очистит неиспользуемые файлы (осторожно)
- Создаем директорию mkdir clickhouse-lab -> cd clickhouse-lab
- Создаём пустой конфигурационный файл докера type nul > docker-compose.yml
- Создаём директории для конфигов кипера и проверок mkdir keeper -> mkdir checks
- Открываем .yml через notepad docker-compose.yml и указываем описание сервисов-киперов
```services:
  keeper1:
    image: clickhouse/clickhouse-server:latest
    container_name: keeper1
    hostname: keeper1
    command: clickhouse-keeper --config-file=/etc/clickhouse-keeper/keeper.xml
    volumes:
      - ./keeper/keeper1.xml:/etc/clickhouse-keeper/keeper.xml
      - keeper1-data:/var/lib/clickhouse
    ports:
      - "9181:9181"

  keeper2:
    image: clickhouse/clickhouse-server:latest
    container_name: keeper2
    hostname: keeper2
    command: clickhouse-keeper --config-file=/etc/clickhouse-keeper/keeper.xml
    volumes:
      - ./keeper/keeper2.xml:/etc/clickhouse-keeper/keeper.xml
      - keeper2-data:/var/lib/clickhouse
    ports:
      - "9182:9181"

  keeper3:
    image: clickhouse/clickhouse-server:latest
    container_name: keeper3
    hostname: keeper3
    command: clickhouse-keeper --config-file=/etc/clickhouse-keeper/keeper.xml
    volumes:
      - ./keeper/keeper3.xml:/etc/clickhouse-keeper/keeper.xml
      - keeper3-data:/var/lib/clickhouse
    ports:
      - "9183:9181"

volumes:
  keeper1-data:
  keeper2-data:
  keeper3-data:
```
- Создаём конфиг для keeper1.xml
```<clickhouse>
    <keeper_server>
        <tcp_port>9181</tcp_port>
        <server_id>1</server_id>

        <log_storage_path>/var/lib/clickhouse/coordination/log</log_storage_path>
        <snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>

        <coordination_settings>
            <operation_timeout_ms>10000</operation_timeout_ms>
            <session_timeout_ms>30000</session_timeout_ms>
            <raft_logs_level>information</raft_logs_level>
        </coordination_settings>

        <raft_configuration>
            <server>
                <id>1</id>
                <hostname>keeper1</hostname>
                <port>9234</port>
            </server>
            <server>
                <id>2</id>
                <hostname>keeper2</hostname>
                <port>9234</port>
            </server>
            <server>
                <id>3</id>
                <hostname>keeper3</hostname>
                <port>9234</port>
            </server>
        </raft_configuration>
    </keeper_server>
</clickhouse>
```
- Копируем конфиг 1го кипера для 2го и 3го через
  - copy keeper\keeper1.xml keeper\keeper2.xml
  - copy keeper\keeper1.xml keeper\keeper3.xml
- Открываем 2ой и 3ий кипер через notepad keeper\keeper2.xml и меняет значение <server_id></server_id> на 2, 3
- Запускаем докер docker compose up -d
  - Проверяем живой ли контейнер docker ps, должны быть указаны 1-3 киперы
  - Проверяем работоспособность распределённого Keeper-кластера, то есть что кворум образовался, а именно что киперы договорились кто из них лидер, а кто последователь, они работают сообща
    - Отвечает ли Kepper как сервис docker exec -i keeper1 bash -c "echo ruok | nc localhost 9181". Ожидаем imok
    - Проверяем роль каждого через docker exec -i keeper1 bash -c "echo mntr | nc localhost 9181". Ожидаем, что у двух в zk_server_state будет follower, а у одного leader
      - [mntr keeper1]()
      - [mntr keeper2]()
      - [mntr keeper3]()

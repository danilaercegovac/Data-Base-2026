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
      - ./data:/var/lib/clickhouse
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

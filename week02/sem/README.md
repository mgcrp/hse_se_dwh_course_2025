## Семинар 2. Репликация, S3, Hadoop.

### Демо 0 - Логическая репликация

1. На master

```sql
create table public.test_table_1 (
    id int,
    value text
);
```

```sql
create publication pub_test_table_1
for table public.test_table_1;
```

2. На replica

```sql
create table public.test_table_1 (
    id int,
    value text
);
```

```sql
create subscription sub_test_table_1
connection 'host=postgres_master dbname=postgres user=postgres password=postgres'
publication pub_test_table_1;
```

3. Проверяем

```sql
insert into public.test_table_1 (id, value) values (1, 'lol'), (2, 'kek'); 

select * from public.test_table_1;
```

### Демо 1 - Ручная настройка бинарной репликации

1. Надо пропатчить конфиги
    - pg_hba.conf - сетевой конфиг базы; разрешим подключения с любых внешних хостов к любой БД на сервере под любым юзером с авторизацией по паролю (шифр scram-sha-256);
    ```yaml
    host    all             all             all                     scram-sha-256
    ```
    - postgresql.conf - настройки СУБД;
    ```bash
    #------------------------------------------------------------------------------
    # WRITE-AHEAD LOG
    #------------------------------------------------------------------------------
    # - Settings -
    wal_level = logical
    #------------------------------------------------------------------------------
    # REPLICATION
    #------------------------------------------------------------------------------
    # - Sending Servers -
    max_wal_senders = 2
    max_replication_slots = 2
    # - Standby Servers -
    hot_standby = on
    hot_standby_feedback = on
    ```
    тут:
        - **wal_level** указывает, сколько информации записывается в WAL (журнал операций, который используется для репликации).
        Значение `replica` указывает на необходимость записывать только данные для поддержки архивирования WAL и репликации.
        Значение `logical` дает возможность поднять полную логическую реплику, которая может заменить мастер в случае его падения;
        - **max_wal_senders** — количество планируемых слейвов; 
        - **max_replication_slots** — максимальное число слотов репликации; 
        - **hot_standby** — определяет, можно или нет подключаться к postgresql для выполнения запросов в процессе восстановления; 
        - **hot_standby_feedback** — определяет, будет или нет сервер replica сообщать мастеру о запросах, которые он выполняет.
    
2. Подложим новые конфиги в БД. Мы уже умеем так делать через docker volumes:
```yaml
volumes:
    - ./init-script/config/pg_hba.conf:/etc/postgresql/pg_hba.conf
    - ./init-script/config/postgres.conf:/etc/postgresql/postgresql.conf
```
3. Сделаем конфиг репликации для слейва:
    - postgresql.auto.conf
    ```yaml
    primary_conninfo='host=postgres_master port=5432 user=replicator password=my_replicator_password'
    primary_slot_name='replication_slot_1'
    ```
4. Запускаем master и консоль
`docker-compose up -d postgres_master`
`docker exec -it postgres_master bash`
5. Создаем пользователя под репликацию на мастере
```bash
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'my_replicator_password';
    SELECT * FROM pg_create_physical_replication_slot('replication_slot_1');
EOSQL
```
6. Создаем бэкап мастера, из которого мы поднимем replica. Важно - к data-replica мы уже пробросили volume, значит он у нас появится на хосте, а потом мы сможем замаунтить на него replica;
```bash
pg_basebackup -D /var/lib/postgresql/data-replica -S replication_slot_1 -X stream -P -U replicator -Fp -R
```
7. Заменяем сетевой конфиг мастера и добавляем конфиг подключения к слоту репликации на слейве:
```bash
cp /etc/postgresql/init-script/replica-config/* /var/lib/postgresql/data-replica
cp /etc/postgresql/init-script/common-config/pg_hba.conf /var/lib/postgresql/data
```
8. Рестартим мастер
`docker-compose restart postgres_master`
9. Поднимаем replica
`docker-compose up -d postgres_replica`
10. Проверяем
```sql
/* на master */
select * from pg_stat_replication;

/* на replica */
select * from pg_stat_wal_receiver;
```

### Демо 2 - Все то же самое, только автоматизированное

```bash
sh docker-init.sh
```

### Демо 3 - HA (High Availability)

Добавляем
- pg_bouncer - connection poller
- HAProxy - proxy
- patroni - переключатель мастера при смерти хоста
- etcd - система конфигурации

Запуск
```bash
docker-compose up -d
```

Топология кластера
```bash
docker exec -it pg-patroni-1 patronictl -c /patroni.yml list
```

### Демо 4 - minio

1. Запустить minio - `docker-compose up -d`
2. Запустить среду и ноутбук - `cd env && sh env_setup.sh`
3. См. `minio_demo.ipynb`

### Демо 5 - hadoop

Ниже - примеры для локального запуска

1. `docker-compose up -d`
Важно: дальше очень долго!
2. `docker cp archive.zip namenode:archive.zip`
3. `docker cp breweries.csv namenode:breweries.csv`
4. `docker exec -it namenode bash`
5. `hdfs dfsadmin -safemode leave`
6. `hdfs dfs -mkdir -p /data/sem_example`
7. `hdfs dfs -ls /data`
8. `hdfs dfs -put archive.zip /data/sem_example/archive.zip`
9. `hdfs fsck /data/sem_example`
10. `hdfs dfs -put breweries.csv /data/sem_example/breweries.csv`

1. `docker exec -it spark-master bash`
2. `/spark/bin/pyspark --master spark://spark-master:7077`
3. `spark`
4. `df = spark.read.csv('hdfs://namenode:9000/data/sem_example/breweries.csv')`
5. `df.show()`
6. Spark
```python
from pyspark.sql import SparkSession


spark = SparkSession.builder.getOrCreate()

df = spark.read \
    .option('header', 'true') \
    .csv('hdfs://namenode:9000/data/sem_example/breweries.csv')

df.groupby('state') \
    .count() \
    .repartition(1) \
    .write \
    .mode('overwrite') \
    .option('header', 'true') \
    .csv('hdfs://namenode:9000/data/sem_example/breweries_groupby_pySpark.csv')
```
7. MapReduce
```bash
docker cp mapper.py namenode:mapper.py
docker cp reducer.py namenode:reducer.py
docker cp pg4300.txt namenode:pg4300.txt
docker cp pg5000.txt namenode:pg5000.txt
```

```bash
hadoop jar /opt/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar \
-file mapper.py     -mapper mapper.py \
-file reducer.py    -reducer reducer.py \
-input /data/text/* -output /data/text-output
```

Ниже - примеры для yandex cloud dataproc

1. `hdfs dfs -mkdir -p /data/sem_example`
2. `hdfs dfs -ls /data`
3. `hdfs dfs -put archive.zip /data/sem_example/archive.zip`
4. `hdfs dfs -ls /data/sem_example`
5. `hdfs fsck /data/sem_example`
6. `hdfs dfs -put breweries.csv /data/sem_example/breweries.csv`
7. `hdfs dfs -ls /data/sem_example`
8. `hdfs fsck /data/sem_example`
9. `/usr/bin/pyspark`
10. 
```python
df = spark \
    .read \
    .option('header', 'true') \
    .csv('hdfs://rc1d-dataproc-m-n1j4m8fiuosjs7rb.mdb.yandexcloud.net:8020/data/sem_example/breweries.csv')
```
11.
```python
df.groupby('state') \
    .count() \
    .repartition(1) \
    .write \
    .mode('overwrite') \
    .option('header', 'true') \
    .csv('hdfs://rc1d-dataproc-m-n1j4m8fiuosjs7rb.mdb.yandexcloud.net:8020/data/sem_example/breweries_groupby_pySpark.csv')
```
12.
```python
spark.read.option('header', 'true').csv('hdfs://rc1d-dataproc-m-n1j4m8fiuosjs7rb.mdb.yandexcloud.net:8020/data/sem_example/breweries_groupby_pySpark.csv').show()
```
13. `hdfs dfs -mkdir -p /data/text`
14. `hdfs dfs -put pg4300.txt /data/text/pg4300.txt`
15. `hdfs dfs -put pg5000.txt /data/text/pg5000.txt`
16. `hdfs dfs -ls /data/text`
17. 
```bash
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming-3.2.2.jar \
-file mapper.py     -mapper mapper.py \
-file reducer.py    -reducer reducer.py \
-input /data/text/* -output /data/text-output
```
18.
```python
df = spark.read.csv('hdfs://rc1d-dataproc-m-n1j4m8fiuosjs7rb.mdb.yandexcloud.net:8020/data/text-output', sep='\t')

df.sort(df._c1, ascending=False).show()
```
### План семинара

#### 1 - Advanced AirFlow pipelines

1) Активируем БД (используем базу из вашей первой ДЗ)<br>
`sh demo_db/docker-init.sh`

2) Активируем Airflow<br>
`cd demo_airflow && docker-compose up -d`

3) Добавим connection в AirFlow<br>
Тип подключения - PostgreSQL<br>
host: `host.docker.internal`<br>
port: `5432`<br>
user: `postgres`<br>
pass: `***`<br>
db: `postgres`<br>

4) Давайте напишем простой DAG с sqlOperator<br>
demo_airflow/dags/dag_demoSql.py<br>
Список параметров, которые мы можем подставлять через Jinja в AirFlow https://airflow.apache.org/docs/apache-airflow/stable/templates-ref.html

5) DAG с sqlSensor <br>
demo_airflow/dags/dag_demoSqlSensor.py

6) DAG с pythonOperator<br>
    - Кладем токен в секреты<br>
        host: `https://api.telegram.org/bot`<br>
        user: `hse_dwh_course_bot`<br>
        pass: `***`
    - demo_airflow/dags/dag_demoPython.py

7) DAG с OnFailureCallback<br>
demo_airflow/dags/dag_demoOnFailureCallback.py

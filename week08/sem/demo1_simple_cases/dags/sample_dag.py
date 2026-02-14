import os
from time import sleep
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator


DEFAULT_ARGS = {
    'owner': 'mgcrp',
    'depends_on_past': False,
    'start_date': datetime(2023, 10, 20),
    'email': None,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=7),
    'execution_timeout': timedelta(minutes=120)
}

def run():
    print('Hello')
    sleep(5)
    print('Bye!')


with DAG("mgcrp_sample_dag",
         default_args=DEFAULT_ARGS,
         catchup=False,
         schedule_interval="*/5 * * * *",
         max_active_runs=1,
         concurrency=1) as dag:
    
    a = DummyOperator(task_id="task_a", dag=dag)
    b = DummyOperator(task_id="task_b", dag=dag)
    d = PythonOperator(task_id="task_d", dag=dag, python_callable=run)
    c = DummyOperator(task_id="task_c", dag=dag)

    [a, b, d] >> c
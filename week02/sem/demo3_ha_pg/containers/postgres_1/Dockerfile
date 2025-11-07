FROM postgres:13.7
RUN apt-get update && apt-get -y install python3 python3-pip postgresql-plpython3-13 \
	&& rm -rf /var/lib/apt/lists/*

RUN pip3 install wheel

COPY ./requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

RUN chmod 700 /var/lib/postgresql/data

COPY ./patroni.yml /patroni.yml
ENTRYPOINT ["patroni", "patroni.yml"]

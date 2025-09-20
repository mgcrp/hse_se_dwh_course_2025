## Семинар 1. Поднимаем OLTP для сервиса в Docker.

### Пререквизиты для прохождения курса

#### 0 - git

git - распределённая система управления версиями.<br>
Мы будем использовать репозитории для сдачи домашних работ.<br>
Если вы еще не знакомы с git:
- Ищем на YouTube любой git tutorial на 10 минут
- Проходим любой курс по git (например [этот](https://stepik.org/course/125248))

В качестве remote репозитория мы будем использовать [GitHub](https://github.com).<br>
Если у вас все еще по какой-то причине нет аккаунта там - самое время завести.

Для взаимодействия с репозиторием нам потребуется git-клиент.<br>
Можно использовать [консольный клиент](https://git-scm.com/downloads) - это похвально и при должной сноровке максимально бытро и удобно.<br>
Я со своей стороны рекомендую [GitHub Desktop](https://desktop.github.com/download/) - удобный desktop клиент, в котором все делается одной кнопкой в уютном UI.

Когда вы будете делать ДЗ, вам потребуется делать каждое ДЗ в своей ветке, и после проверки при желании вы сможете вмержить его в мастер.

#### 1 - Docker

Docker - ПО для автоматизации развёртывания и управления приложениями в средах с поддержкой контейнеризации, контейнеризатор приложений.<br>
Для запуска контейнеров с приложениями вам потребуется либо пакет ПО Docker с консольным клиентом, либо [Docker Desktop](https://docs.docker.com/desktop/).

#### 2 - IDE для БД

- Самое удобное, если на вас не наложены санкции - [JetBrains DataGrip](https://www.jetbrains.com/ru-ru/datagrip/)
- OpenSource IDE, но сильно менее удобная и с сильно менее удобным UI/Shortcut'ами - [DBeaver](https://dbeaver.io)
- Консольная - psql (устанавливается вместе с postgresql, на Mac можно поставить через `brew install postgresql`)
- Оптимально красиво и удобно - [DBCode](https://dbcode.io) как дополнение для VSCode

### Демо 0 - Запускаем контейнер с PostgreSQL из консоли

```bash
docker run --rm --name postgres_1 -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:latest
```

Здесь:
- `--rm` - удалить docker volume (виртуальный диск контейнера) и сам контейнер после остановки
- `--name` - кастомное имя контейнера
- `-e` - переменные окружения в контейнере; в нашем случае POSTGRES_PASSWORD - пароль от superuser в контейнере с PostgreSQL (без этого контейнер не запустится)
- `-p` - маппинг портов; левый 5432 на нашем компьютере (его можно изменить на любой другой свободный) на 5432 на контейнере
- `-d` - detach; работать в фоне
- `postgres:latest` - имя образа в [Docker Hub](https://hub.docker.com), хралилище готовых контейнеров; `postgres` - имя образа, `latest` - версия образа, так называемый tag

Для подключения:
```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

Здесь:
- `-h` - хост
- `-p` - порт
- `-U` - имя пользователя
- `-d` - название базы данных

### Демо 1 - Самый простой голый PostgreSQL.

Для такого сценария достаточно максимально просто конфига:
```yaml
version: "3"
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: "postgres"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

Здесь:
- version - версия docker-compose
- services - название сети (группы контейнеров) в docker-compose
- postgres - название контейнера

Далее идут настройки приложения:
- image - образ приложения (локальный или из docker hub), тут - официальный контейнер PostgreSQL 13.
- environment - значения переменных среды внутри контейнера
- volumes - mount директорий с хост машины на контейнер<br>
В данном случае директория `./data` на нашей ОС, маунтится на `/var/lib/postgresql/data` внутри контейнера. Это значит, что файлы и их изменения будут синхронизовываться, а при старте пустого контейнера в него будут добавлены соотвествущие  файлы с хоста.
**Тут важно заметить** - если при старте контейнера в папке pgdata будет лежать сконфигурированная база, то новая проинициализирована не будет, а база поднимется из состояния, которое лежит в pgdata.
- ports - соответствие портов на хосте и на контейнере. В данном случае обращение по порту 5432 к хосту будет транслировано на порт 5432 контейнера.

Прямое указание конфига в базе можно заменить на указание конфига в .env файле.
Тогда это будет выглядеть следующим образом:

`docker-compose.yml`:<br>
```yaml
version: "3"
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      PGDATA: ${PGDATA}
    volumes:
      - ./data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

`.env`:<br>
```bash
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
PGDATA=/var/lib/postgresql/data/pgdata
```

Так делать правильнее, потому что при запуске в промышленной среде у средств контроля контейнеров (например, k8s) будет возможность пробрасывать секреты через конфиги, а не через явное указание их в коде.

### Демо 2 - Добавляем первичную инициализацию базы из SQL / данных.

```yaml
version: "3"
services:
  postgres:
    image: postgres:latest
    environment:
      POSTGRES_DB: "postgres"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
```

В этом конфиге мы добавили 2 вещи:
1. Положили в директорию, которая маунтится на PGDATA, файл data.csv; теперь он появится в контейнере, и мы сможем использовать его внутри него;
2. Положили в `/docker-entrypoint-initdb.d/createdb.sql` файл с инициализацией нашей БД; На самом деле, таких файлов может быть сколько угодно, а PostgreSQL просто при инициализации БД выполнит их все в алфавитном порядке;

В примере показано, как создать таблицы в новой БД и как наполнить их файлами;
В целом, в БД можно выполнить любые операции в SQL-синтаксисе:
- создание ролей
- создание БД/таблиц/view/триггеров
- insert данных

### Чтобы выполнить это у себя

1. Заходим в директорию `demo*`
2. `docker-compose build`
3. `docker-compose up`
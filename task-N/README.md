# Task 1

### Команды для запуска

- sudo docker compose up -d --build (сборка контейнеров)
- sudo docker compose ud -d (запуск)
- sudo docker compose stop (остановка работы контейнеров)
- sudo docker compose down (остановка и удаление контейнеров)
- sudo docker compose down -v (остановка и удаление контейнеров, вместе с томами)

### Эксперименты

1. sudo docker compose up -d --build
   [+] Building 26.2s (11/11) FINISHED docker:default
   => [web internal] load build definition from Dockerfile 0.0s
   => => transferring dockerfile: 199B 0.0s
   => [web internal] load metadata for docker.io/library/python:3.12-slim 0.0s
   => [web internal] load .dockerignore 0.3s
   => => transferring context: 128B 0.0s
   => [web 1/5] FROM docker.io/library/python:3.12-slim 0.1s
   => [web internal] load build context 0.1s
   => => transferring context: 408B 0.0s
   => [web 2/5] WORKDIR /app 0.2s
   => [web 3/5] COPY requirements.txt . 0.0s
   => [web 4/5] RUN pip install --no-cache-dir -r requirements.txt 25.2s
   => [web 5/5] COPY . . 0.1s
   => [web] exporting to image 0.1s
   => => exporting layers 0.1s
   => => writing image sha256:7d92cd5f506655846f11e89b15646f9bd01ec1e9f7c128477033612a7853b41e 0.0s
   => => naming to docker.io/library/task1-web 0.0s
   => [web] resolving provenance for metadata file 0.0s
   [+] Running 5/5
   ✔ web Built 0.0s
   ✔ Network task1_default Created 0.2s
   ✔ Volume "task1_redis_data" Created 0.0s
   ✔ Container task1-redis-1 Started 0.3s
   ✔ Container task1-web-1 Started

2. sudo docker compose ps
   NAME IMAGE COMMAND SERVICE CREATED STATUS PORTS
   task1-redis-1 redis:7-alpine "docker-entrypoint.s…" redis About a minute ago Up About a minute 6379/tcp
   task1-web-1 task1-web "python app.py" web About a minute ago Up About a minute 0.0.0.0:8000->8000/tcp, :::8000->8000/tcp

При открытии https://localhost:8000 возрастает счетчик, при обновловлении страницы счетсчик растет, если страницу закрыть и открыть заново то счетчик не обнуляется и продолжает расти.

3. sudo docker compose logs -f web
   \\web-1 | _ Serving Flask app 'app'
   web-1 | _ Debug mode: off
   web-1 | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
   web-1 | _ Running on all addresses (0.0.0.0)
   web-1 | _ Running on http://127.0.0.1:8000
   web-1 | \* Running on http://172.18.0.3:8000
   web-1 | Press CTRL+C to quit
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:53] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:53] "GET /favicon.ico HTTP/1.1" 404 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:57] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:05:57] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:06:03] "GET / HTTP/1.1" 200 -
   web-1 | 172.18.0.1 - - [26/Nov/2026 09:06:03] "GET / HTTP/1.1" 200 -

4. sudo docker compose exec redis redis-cli get visits
   "8"

5. sudo docker compose restart redis
   [+] Restarting 1/1
   ✔ Container task1-redis-1 Started  
   Счетчик = 8
   Растартуется сервис редис, но том не рестартуется, поэтому после рестарта Redis подключается к существующему тому redis_data
6. docker compose down && docker compose up -d — счётчик не сбросился.
   docker compose down -v && docker compose up -d — счётчик сбросился. Объяснить в README, почему.
   - docker compose down - команда останавливает работу и удаляет контейнер и виртуальную сеть, но не трогает values.
     При запуске, создается новый контейнер Redis. Он подключается к уже существующему тому redis_data, считывает сохраненный файл и продолжает счет
   - docker compose down -v - флаг -v указывает на удаление томов перечисленных в values, вместе с контейнерами.
     При новом запуске, создается новый том redis_data. поэтому Redis стартует с чистого листа и счетчик равен 1.

### Вопросы для самопроверки

1. Почему web достучался до redis по имени redis? Какая сеть создалась автоматически и кто в неё попал?

- Это произашло благодаря встроенному DNS-сурверу Docker.
- Когда код в web обращается к хосту redis, запрос уходит во внутренний DNS Docker, который находит актуальный внутренний IP-адрес контейнера task1-redis-1 (например, 172.18.0.2) и направляет трафик туда.
- Даже если контейнер Redis перезапустится и получит новый внутренний IP-адрес, имя redis продолжит работать без изменения настроек.
- Docker compose создает автоматически сеть типа bridge с именем по шаблону <имя_папки>\_default
- В сеть попадают все контейнеры, описанные в секции services из compose.yml. Все остальные контейнеры не попадают в эту сеть.

2. Что именно гарантирует depends_on, а что — нет?

- depend_on гарантирует ожидание загрузки сервиса, но не его запуска.

3. Чем отличаются stop, down и down -v? Что происходит с контейнерами, сетью и volume в каждом случае?\

- stop - контейнеры останавливают работу. Сеть/NamedVolumes/Images все сохраняется
- down - контейнеры останавливают работу и удаляются. Сеть удаляется, NamedVolumes/Images сохраняются
- down -v - контейнеры останавливают работу и удаляются. Суть удаляется, NamedVolumes удаляются навсегда. Images сохраняются, если не был указан флаг --rmi

# Task 1

### Команды для запуска и управления

- `sudo docker compose up -d --build` — сборка образов и запуск контейнеров в фоновом режиме
- `sudo docker compose up -d` — запуск контейнеров без пересборки
- `sudo docker compose ps` - проверка состояния контейнеров
- `sudo docker compose stop` — остановка работы контейнеров
- `sudo docker compose down` — остановка и удаление контейнеров и сети
- `sudo docker compose down -v` — остановка и удаление контейнеров, сети и томов (volumes)

---

### Эксперименты

#### 1. Сборка и запуск проекта

```bash
sudo docker compose up -d --build
```

Вывод терминала:

```text
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
```

#### 2. Проверка статуса контейнеров

```bash
sudo docker compose ps
```

Вывод терминала:

```text
NAME            IMAGE            COMMAND                  SERVICE   CREATED              STATUS              PORTS
task1-redis-1   redis:7-alpine   "docker-entrypoint.s…"   redis     About a minute ago   Up About a minute   6379/tcp
task1-web-1     task1-web        "python app.py"          web       About a minute ago   Up About a minute   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp
```

При открытии `http://localhost:8000` отображается счётчик посещений. При обновлении страницы счётчик растёт; если закрыть вкладку и открыть заново, счётчик не обнуляется и продолжает расти.

#### 3. Просмотр логов сервиса `web`

```bash
sudo docker compose logs -f web
```

Вывод терминала:

```text
web-1  |  * Serving Flask app 'app'
web-1  |  * Debug mode: off
web-1  | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
web-1  |  * Running on all addresses (0.0.0.0)
web-1  |  * Running on http://127.0.0.1:8000
web-1  |  * Running on http://172.18.0.3:8000
web-1  | Press CTRL+C to quit
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:53] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:53] "GET /favicon.ico HTTP/1.1" 404 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:56] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:57] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:05:57] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:06:03] "GET / HTTP/1.1" 200 -
web-1  | 172.18.0.1 - - [26/Nov/2026 09:06:03] "GET / HTTP/1.1" 200 -
```

#### 4. Проверка значения в Redis напрямую

```bash
sudo docker compose exec redis redis-cli get visits
```

Результат:

```text
"8"
```

#### 5. Перезапуск контейнера Redis

```bash
sudo docker compose restart redis
```

Вывод терминала:

```text
[+] Restarting 1/1
 ✔ Container task1-redis-1 Started
```

**Результат:** Счётчик остаётся равен `8`. Перезапускается только сам контейнер сервиса `redis`, но named volume не удаляется, поэтому после рестарта Redis снова подключается к существующему тому `redis_data`.

#### 6. Проверка сохранности данных при `down` и `down -v`

- **`docker compose down && docker compose up -d` (счётчик не сбросился):**  
  Команда `down` останавливает и удаляет контейнеры и виртуальную сеть, но **не трогает volumes**. При новом запуске создаётся новый контейнер Redis, который подключается к уже существующему тому `redis_data`, считывает сохранённый AOF-файл и продолжает счёт.
- **`docker compose down -v && docker compose up -d` (счётчик сбросился):**  
  Флаг `-v` указывает на удаление томов, объявленных в секции `volumes`, вместе с контейнерами. При новом запуске создаётся новый пустой том `redis_data`, поэтому Redis стартует с чистого листа и счётчик начинается заново с `1`.

---

### Вопросы для самопроверки

**1. Почему `web` достучался до `redis` по имени `redis`? Какая сеть создалась автоматически и кто в неё попал?**

- Это произошло благодаря встроенному DNS-серверу Docker (`127.0.0.11`).
- Когда код в `web` обращается к хосту `redis`, запрос уходит во внутренний DNS Docker, который находит актуальный внутренний IP-адрес контейнера `task1-redis-1` (например, `172.18.0.2`) и направляет трафик туда.
- Даже если контейнер Redis перезапустится и получит новый IP-адрес, обращение по имени `redis` продолжит работать без изменения настроек.
- Docker Compose автоматически создаёт изолированную сеть типа `bridge` с именем по шаблону `<имя_папки>_default` (в нашем случае `task1_default`).
- В эту сеть попадают только контейнеры, описанные в секции `services` файла `compose.yaml` (`task1-web-1` и `task1-redis-1`). Остальные контейнеры на хосте в неё не попадают.

**2. Что именно гарантирует `depends_on`, а что — нет?**

- `depends_on` (в базовой форме) гарантирует только порядок **запуска контейнеров** (контейнер `redis` будет запущен раньше контейнера `web`).
- Он **не гарантирует**, что приложение внутри контейнера `redis` уже полностью инициализировалось и готово принимать подключения к моменту старта `web` (для этого дополнительно настраивают `healthcheck` с условием `condition: service_healthy`).

**3. Чем отличаются `stop`, `down` и `down -v`? Что происходит с контейнерами, сетью и volume в каждом случае?**

- **`stop`** — контейнеры останавливают работу (остаются в системе в статусе `Exited`). Сеть, named volumes и образы сохраняются.
- **`down`** — контейнеры останавливаются и удаляются; автоматически созданная сеть удаляется; named volumes и образы сохраняются.
- **`down -v`** — контейнеры останавливаются и удаляются; сеть удаляется; named volumes удаляются навсегда вместе со всеми данными. Образы сохраняются (если не указан флаг `--rmi`).

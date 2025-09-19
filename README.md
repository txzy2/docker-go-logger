# Logger Go - Docker Stack

Docker-контейнеризованное приложение для логирования с использованием Go, PostgreSQL, Nginx и Adminer.

## Архитектура

Стек состоит из следующих сервисов:

- **logv2_app** - Go приложение (исключено из документации)
- **logv2_db** - PostgreSQL база данных
- **logv2_web** - Nginx веб-сервер (прокси)
- **logv2_adm** - Adminer для управления БД

## Структура проекта

```
logger_go/
├── docker-compose.yml          # Основная конфигурация Docker Compose
├── docker-compose.dev.yml      # Конфигурация для разработки
├── Makefile                    # Команды для управления контейнерами
├── nginx/                      # Конфигурация Nginx
│   ├── conf.d/
│   │   └── default.conf        # Основная конфигурация Nginx
│   └── logs/                   # Логи Nginx
├── pgsql/                      # Конфигурация PostgreSQL
│   ├── Dockerfile              # Dockerfile для PostgreSQL
│   └── create-multiple-postgresql-databases.sh  # Скрипт создания БД
├── dbdata/                     # Данные PostgreSQL (том)
└── app/                        # Go приложение (исключено из документации)
```

## Требования

- Docker
- Docker Compose
- Make (опционально, для удобства)

## Переменные окружения

Создайте файл `.env` в корне проекта со следующими переменными:

```env
# PostgreSQL
DB_VERSION_PG_SQL=14
DB_NAME=your_database_name
DB_USER=your_username
DB_PASS=your_password

# Nginx
NGINX_PORT=8080

# Adminer
ADMINER_VERSION=adminer:latest
ADMINER_PORT=8081
```

## Быстрый старт

### 1. Клонирование и настройка

```bash
git clone <repository-url>
cd logger_go
cp .env.example .env  # Настройте переменные окружения
```

### 2. Запуск стека

```bash
# Запуск всех сервисов
docker-compose up -d

# Или с пересборкой
docker-compose up -d --build
```

### 3. Проверка статуса

```bash
docker-compose ps
```

## Управление через Makefile

Для удобства управления контейнерами используйте команды Make:

```bash
# Остановка всех контейнеров
make dd-dev

# Перезапуск с пересборкой
make dbr-dev

# Просмотр статуса контейнеров
make dps-dev

# Просмотр логов
make dlogs-dev                    # Логи приложения
make dlogs-dev CONTAINER=logv2_db # Логи конкретного контейнера
make dlogs-all                    # Логи всех контейнеров

# Перезапуск контейнера
make drestart CONTAINER=logv2_app

# Статус контейнеров
make dstatus
```

## Сервисы

### PostgreSQL (logv2_db)

- **Порт**: Внутренний (доступен через сеть Docker)
- **Версия**: PostgreSQL 14
- **Данные**: Сохраняются в `./dbdata/`
- **Инициализация**: Автоматическое создание БД при первом запуске

### Nginx (logv2_web)

- **Порт**: 8080 (настраивается через `NGINX_PORT`)
- **Функции**:
  - Проксирование запросов на Go приложение
  - Логирование доступа и ошибок
  - Поддержка WebSocket соединений
  - Ограничение размера загружаемых файлов (10MB)

### Adminer (logv2_adm)

- **Порт**: 8081 (настраивается через `ADMINER_PORT`)
- **Функции**: Веб-интерфейс для управления PostgreSQL

## Сеть

Все сервисы работают в изолированной Docker сети `log_net_v2` с драйвером `bridge`.

## Логи

- **Nginx логи**: `./nginx/logs/`
- **Docker логи**: `docker-compose logs <service_name>`

## Разработка

### Hot Reload

Приложение настроено на hot reload - изменения в коде автоматически перезагружают контейнер.

### Отладка

```bash
# Подключение к контейнеру приложения
docker exec -it logv2_app /bin/bash

# Подключение к PostgreSQL
docker exec -it logv2_db psql -U your_username -d your_database

# Просмотр логов в реальном времени
docker-compose logs -f logv2_app
```

## Производственное развертывание

1. Настройте переменные окружения для продакшена
2. Используйте `docker-compose.yml` вместо `docker-compose.dev.yml`
3. Настройте SSL сертификаты в Nginx (раскомментируйте HTTPS порт)
4. Настройте резервное копирование данных PostgreSQL

## Безопасность

- Доступ к скрытым файлам заблокирован в Nginx
- База данных доступна только внутри Docker сети
- Adminer доступен только на внутреннем порту

## Мониторинг

```bash
# Использование ресурсов
docker stats

# Логи всех сервисов
docker-compose logs

# Статус контейнеров
docker-compose ps
```

## Устранение неполадок

### Контейнер не запускается

```bash
# Проверьте логи
docker-compose logs <service_name>

# Проверьте конфигурацию
docker-compose config
```

### Проблемы с базой данных

```bash
# Проверьте подключение
docker exec -it logv2_db psql -U your_username -d your_database

# Пересоздайте том данных (ВНИМАНИЕ: данные будут потеряны)
docker-compose down -v
docker-compose up -d
```

### Проблемы с сетью

```bash
# Проверьте сеть
docker network ls
docker network inspect logger_go_log_net_v2
```

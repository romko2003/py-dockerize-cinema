FROM python:3.10.8-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Системні пакунки, потрібні для psycopg2-binary/Pillow/HTTPS
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libjpeg62-turbo-dev \
      zlib1g-dev \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Встановлюємо залежності
# (якщо в тебе інший файл — підстав актуальну назву)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо увесь проєкт
COPY . .

# Порт API
EXPOSE 8000

# Запуск через gunicorn (оновлення БД/статик - у docker-compose команді)
CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]

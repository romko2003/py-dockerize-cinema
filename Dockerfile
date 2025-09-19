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

# Залежності
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Код
COPY . .

# Нерутовий користувач + права на каталоги для статик/медіа
RUN useradd -m appuser \
 && mkdir -p /vol/web/static /vol/web/media \
 && chown -R appuser:appuser /vol
USER appuser

EXPOSE 8000

CMD ["gunicorn", "cinema_service.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]

import time
from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError

class Command(BaseCommand):
    help = "Wait for database to be available"

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING("Waiting for database..."))
        db_conn = None
        retries = 0
        while not db_conn:
            try:
                db_conn = connections['default']
                db_conn.cursor()  # відкриття курсора перевіряє доступність
            except OperationalError:
                retries += 1
                self.stdout.write(f"DB unavailable, retry {retries}... sleep 1s")
                time.sleep(1)
            else:
                break
        self.stdout.write(self.style.SUCCESS("Database is available!"))

import os
import time
from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError


class Command(BaseCommand):
    help_text = "Wait for database to be available"

    def handle(self, *args, **options):
        max_retries = int(os.getenv("DB_WAIT_MAX_RETRIES", "60"))
        delay = float(os.getenv("DB_WAIT_DELAY", "1"))

        self.stdout.write(self.style.WARNING("Waiting for database..."))
        conn = None
        retries = 0

        while not conn and retries < max_retries:
            try:
                conn = connections["default"]
                conn.cursor()
            except OperationalError as exc:
                retries += 1
                self.stdout.write(f"DB unavailable ({exc}), retry {retries}; sleep {delay}s")
                time.sleep(delay)
            else:
                break

        if not conn:
            self.stderr.write(self.style.ERROR("Database is not available after retries"))
            raise SystemExit(1)

        self.stdout.write(self.style.SUCCESS("Database is available!"))

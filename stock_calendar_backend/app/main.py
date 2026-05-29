from datetime import datetime, timezone

from fastapi import FastAPI

from app.config import settings

app = FastAPI(title=settings.service_name)


@app.get("/api/v1/health")
def health():
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    return {"status": "ok", "now": now}

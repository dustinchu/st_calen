from fastapi.testclient import TestClient

from app.main import app


def test_health_returns_ok():
    client = TestClient(app)
    r = client.get("/api/v1/health")

    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    assert "now" in body
    # spec: `now` is a UTC ISO-8601 timestamp, e.g. "2026-05-28T01:23:45Z"
    assert body["now"].endswith("Z")

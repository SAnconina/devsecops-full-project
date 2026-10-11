from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_returns_success():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {
        "message": "DevSecOps Platform is running",
        "status": "ok",
    }


def test_health_returns_healthy():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
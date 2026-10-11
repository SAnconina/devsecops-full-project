from fastapi import FastAPI

app = FastAPI(
    title="DevSecOps Platform",
    description="A secure API built with DevSecOps practices",
    version="0.1.0",
)


@app.get("/")
def root():
    return {
        "message": "DevSecOps Platform is running",
        "status": "ok",
    }


@app.get("/health")
def health():
    return {"status": "healthy"}

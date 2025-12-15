# Dockerfile
FROM python:3.12-slim

RUN useradd -m appuser

WORKDIR /app

COPY simpletimeservice.py .

USER appuser

EXPOSE 8080
CMD ["python", "simpletimeservice.py"]

FROM python:3.13-slim

RUN useradd --create-home appuser

WORKDIR /app

COPY app.py requirements.txt /app/

RUN mkdir -p /app/templates /app/static
COPY templates/ /app/templates/ || echo "No templates folder, skipping"
COPY static/ /app/static/ || echo "No static folder, skipping"

RUN pip install --no-cache-dir -r requirements.txt

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
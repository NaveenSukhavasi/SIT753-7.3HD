FROM python:3.11-slim

RUN useradd --create-home appuser

WORKDIR /app

COPY app.py requirements.txt /app/
RUN mkdir -p /app/templates /app/static
COPY templates/ /app/templates/
COPY static/ /app/static/

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
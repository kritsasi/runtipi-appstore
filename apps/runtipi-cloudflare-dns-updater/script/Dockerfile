FROM python:3.12-alpine

RUN pip install --no-cache-dir docker requests

COPY dns_updater.py /dns_updater.py

CMD ["python", "/dns_updater.py"]

FROM python:3.13-slim AS build

WORKDIR /build

COPY . .
RUN pip install --no-cache-dir .

FROM python:3.13-slim

RUN groupadd -r app && useradd -r -g app -u 1000 app

WORKDIR /app

COPY --from=build /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /build /app

ENV UPLOADS_DIR=/uploads

RUN mkdir -p /uploads && chown app:app /uploads

EXPOSE 4000

USER app

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "4000"]

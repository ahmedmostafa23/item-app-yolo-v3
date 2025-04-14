FROM python:3.10

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml pyproject.toml
COPY .python-version .python-version
COPY uv.lock uv.lock

RUN uv sync

COPY . .

EXPOSE 8000

ENTRYPOINT [ "uv", "run", "uvicorn", "app:app", "--port", "8000", "--host", "0.0.0.0" ]

CMD [ "--workers", "2" ]

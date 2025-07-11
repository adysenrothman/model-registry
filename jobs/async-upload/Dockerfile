###############################################################################
#  Asynchronous Model-Sync Job image for Kubeflow Model Registry (https://github.com/kubeflow/model-registry/issues/1108)
###############################################################################

FROM python:3.10-slim AS base

# security/env hardening
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=2.1.3 \
    POETRY_HOME="/opt/poetry" \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Create an unprivileged user
RUN addgroup --system --gid 1000 app \
    && adduser  --system --uid 1000 --ingroup app --home /app app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl build-essential libffi-dev libssl-dev skopeo \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="$POETRY_HOME/bin:$PATH"


WORKDIR /app

# Copy Python dependencies first to leverage layer caching
COPY ./poetry.lock ./pyproject.toml ./

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/pypoetry \
    poetry config virtualenvs.create false \
    && poetry install --no-root --no-ansi


# Copy application source
COPY . .

# Switch to the non-root user for the final image layer
USER 1000:1000

# Add an explicit health-check (K8s will surface this in Pod.status)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -m job.healthcheck

# OCI-recommended labels
ARG VCS_REF=unknown
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.title="Kubeflow Model Registry Async-Upload Job" \
    org.opencontainers.image.description="K8s Job image that copies a model between storage back-ends and registers it in Kubeflow Model Registry." \
    org.opencontainers.image.url="https://github.com/kubeflow/model-registry" \
    org.opencontainers.image.source="https://github.com/kubeflow/model-registry/tree/main/jobs/async-upload" \
    org.opencontainers.image.version="0.1.0" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.authors="Kubeflow Model Registry maintainers"

# The Job controller will pass CLI flags/ENV-vars described in issue #1108.
ENTRYPOINT ["python", "-m", "job.entrypoint"]

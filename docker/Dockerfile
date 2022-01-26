# build stage
FROM python:3.10-slim-bullseye AS builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get -y install netcat gcc make \
    && apt-get clean

# install PDM
RUN pip install -U pip setuptools wheel pdm

# copy files
COPY pyproject.toml pdm.lock README.md /project/
COPY alvis/ /project/alvis

# install dependencies and project
WORKDIR /project
RUN ["pdm", "install", "--prod", "--no-lock", "--no-editable"]


# run stage
FROM python:3.10-slim-bullseye AS prod

# retrieve packages from build stage
ENV PYTHONPATH=/project/pkgs
COPY --from=builder /project/__pypackages__/3.10/lib /project/pkgs

ENTRYPOINT ["python", "-m", "alvis"]

FROM build as test
COPY tests /app/tests
RUN ["pdm", "install", "--prod", "-G", "testing"]
ENTRYPOINT ["pdm", "run", "pytest", "-c", "pyproject.toml"]

########
# Base #
########

FROM docker.io/library/python:3.10-alpine AS base

WORKDIR /app

ENV PIP_NO_CACHE_DIR True

RUN pip3 install --no-cache-dir pipenv \
  && find /usr -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

RUN apk add --no-cache git tini

COPY Pipfile.lock Pipfile ./

ENTRYPOINT [ "/sbin/tini", "--" ]

CMD [ "mkdocs", "serve", "--livereload", "--verbose", "--watch-theme" ]

#######
# App #
#######

FROM base AS dev

RUN pipenv install --dev --system --deploy --ignore-pipfile \
  && find /usr -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

#######
# App #
#######

FROM base AS app

RUN pipenv install --system --deploy --ignore-pipfile \
  && find /usr -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

COPY src .

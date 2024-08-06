FROM python:3.10-alpine

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV HEADLESS=1

# To install pgconfig, required for PostgreSQL database engine
#https://stackoverflow.com/questions/46711990/error-pg-config-executable-not-found-when-installing-psycopg2-on-alpine-in-dock
RUN apk update && \
 apk add postgresql-libs && \
 apk add --virtual .build-deps build-base musl-dev postgresql-dev libffi-dev python3-dev cargo

RUN apk update
RUN apk add --no-cache curl gnupg git
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --import -
RUN echo "http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apk/repositories
RUN apk add --no-cache chromium chromium-chromedriver

# python deps
RUN pip install --upgrade pip

FROM python:3.8.5-slim 

RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

WORKDIR /code
COPY test-server.py /code
RUN chown -R www-data:www-data /code/

CMD [ "python", "-u", "test-server.py" ]
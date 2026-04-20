FROM mongo:7.0-jammy

COPY ./mongofiles /docker-entrypoint-initdb.d/

USER mongodb

EXPOSE 27017

FROM mongo:7.0-jammy    

COPY ./mongofiles /docker-entrypoint-initdb.d/

EXPOSE 27017

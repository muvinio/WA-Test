FROM nginx:1.25-alpine

RUN apk add --no-cache openssl gettext && \
    rm /etc/nginx/conf.d/default.conf

COPY nginx.conf.template /etc/nginx/nginx.conf.template

COPY ./src /usr/share/nginx/html

EXPOSE 80 443

CMD ["/bin/sh", "-c", "\
    mkdir -p /etc/letsencrypt/live/${ENV_SERVER_NAME} && \
    if [ ! -f /etc/letsencrypt/live/${ENV_SERVER_NAME}/fullchain.pem ]; then \
        openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
        -keyout /etc/letsencrypt/live/${ENV_SERVER_NAME}/privkey.pem \
        -out /etc/letsencrypt/live/${ENV_SERVER_NAME}/fullchain.pem \
        -subj '/C=US/ST=State/L=City/O=Organization/CN='${ENV_SERVER_NAME} && \
        chmod -R 777 /etc/letsencrypt; \
    fi; \
    envsubst '$ENV_SERVER_NAME' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf && \
    exec nginx -g 'daemon off;'"]
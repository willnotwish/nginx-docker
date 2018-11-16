FROM nginx:alpine

RUN apk update && \
    apk add bash openssl curl inotify-tools && \
    rm -rf /var/cache/apk/*

# monitor.sh looks to see if a reload/restart is requested. Called by entrypoint.sh
COPY entrypoint.sh monitor.sh /tmp/
RUN chmod +x /tmp/entrypoint.sh /tmp/monitor.sh

COPY conf /etc/nginx/

WORKDIR /var/www

RUN mkdir -p ssl html \
  /monitor            \
  /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/certs

ENV SSL_ROOT=/var/www/ssl

# sites-available/sites-enabled follow the Ubuntu convention
VOLUME ["/etc/nginx/sites-available", "/etc/nginx/sites-enabled", "/monitor", "/etc/nginx/certs", "/var/www/ssl/params"]

ENTRYPOINT ["/tmp/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]

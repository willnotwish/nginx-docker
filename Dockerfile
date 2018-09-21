FROM nginx:alpine

# We need bash & openssl
RUN apk update && apk add bash openssl curl && \
    rm -rf /var/cache/apk/*

ENV SSL_ROOT /var/www/ssl
ENV SSL_CERT_HOME $SSL_ROOT/certs/live

# Include the script that is needed by CMD, below
COPY cmd.sh /tmp/
RUN chmod +x /tmp/cmd.sh

WORKDIR /var/www
RUN mkdir ssl members members/log members/html public public/log public/html

# Copy Nginx config files
COPY nginx.default.conf nginx.public.conf nginx.members.conf /tmp/

# Substitute variable references in the Nginx config template for real values from the environment.
# Put the final config in its place
RUN envsubst '$SSL_ROOT:$SSL_CERT_HOME:$BASE_DOMAIN' < /tmp/nginx.default.conf > /etc/nginx/conf.d/default.conf && \
    envsubst '$SSL_ROOT:$SSL_CERT_HOME:$BASE_DOMAIN' < /tmp/nginx.public.conf  > /etc/nginx/conf.d/public.conf && \
    envsubst '$SSL_ROOT:$SSL_CERT_HOME:$BASE_DOMAIN' < /tmp/nginx.members.conf > /etc/nginx/conf.d/members.conf

# Define the script we want to run once the container starts
CMD [ "/tmp/cmd.sh" ]

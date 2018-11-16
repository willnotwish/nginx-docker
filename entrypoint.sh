#!/usr/bin/env bash

SSL_PARAMS_DIR=$SSL_ROOT/params

echo "entrypoint.sh. SSL_PARAMS_DIR is $SSL_PARAMS_DIR"

if [ ! -r "$SSL_PARAMS_DIR/dhparam.pem" ]; then
  echo "Creating SSL params directory $SSL_PARAMS_DIR"
  mkdir -p $SSL_PARAMS_DIR
  openssl dhparam -out $SSL_PARAMS_DIR/dhparam.pem 2048
fi

echo "Running monitor.sh in the background"
/tmp/monitor.sh &

echo "About to run: $@"
exec "$@"
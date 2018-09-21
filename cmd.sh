#!/usr/bin/env bash

# initialize the dehydrated environment
setup_dehydrated() {

  # create the directory that will serve ACME challenges
  mkdir -p .well-known/acme-challenge
  chmod -R 755 .well-known

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/domains_txt.md
  echo "$BASE_DOMAIN www.$BASE_DOMAIN members.$BASE_DOMAIN" > domains.txt

  # # We want a wildcard certificate
  # echo "$BASE_DOMAIN *.$BASE_DOMAIN" > domains.txt

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/staging.md
  # echo "CA=\"https://acme-staging.api.letsencrypt.org/directory\"" > config
  echo "CA=\"$CA_ENDPOINT\"" > config

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/wellknown.md
  echo "WELLKNOWN=\"$SSL_ROOT/.well-known/acme-challenge\"" >> config

  # The license we are agreeing to
  echo "LICENSE=\"https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf\"" >> config

  # # The challenge type: we need dns-01 to verify wildcard domains
  # echo "CHALLENGETYPE=\"dns-01\"" >> config
  # echo "HOOK=\"${SSL_ROOT}/hooks.sh\"" >> config
  # echo "CONTACT_EMAIL=\"nadams@dsc.net\"" >> config

  # Fetch the dehydrated script itself
  curl "https://raw.githubusercontent.com/lukas2511/dehydrated/v0.6.2/dehydrated" > dehydrated

  chmod 755 dehydrated
}

# creates self-signed SSL files
# these files are used in development and get production up and running so letsencrypt.sh can do its work
create_pems() {
  openssl req -x509 -nodes -days 730 -newkey rsa:1024 -keyout privkey.pem -out fullchain.pem -subj "/C=GB/ST=Warwickshire/L=Warwick/O=NAS/OU=Engineering/CN=$BASE_DOMAIN"
  openssl dhparam -out dhparam.pem 2048
  chmod 600 *.pem
}

# if we have not already done so initialize Docker volume to hold SSL files
if [ ! -d "$SSL_CERT_HOME" ]; then
  mkdir -p $SSL_CERT_HOME
  chmod 755 $SSL_ROOT
  chmod -R 700 $SSL_ROOT/certs
  cd $SSL_CERT_HOME
  create_pems
  cd $SSL_ROOT
  setup_dehydrated
fi

# if we are configured to run SSL with a real certificate authority run letsencrypt.sh to retrieve/renew SSL certs
if [ "$CA_SSL" = "true" ]; then

  # Nginx must be running for challenges to proceed
  # run in daemon mode so our script can continue
  nginx

  # retrieve/renew SSL certs
  ./dehydrated --cron --accept-terms

  # copy the fresh certs to where Nginx expects to find them
  cp $SSL_ROOT/certs/$BASE_DOMAIN/fullchain.pem $SSL_ROOT/certs/$BASE_DOMAIN/privkey.pem $SSL_CERT_HOME

  # pull Nginx out of daemon mode
  nginx -s stop
fi

# start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"
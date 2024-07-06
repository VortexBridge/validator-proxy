#!/bin/sh

echo "Starting validator proxy with the following validators: $VALIDATORS"

# split the validators variable into a list
VALIDATORS_LIST=$(echo $VALIDATORS | tr ',' '\n')

# generate the upstream block for nginx to insert into the template config
UPSTREAM_BLOCK=""
for validator in $VALIDATORS_LIST; do
    UPSTREAM_BLOCK="${UPSTREAM_BLOCK}server $validator;\n"
done

# if cert doesn't exist, use the nossl template so certbot can verify
if [ ! -f /etc/letsencrypt/live/proxy.vortexbridge.io/fullchain.pem ]; then
    echo "No SSL certificate found, using the nossl template for certbot verification"
    cp /etc/nginx/nginx.nossl.conf.template /etc/nginx/nginx.conf
else
    echo "SSL certificate found, using the ssl template"
    # generate the nginx.conf file from the template and edit the upstream block to include the validators
    cat /etc/nginx/nginx.conf.template | sed "s|# UPSTREAM_SERVERS|${UPSTREAM_BLOCK}|" > /etc/nginx/nginx.conf
fi

nginx -g 'daemon off;'
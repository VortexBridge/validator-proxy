#!/bin/sh

echo "Starting validator proxy with the following validators: $VALIDATORS"

# split the validators variable into a list
VALIDATORS_LIST=$(echo $VALIDATORS | tr ',' '\n')

# generate the upstream block for nginx to insert into the template config
UPSTREAM_BLOCK=""
for validator in $VALIDATORS_LIST; do
    UPSTREAM_BLOCK="${UPSTREAM_BLOCK}server $validator;\n"
done

# generate the nginx.conf file from the template
cat /etc/nginx/nginx.conf.template | sed "s|# UPSTREAM_SERVERS|${UPSTREAM_BLOCK}|" > /etc/nginx/nginx.conf

nginx -g 'daemon off;'
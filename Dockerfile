FROM nginx:1.27.0

RUN apt-get update && apt-get install -y gettext-base

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY nginx.nossl.conf.template /etc/nginx/nginx.nossl.conf.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
EXPOSE 443

CMD ["/entrypoint.sh"]
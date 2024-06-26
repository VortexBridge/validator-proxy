FROM nginx:1.27.0

RUN apt-get update && apt-get install -y gettext-base

COPY nginx.conf.template /etc/nginx/nginx.conf.template

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]
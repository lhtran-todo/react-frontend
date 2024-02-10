FROM node:alpine as builder
WORKDIR /app
COPY ./app/package.json .
COPY ./app/yarn.lock .
RUN yarn
COPY ./app .
RUN yarn build

FROM nginx:alpine
ENV RUNTIME_ENABLE_BACKEND_PROXY=false \
    PORT=80

COPY scripts /env-config
RUN chmod +x /env-config/*.sh

RUN rm -rf /etc/nginx/conf.d
COPY nginx /etc/nginx

COPY --from=builder /app/build /usr/share/nginx/html

CMD ["/bin/sh", "-c", "/env-config/config-nginx.sh '/etc/nginx/conf.d/default.conf' && /env-config/load-env.sh '/usr/share/nginx/html/env-config.js' && nginx -g \"daemon off;\""]
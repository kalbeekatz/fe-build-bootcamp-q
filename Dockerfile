# まずは node で build する
FROM node:16-slim AS build

WORKDIR /build
COPY . .
RUN npm ci
RUN npm run build

# FROM が来たら別の世界(image) → マルチステージビルド
FROM nginx:latest

COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

# nginx は debian 系なので apt コマンドが使える
RUN apt-get update -y \
&& apt-get install -yq apache2-utils
RUN htpasswd -b -c /etc/nginx/.htpasswd user pass

# build から引っ張ってくる
COPY --from=build /build/dist/ /var/www/html/

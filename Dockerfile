FROM nginx:1.15

ARG location=/

COPY public/ /usr/share/nginx/html${LOCATION}
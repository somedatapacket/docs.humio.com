FROM openjdk:11 AS REDIRECTS
COPY public /var/docs/public
COPY ConvertRedirects.java /var/docs/
WORKDIR /var/docs
RUN java ConvertRedirects.java > default.rewrites

FROM nginx:1.17
COPY nginx-conf.d/* /etc/nginx/conf.d/
COPY --from=REDIRECTS /var/docs/default.rewrites /etc/nginx/conf.d/
COPY public/ /usr/share/nginx/html

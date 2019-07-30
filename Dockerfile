FROM alpine:latest AS DATA
RUN apk add curl
ENV HUMIO_RELEASE=1.5.22
WORKDIR /var/docs
RUN mkdir -p /var/docs/data && \
    curl -fs https://repo.humio.com/repository/maven-releases/com/humio/server/${HUMIO_RELEASE}/server-${HUMIO_RELEASE}.releases.yml > data/releases.yml && \
    curl -fs https://repo.humio.com/repository/maven-releases/com/humio/docs/queryfunctions/${HUMIO_RELEASE}/queryfunctions-${HUMIO_RELEASE}.json > data/functions.json && \
    curl -fs https://repo.humio.com/repository/maven-releases/com/humio/docs/metrics/${HUMIO_RELEASE}/metrics-${HUMIO_RELEASE}.json > data/metrics.json

FROM alpine:latest AS STATIC
RUN apk add zip
WORKDIR /var/docs
COPY artefacts /var/docs/artefacts
RUN mkdir -p /var/docs/static/zeek-files && \
    cd artefacts && zip -r ../static/zeek-files/corelight-dashboards.zip corelight-dashboards

FROM alpine:latest AS HUGO
RUN apk add git
ENV HUGO_VERSION=0.55.6
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/hugo.tar.gz
RUN tar xvzf /tmp/hugo.tar.gz hugo -C /usr/local/bin
COPY config.toml /var/docs/
COPY layouts /var/docs/layouts
COPY static  /var/docs/static
COPY themes  /var/docs/themes
COPY data    /var/docs/data
COPY content /var/docs/content
COPY .git /var/docs/.git
COPY --from=DATA   /var/docs/data   /var/docs/data
COPY --from=STATIC /var/docs/static /var/docs/static
WORKDIR /var/docs
RUN hugo

FROM openjdk:11 AS REDIRECTS
COPY --from=HUGO /var/docs/public /var/docs/public
COPY src/* /var/docs/
WORKDIR /var/docs
RUN java ConvertRedirects.java > default.rewrites

FROM nginx:1.17
COPY nginx-conf.d/* /etc/nginx/conf.d/
COPY --from=REDIRECTS /var/docs/default.rewrites /etc/nginx/conf.d/
COPY --from=HUGO /var/docs/public /usr/share/nginx/html

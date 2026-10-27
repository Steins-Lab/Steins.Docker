# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG VERSION=development
LABEL org.opencontainers.image.title="Stenins-Onebot" \
      org.opencontainers.image.description="Linux QQ bot with OneBot v11" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/Steins-Lab/Stenins.Docker"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 stenins \
    && useradd --uid 10001 --gid 10001 --no-create-home --home-dir /data --shell /usr/sbin/nologin stenins \
    && install -d -o stenins -g stenins -m 0700 /data

# CI supplies the already-tested Linux binary. No source code is copied.
COPY --chmod=0755 dist/Stenins-Onebot /opt/stenins/Stenins-Onebot
COPY dist/NOTICE.md dist/config.example.yml /opt/stenins/
COPY dist/licenses/ /opt/stenins/licenses/

ENV TZ=Asia/Shanghai
WORKDIR /data
USER 10001:10001
VOLUME ["/data"]
EXPOSE 8080
STOPSIGNAL SIGTERM
ENTRYPOINT ["/opt/stenins/Stenins-Onebot"]

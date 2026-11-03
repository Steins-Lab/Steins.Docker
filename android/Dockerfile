# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG VERSION=development
LABEL org.opencontainers.image.title="Steins-Android" \
      org.opencontainers.image.description="Android QQ bot with OneBot v11" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/Steins-Lab/Steins.Docker"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates tzdata ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 steins \
    && useradd --uid 10001 --gid 10001 --no-create-home --home-dir /data --shell /usr/sbin/nologin steins \
    && install -d -o steins -g steins -m 0700 /data

# Only the tested executable and notices enter this context; source stays private.
COPY --chmod=0755 dist/Steins-Android /opt/steins/Steins-Android
COPY dist/config.example.yml /opt/steins/
COPY dist/licenses/ /opt/steins/licenses/

ENV TZ=Asia/Shanghai
WORKDIR /data
USER 10001:10001
VOLUME ["/data"]
EXPOSE 5700
STOPSIGNAL SIGTERM
ENTRYPOINT ["/opt/steins/Steins-Android"]

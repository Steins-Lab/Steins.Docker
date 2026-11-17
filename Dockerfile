# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ARG VERSION=development
LABEL org.opencontainers.image.title="Steins-Onebot" \
      org.opencontainers.image.description="Linux QQ bot with OneBot v11" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/Steins-Lab/Steins.Docker"

# Use an independent Ubuntu mirror when Canonical's archive DNS is unavailable.
# Ubuntu archive signatures remain enforced by apt.
RUN sed -i -E 's#https?://([[:alnum:]-]+\.)?(archive|security)\.ubuntu\.com#http://mirrors.edge.kernel.org#g' /etc/apt/sources.list \
    && apt-get -o Acquire::Retries=3 -o APT::Update::Error-Mode=any update \
    && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=3 install -y --no-install-recommends ca-certificates tzdata ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 steins \
    && useradd --uid 10001 --gid 10001 --no-create-home --home-dir /data --shell /usr/sbin/nologin steins \
    && install -d -o steins -g steins -m 0700 /data

# CI supplies the already-tested Linux binary. No source code is copied.
COPY --chmod=0755 dist/Steins-Onebot /opt/steins/Steins-Onebot
COPY dist/NOTICE.md dist/config.example.yml /opt/steins/
COPY dist/licenses/ /opt/steins/licenses/
COPY --chmod=0755 scripts/docker-entrypoint.sh /usr/local/bin/steins-entrypoint

ENV TZ=Asia/Shanghai
WORKDIR /data
VOLUME ["/data"]
EXPOSE 8080
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/steins-entrypoint"]

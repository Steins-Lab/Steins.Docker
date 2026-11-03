# Steins-Onebot · [Steins-Android](android/README.md)

## Docker CLI

```bash
docker pull ghcr.io/steins-lab/steins-onebot:latest
sudo install -d -m 0700 -o 10001 -g 10001 data
docker run --rm -it \
  -v "$PWD/data:/data" \
  ghcr.io/steins-lab/steins-onebot:latest
sudo vi data/config.yml
```

```bash
docker run -dit \
  --name steins-onebot \
  --restart unless-stopped \
  --init \
  -v "$PWD/data:/data" \
  ghcr.io/steins-lab/steins-onebot:latest
docker logs -f steins-onebot
```

## compose.yml

```yaml
services:
  bot:
    image: ghcr.io/steins-lab/steins-onebot:latest
    pull_policy: never
    platform: linux/amd64
    container_name: steins-onebot
    restart: unless-stopped
    init: true
    stdin_open: true
    tty: true
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./data:/data
    # Only needed for OneBot HTTP API / forward WebSocket.
    # Set onebot.listen.host to 0.0.0.0 inside the container first.
    # ports:
    #   - "127.0.0.1:8080:8080"
```

## 启动

```bash
sudo install -d -m 0700 -o 10001 -g 10001 data
docker compose pull
docker compose run --rm bot
sudo vi data/config.yml
docker compose up -d
docker compose logs -f bot
```

## 更新

```bash
docker compose pull
docker compose up -d
```

## 重启 / 停止

```bash
docker compose restart bot
docker compose down
```

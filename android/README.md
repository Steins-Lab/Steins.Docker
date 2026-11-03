# Steins-Android Docker

## compose.yml

```yaml
services:
  bot:
    image: ghcr.io/steins-lab/steins-android:latest
    platform: linux/amd64
    container_name: steins-android
    restart: unless-stopped
    init: true
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./data:/data
    # For HTTP API / forward WebSocket, set onebot.listen.host to 0.0.0.0.
    # ports:
    #   - "127.0.0.1:5700:5700"
```

## 启动

```bash
sudo install -d -m 0700 -o 10001 -g 10001 data
docker compose pull
docker compose run --rm bot
sudo vi data/config.yml
docker compose run --rm bot --check-config
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

## 离线镜像

```bash
curl -fsSL https://raw.githubusercontent.com/Steins-Lab/Steins.Docker/main/android/scripts/download-image.sh -o download-image.sh
bash download-image.sh latest
```

# Steins-Onebot Docker

## Docker CLI

```bash
docker pull ghcr.io/steins-lab/steins-onebot:latest
mkdir -p data
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
mkdir -p data
docker compose pull
docker compose run --rm bot
sudo vi data/config.yml
docker compose up -d
docker compose logs -f bot
```

容器启动时会将 `/data` 挂载目录及已有文件的所有者调整为 `10001:10001`，随后以该普通用户运行程序。使用 Docker 自动创建的目录或 root 所有的目录时，无需提前手动修改所有者。已有配置、设备信息和票据会保留内容及文件权限。

如果通过 `--user` 或 Compose 的 `user` 指定其他用户，则使用指定身份启动，不自动修改目录所有者；需要自行确保该用户能读写挂载目录。

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

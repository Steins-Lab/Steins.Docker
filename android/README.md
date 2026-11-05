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
      - LANG
      - LC_ALL
      - LC_MESSAGES
    volumes:
      - ./data:/data
      - /etc/localtime:/etc/localtime:ro
    # For HTTP API / forward WebSocket, set onebot.listen.host to 0.0.0.0.
    # ports:
    #   - "127.0.0.1:5700:5700"
```

## 启动

编辑 `data/config.yml` 时须填全 `account` 中的 `qq`、`password`、`login_method`、`country_code` 和 `phone`。密码登录也必须填写绑定手机号；`phone` 不含区号，区号单独填写。空账号模板不能通过 `--check-config`，检查失败时按提示补全后再启动容器。

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

机器人自动读取容器运行环境的时区和语言，不写入设备 YAML。Compose 挂载宿主 /etc/localtime 并传入 LANG、LC_ALL、LC_MESSAGES；无语言配置（C/POSIX）时使用 en-US。

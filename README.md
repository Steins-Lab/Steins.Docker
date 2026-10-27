# Steins-Onebot

## Docker CLI

Pull the image and run once to initialize. No registry login is required:

```bash
docker pull ghcr.io/steins-lab/steins-onebot:latest
sudo install -d -m 0700 -o 10001 -g 10001 data
docker run --rm -it \
  -v "$PWD/data:/data" \
  ghcr.io/steins-lab/steins-onebot:latest
```

After completing the initial setup, start the service:

```bash
docker run -dit \
  --name steins-onebot \
  --restart unless-stopped \
  --init \
  -v "$PWD/data:/data" \
  ghcr.io/steins-lab/steins-onebot:latest
docker logs -f steins-onebot
```

## Docker Compose

Install Docker Engine with the Docker Compose v2 plugin, then create an empty deployment directory. No repository clone or registry login is required.

Create `compose.yml` in that directory:

```yaml
services:
  bot:
    image: ghcr.io/steins-lab/steins-onebot:latest
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
```

Prepare the data directory, pull the image, and run once to initialize:

```bash
sudo install -d -m 0700 -o 10001 -g 10001 data
docker compose pull
docker compose run --rm bot
```

The first run initializes `./data` and exits. Complete the initial setup there, then start the service and follow the login output:

```bash
docker compose up -d
docker compose logs -f bot
```

Press `Ctrl+C` to stop following the logs; the service keeps running.

To update the image and recreate the container:

```bash
docker compose pull
docker compose up -d
```

To restart or stop the service:

```bash
docker compose restart bot
docker compose down
```

The `./data` directory is preserved when the container is recreated or stopped. If you previously started a container named `steins-onebot` with `docker run`, stop and remove that container before switching to Compose.

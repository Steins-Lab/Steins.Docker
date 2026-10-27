# Steins-Onebot

Pull the image and run once to initialize. No registry login is required:

```bash
git clone https://github.com/Steins-Lab/Steins.Docker.git
cd Steins.Docker
sudo install -d -m 0700 -o 10001 -g 10001 data
docker pull ghcr.io/steins-lab/steins-onebot:latest
docker compose run --rm bot
```

After completing the initial setup, start the service:

```bash
docker compose up -d
docker compose logs -f bot
```

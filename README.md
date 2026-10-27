# Steins-Onebot

Run once to initialize:

```bash
git clone https://github.com/Steins-Lab/Steins.Docker.git
cd Steins.Docker
sudo install -d -m 0700 -o 10001 -g 10001 data
bash scripts/download-image.sh
docker compose run --rm bot
```

After completing the initial setup, start the service:

```bash
docker compose up -d
docker compose logs -f bot
```

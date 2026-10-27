# Steins-Onebot

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

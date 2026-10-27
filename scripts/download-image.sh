#!/usr/bin/env bash
set -euo pipefail
version="${1:-latest}"
if [[ "$version" == latest ]]; then
    release_url='https://github.com/Steins-Lab/Steins.Docker/releases/latest/download'
elif [[ "$version" == edge || "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
    release_url="https://github.com/Steins-Lab/Steins.Docker/releases/download/$version"
else
    echo 'Use latest, edge, or a version such as v0.1.3.' >&2
    exit 1
fi
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT
archive='Steins-Onebot-docker-linux-amd64.tar.gz'
curl --fail --location --retry 2 "$release_url/$archive" -o "$download_dir/$archive"
curl --fail --location --retry 2 "$release_url/$archive.sha256" -o "$download_dir/$archive.sha256"
(cd "$download_dir" && sha256sum -c "$archive.sha256")
docker load -i "$download_dir/$archive"

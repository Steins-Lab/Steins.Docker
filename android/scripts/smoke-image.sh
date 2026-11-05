#!/usr/bin/env bash
set -euo pipefail
: "${IMAGE:?Set IMAGE to the local image tag}"
: "${EXPECTED_VERSION:?Set EXPECTED_VERSION to the binary build version}"

actual="$(docker run --rm "$IMAGE" --version)"
[[ "$actual" == "Steins.Android $EXPECTED_VERSION" ]]
volume="steins-android-smoke-${RANDOM}-$$"
container="steins-android-smoke-${RANDOM}-$$"
docker volume create "$volume" >/dev/null
cleanup() {
    docker rm -f "$container" >/dev/null 2>&1 || true
    docker volume rm "$volume" >/dev/null
}
trap cleanup EXIT

output="$(docker run --rm -v "$volume:/data" "$IMAGE")"
[[ "$output" == *'模板'* ]]
docker run --rm --entrypoint /bin/sh -v "$volume:/data" "$IMAGE" -ec '
  test "$(id -u)" = 10001
  test "$(stat -c %a /data/config.yml)" = 600
  test "$(ls -A /data | wc -l)" -eq 1
  test ! -d /opt/steins/internal
  test ! -f /opt/steins/go.mod
  command -v ffmpeg >/dev/null
'
set +e
output="$(docker run --rm -v "$volume:/data" "$IMAGE" 2>&1)"
status=$?
set -e
[[ "$status" -ne 0 ]]
docker run --rm --entrypoint /bin/sh -v "$volume:/data" "$IMAGE" -ec '
  test "$(ls -A /data | wc -l)" -eq 1
  cat > /data/offline.yml <<EOF
account:
  qq: 10001
  password: synthetic-offline-password
  login_method: password
  country_code: "86"
  phone: "13800000000"
onebot:
  listen:
    host: 0.0.0.0
    port: 5700
  http_api:
    enabled: true
    path: /api
    token: synthetic-image-token
EOF
'
docker run -d --name "$container" -p 127.0.0.1::5700 -v "$volume:/data" "$IMAGE" --config offline.yml --offline >/dev/null
port="$(docker port "$container" 5700/tcp)"
export STEINS_SMOKE_URL="http://$port/api/get_version_info"
python3 <<'PY'
import json,os,time,urllib.request,urllib.error
url=os.environ['STEINS_SMOKE_URL']
for attempt in range(100):
    try:
        urllib.request.urlopen(url, timeout=1)
    except urllib.error.HTTPError as error:
        assert error.code==401
        break
    except OSError:
        time.sleep(.1)
else:
    raise SystemExit('Image offline listener did not become ready')
req=urllib.request.Request(url,headers={'Authorization':'Bearer synthetic-image-token'})
with urllib.request.urlopen(req,timeout=5) as response:
    data=json.load(response)
assert data['retcode']==0 and data['data']['app_version']==os.environ['EXPECTED_VERSION']
PY
echo 'Docker version, non-root initialization, permissions, FFmpeg and authenticated offline API checks passed.'

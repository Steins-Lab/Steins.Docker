#!/usr/bin/env bash
set -euo pipefail
: "${IMAGE:?Set IMAGE to the local image tag}"
: "${EXPECTED_VERSION:?Set EXPECTED_VERSION to the binary build version}"

actual="$(docker run --rm --network none "$IMAGE" -version)"
[[ "$actual" == "Steins-Onebot $EXPECTED_VERSION" ]]
volume="steins-smoke-${RANDOM}-$$"
fixture="$(mktemp -d)"
docker volume create "$volume" >/dev/null
cleanup() {
  docker volume rm "$volume" >/dev/null
  docker run --rm --network none --user 0:0 --entrypoint /bin/sh \
    -v "$fixture:/fixture" "$IMAGE" -ec 'find /fixture -mindepth 1 -delete'
  rmdir "$fixture"
}
trap cleanup EXIT

check_first_start() {
  local mount="$1" output status
  output="$(docker run --rm --network none --mount "$mount" "$IMAGE")"
  [[ "$output" == *'程序已退出'* ]]
  docker run --rm --network none --user 10001:10001 --entrypoint /bin/sh \
    --mount "$mount" "$IMAGE" -ec '
    test "$(stat -c %u:%g /data)" = 10001:10001
    test "$(stat -c %u:%g:%a /data/config.yml)" = 10001:10001:600
    test "$(ls -A /data | wc -l)" -eq 1
    test ! -d /opt/steins/internal
    test ! -f /opt/steins/go.mod
  '
  set +e
  output="$(docker run --rm --network none --mount "$mount" "$IMAGE" 2>&1)"
  status=$?
  set -e
  [[ "$status" -ne 0 && "$output" == *'account.qq'* ]]
  docker run --rm --network none --user 10001:10001 --entrypoint /bin/sh \
    --mount "$mount" "$IMAGE" -ec 'test "$(ls -A /data | wc -l)" -eq 1'
}

check_first_start "type=volume,source=$volume,target=/data"

# Docker-created bind directories belong to root, unlike initialized volumes.
docker run --rm --network none --user 0:0 --entrypoint /bin/sh \
  -v "$fixture:/fixture" "$IMAGE" -ec '
  mkdir /fixture/data
  chown 0:0 /fixture/data
  chmod 0755 /fixture/data
'
mount="type=bind,source=$fixture/data,target=/data"
check_first_start "$mount"

# Existing private configuration, devices and tickets must survive the repair.
docker run --rm --network none --user 0:0 --entrypoint /bin/sh \
  --mount "$mount" -v "$fixture:/fixture" "$IMAGE" -ec '
  mkdir -p /data/data/linux/tickets /data/data/android
  printf "synthetic-ticket\n" > /data/data/linux/tickets/session
  printf "synthetic-device\n" > /data/data/android/device.json
  printf "outside-data\n" > /fixture/protected
  chmod 0600 /fixture/protected
  chown 0:0 /fixture/protected
  ln -s /protected /data/data/android/outside
  chmod 0600 /data/data/linux/tickets/session /data/data/android/device.json
  cd /data
  sha256sum config.yml data/linux/tickets/session data/android/device.json > expected.sha256
  chown -R 0:0 /data
  chmod 0700 /data /data/data /data/data/linux /data/data/linux/tickets /data/data/android
'
set +e
output="$(docker run --rm --network none --mount "$mount" -v "$fixture/protected:/protected" "$IMAGE" 2>&1)"
status=$?
set -e
[[ "$status" -ne 0 && "$output" == *'account.qq'* ]]
docker run --rm --network none --user 10001:10001 --entrypoint /bin/sh \
  --mount "$mount" "$IMAGE" -ec '
  cd /data
  sha256sum -c expected.sha256
  for path in config.yml data/linux/tickets/session data/android/device.json; do
    test "$(stat -c %u:%g:%a "$path")" = 10001:10001:600
  done
'
docker run --rm --network none --user 0:0 --entrypoint /bin/sh \
  -v "$fixture:/fixture" "$IMAGE" -ec 'test "$(stat -c %u:%g:%a /fixture/protected)" = 0:0:600'

# A caller-selected UID can generate configuration without root initialization.
docker run --rm --network none --user 0:0 --entrypoint /bin/sh \
  --mount "$mount" "$IMAGE" -ec 'rm /data/config.yml; chown 12345:12345 /data'
output="$(docker run --rm --network none --user 12345:12345 --mount "$mount" "$IMAGE")"
[[ "$output" == *'程序已退出'* ]]
docker run --rm --network none --user 12345:12345 --entrypoint /bin/sh \
  --mount "$mount" "$IMAGE" -ec 'test "$(stat -c %u:%g:%a /data/config.yml)" = 12345:12345:600'

echo 'Docker version, named volume, root-owned bind mount, existing state and custom-user checks passed.'

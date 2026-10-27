#!/usr/bin/env bash
set -euo pipefail
: "${IMAGE:?Set IMAGE to the local image tag}"
: "${EXPECTED_VERSION:?Set EXPECTED_VERSION to the binary build version}"

actual="$(docker run --rm "$IMAGE" -version)"
[[ "$actual" == "Stenins-Onebot $EXPECTED_VERSION" ]]
volume="stenins-smoke-${RANDOM}-$$"
docker volume create "$volume" >/dev/null
trap 'docker volume rm "$volume" >/dev/null' EXIT

output="$(docker run --rm -v "$volume:/data" "$IMAGE")"
[[ "$output" == *'程序已退出'* ]]
docker run --rm --entrypoint /bin/sh -v "$volume:/data" "$IMAGE" -ec '
  test "$(stat -c %a /data/config.yml)" = 600
  test "$(ls -A /data | wc -l)" -eq 1
  test ! -d /opt/stenins/internal
  test ! -f /opt/stenins/go.mod
'
set +e
output="$(docker run --rm -v "$volume:/data" "$IMAGE" 2>&1)"
status=$?
set -e
[[ "$status" -ne 0 && "$output" == *'account.qq'* ]]
docker run --rm --entrypoint /bin/sh -v "$volume:/data" "$IMAGE" -ec 'test "$(ls -A /data | wc -l)" -eq 1'
echo 'Docker version, configuration generation, permissions and missing-account checks passed.'

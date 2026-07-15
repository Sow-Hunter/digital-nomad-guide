#!/usr/bin/env bash
set -euo pipefail

umask 077

CONFIG="${XRAY_CONFIG:-/usr/local/etc/xray/config.json}"
TAG="${SS_INBOUND_TAG:-ss-chain}"

if (( $# > 1 )); then
  printf 'Usage: sudo %s [server-address]\n' "$0" >&2
  exit 1
fi

SERVER="${1:-}"

if [[ "$EUID" -ne 0 ]]; then
  printf 'Run as root: sudo %s [server-address]\n' "$0" >&2
  exit 1
fi

for command in jq base64 tr; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command" >&2
    exit 1
  fi
done

if [[ -z "$SERVER" ]]; then
  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to detect the instance public IP; pass the server address explicitly.\n' >&2
    exit 1
  fi

  if ! IMDS_TOKEN="$(curl -fsS --max-time 2 -X PUT \
    -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' \
    http://169.254.169.254/latest/api/token)" ||
    ! SERVER="$(curl -fsS --max-time 2 \
      -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
      http://169.254.169.254/latest/meta-data/public-ipv4)"; then
    printf 'Could not detect the instance public IP; pass it as the first argument.\n' >&2
    exit 1
  fi
fi

if [[ ! -r "$CONFIG" ]]; then
  printf 'Xray config is not readable: %s\n' "$CONFIG" >&2
  exit 1
fi

INBOUND_COUNT="$(jq --arg tag "$TAG" '[.inbounds[] | select(.tag == $tag)] | length' "$CONFIG")"
if [[ "$INBOUND_COUNT" != "1" ]]; then
  printf 'Expected exactly one Xray inbound tagged %s; found %s.\n' "$TAG" "$INBOUND_COUNT" >&2
  exit 1
fi

METHOD="$(jq -er --arg tag "$TAG" '.inbounds[] | select(.tag == $tag) | .settings.method' "$CONFIG")"
PASSWORD="$(jq -er --arg tag "$TAG" '.inbounds[] | select(.tag == $tag) | .settings.password' "$CONFIG")"
PORT="$(jq -er --arg tag "$TAG" '.inbounds[] | select(.tag == $tag) | .port' "$CONFIG")"

if [[ -z "$METHOD" || -z "$PASSWORD" ]]; then
  printf 'The %s inbound has an empty method or password.\n' "$TAG" >&2
  exit 1
fi

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  printf 'The %s inbound has an invalid port: %s\n' "$TAG" "$PORT" >&2
  exit 1
fi

if [[ "$SERVER" == *:* && "$SERVER" != \[*\] ]]; then
  SERVER="[$SERVER]"
fi

USERINFO="$(printf '%s:%s' "$METHOD" "$PASSWORD" | base64 | tr -d '\n=' | tr '+/' '-_')"

printf 'WARNING: the following URI contains the complete Shadowsocks credential.\n' >&2
printf 'Import it directly into the client; do not paste it into chat, logs, screenshots, or Git.\n' >&2
printf 'ss://%s@%s:%s#Oregon-SS-%s\n' "$USERINFO" "$SERVER" "$PORT" "$METHOD"

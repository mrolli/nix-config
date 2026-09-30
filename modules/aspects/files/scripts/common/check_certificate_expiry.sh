#!/usr/bin/env bash

print_usage() {
  >&2 echo "Usage: $(basename "$0") FQDN [PORT] [DAYS]"
}

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  print_usage
  exit 1
fi

domain=$1
port=${2:-443}
expiry_days=${3:-30}

if ! [[ $port =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
  >&2 echo "PORT must be an integer between 1 and 65535."
  exit 1
fi

if ! [[ $expiry_days =~ ^[0-9]+$ ]]; then
  >&2 echo "DAYS must be a non-negative integer."
  exit 1
fi

for command in openssl timeout; do
  if ! command -v "$command" >/dev/null 2>&1; then
    >&2 echo "Required command not found: $command"
    exit 1
  fi
done

cert=$(timeout 10 openssl s_client \
  -showcerts \
  -servername "$domain" \
  -connect "$domain:$port" \
  </dev/null 2>/dev/null)
connect_status=$?

if ((connect_status == 124)); then
  >&2 echo "Timed out connecting to $domain:$port."
  exit 2
fi

if ((connect_status != 0)) || [ -z "$cert" ]; then
  >&2 echo "Could not retrieve a certificate from $domain:$port."
  exit 2
fi

if ! enddate=$(printf '%s\n' "$cert" | openssl x509 -enddate -noout 2>/dev/null); then
  >&2 echo "Could not parse the certificate from $domain:$port."
  exit 2
fi
enddate=${enddate#notAfter=}

if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then
  red=$'\033[31m'
  green=$'\033[32m'
  reset=$'\033[0m'
else
  red=
  green=
  reset=
fi

expiry_seconds=$((expiry_days * 86400))
if printf '%s\n' "$cert" | openssl x509 -checkend "$expiry_seconds" -noout >/dev/null 2>&1; then
  printf '%sCertificate for %s expires on %s%s\n' "$green" "$domain" "$enddate" "$reset"
  exit 0
fi

printf '%sCertificate for %s expires within %s days, on %s%s\n' \
  "$red" "$domain" "$expiry_days" "$enddate" "$reset"
exit 3

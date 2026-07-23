#!/usr/bin/env bash
# Curls every known route against a running instance of the site and
# asserts 200, plus confirms a genuinely missing path 404s. Used by both
# `make check` and CI so a typo'd nav link fails the build.
set -uo pipefail

base="${1:?usage: smoke_test.sh <base-url>}"

routes=(
  /
  /servers/
  /giants/
  /doc/
  /doc/start/
  /doc/api/
  /doc/vps/
  /doc/billing/
  /doc/token/
  /policy/
  /policy/trust/
  /policy/privacy/
  /policy/aup/
  /policy/retention/
  /policy/disclosures/
  /404.html
  /assets/style.css
  /assets/nav.js
  /robots.txt
)

fail=0

for route in "${routes[@]}"; do
  code="$(curl -s -o /dev/null -w '%{http_code}' "$base$route")"
  if [ "$code" != "200" ]; then
    echo "FAIL $route -> $code"
    fail=1
  else
    echo "ok   $route -> $code"
  fi
done

code="$(curl -s -o /dev/null -w '%{http_code}' "$base/this-page-does-not-exist")"
if [ "$code" != "404" ]; then
  echo "FAIL /this-page-does-not-exist -> $code (want 404)"
  fail=1
else
  echo "ok   /this-page-does-not-exist -> 404"
fi

exit $fail

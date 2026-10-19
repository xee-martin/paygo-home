#!/usr/bin/env bash
# Requires Bash, Python 3, and cURL. Run locally; never paste SECRET into this file.
set -euo pipefail
: "${PAYGO_PID:?Set PAYGO_PID to your merchant PID}"
: "${PAYGO_ORIGIN:?Set PAYGO_ORIGIN to your allowlisted page Origin}"
: "${PAYGO_RETURN_URL:?Set PAYGO_RETURN_URL to your payment return URL}"
export PAYGO_PID PAYGO_ORIGIN PAYGO_RETURN_URL

payload="$(python3 - <<'PY'
import getpass
import hashlib
import hmac
import json
import os
import secrets
import time
from urllib.parse import quote, urlsplit

origin = urlsplit(os.environ['PAYGO_ORIGIN'])
return_url = urlsplit(os.environ['PAYGO_RETURN_URL'])
if (origin.scheme not in ('http', 'https') or not origin.netloc
        or origin.path or origin.query or origin.fragment
        or origin.username or origin.password):
    raise SystemExit('PAYGO_ORIGIN must be an http(s) Origin without a path or credentials')
if (return_url.scheme not in ('http', 'https') or not return_url.netloc
        or return_url.username or return_url.password):
    raise SystemExit('PAYGO_RETURN_URL must be an http(s) URL without credentials')
secret = getpass.getpass('PayGo SECRET (hidden, local signing only): ')
if not secret:
    raise SystemExit('SECRET must not be empty')
fields = {
    'pid': os.environ['PAYGO_PID'],
    'merchant_order_no': 'CURL-' + str(int(time.time())) + '-' + secrets.token_hex(8),
    'amount': '1.00',
    'name': 'cURL integration test',
    'type': 'alipay',
    'return_url': os.environ['PAYGO_RETURN_URL'],
    'timestamp': str(int(time.time())),
    'nonce': secrets.token_hex(16),
}
canonical = '&'.join(key + '=' + quote(fields[key], safe='-._~') for key in sorted(fields))
fields['sign'] = hmac.new(secret.encode(), canonical.encode(), hashlib.sha256).hexdigest()
print(json.dumps(fields, ensure_ascii=False))
PY
)"

printf '%s' "$payload" | curl --silent --show-error --fail-with-body \
  --connect-timeout 10 --max-time 30 \
  --request POST 'https://api.paygo2.uk/api/v1/paygo/checkout/sessions' \
  --header "Origin: $PAYGO_ORIGIN" \
  --header 'Content-Type: application/json' \
  --data-binary @-
printf '\n'

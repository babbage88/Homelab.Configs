!#/usr/bin/bash
curl 'https://infra.trahan.dev/renew' \
	-H 'accept: application/zip' \
	-H 'accept-language: en-US,en;q=0.7' \
	-H $AUTH_HEADER_FULL
-H 'content-type: application/json' \
	-H 'origin: https://infra.trahan.dev' \
	-H 'priority: u=1, i' \
	-H 'referer: https://infra.trahan.dev/swaggerui/' \
	-H 'sec-ch-ua: "Brave";v="131", "Chromium";v="131", "Not_A Brand";v="24"' \
	-H 'sec-ch-ua-mobile: ?0' \
	-H 'sec-ch-ua-platform: "Linux"' \
	-H 'sec-fetch-dest: empty' \
	-H 'sec-fetch-mode: cors' \
	-H 'sec-fetch-site: same-origin' \
	-H 'sec-gpc: 1' \
	-H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
	--data-raw $'{\n  "domainName": "*.trahan.dev",\n  "email": "justin@trahan.dev",\n  "provider": "cf",\n  "zipFiles": true\n}'

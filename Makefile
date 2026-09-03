.PHONY: docker-up docker-down setup-env

setup-env:
	@umask 077; \
	trap 'stty echo 2>/dev/null || true' EXIT INT TERM; \
	printf 'Client ID de 42: '; \
	read -r CLIENT_ID; \
	printf 'Client Secret de 42: '; \
	stty -echo; \
	read -r CLIENT_SECRET; \
	stty echo; \
	printf '\n'; \
	printf '%s\n' '# 42 API credentials' "CLIENT_ID=$$CLIENT_ID" "CLIENT_SECRET=$$CLIENT_SECRET" > .env

docker-up: setup-env
	docker compose up --build

docker-down:
	docker compose down

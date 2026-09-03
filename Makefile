.PHONY: docker-up docker-down setup-env android-studio

setup-env:
	@if [ -f .env ]; then \
		printf '%s\n' '.env ya existe; se conservaran las credenciales actuales.'; \
	else \
		umask 077; \
		trap 'stty echo 2>/dev/null || true' EXIT INT TERM; \
		printf 'Client ID de 42: '; \
		read -r CLIENT_ID; \
		printf 'Client Secret de 42: '; \
		stty -echo; \
		read -r CLIENT_SECRET; \
		stty echo; \
		printf '\n'; \
		printf '%s\n' '# 42 API credentials' "CLIENT_ID=$$CLIENT_ID" "CLIENT_SECRET=$$CLIENT_SECRET" > .env; \
	fi

docker-up: setup-env
	docker compose run --build --rm --service-ports swifty-companion

docker-down:
	docker compose down

android-studio:
	@if command -v studio >/dev/null 2>&1; then \
		studio "$(CURDIR)/app" >/dev/null 2>&1 & \
	elif command -v android-studio >/dev/null 2>&1; then \
		android-studio "$(CURDIR)/app" >/dev/null 2>&1 & \
	else \
		printf '%s\n' 'No se encontro Android Studio en el PATH.'; \
		exit 1; \
	fi

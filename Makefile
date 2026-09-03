.PHONY: docker-up docker-down setup-env setup-flutter android-studio

setup-flutter:
	@cd app && bash ../scripts/setup_flutter.sh

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
	fi; \
	cp .env app/.env; \
	chmod 600 .env app/.env

docker-up: setup-env
	docker compose up --build -d
	@i=0; \
	until curl -fsS http://localhost:8080 >/dev/null 2>&1 || [ $$i -ge 30 ]; do \
		i=$$((i + 1)); \
		sleep 2; \
	done; \
	if curl -fsS http://localhost:8080 >/dev/null 2>&1; then \
		printf '%s\n' 'Swifty Companion disponible en http://localhost:8080'; \
		if command -v xdg-open >/dev/null 2>&1; then \
			xdg-open http://localhost:8080 >/dev/null 2>&1 || true; \
		elif command -v open >/dev/null 2>&1; then \
			open http://localhost:8080 >/dev/null 2>&1 || true; \
		fi; \
	else \
		printf '%s\n' 'El servidor no respondio. Revisa los logs:'; \
		docker compose logs --tail=50 swifty-companion; \
		exit 1; \
	fi

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

.PHONY: docker-up docker-down

docker-up:
	docker compose up --build

docker-down:
	docker compose down

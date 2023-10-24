.PHONY: up
up:
	docker compose up -d --remove-orphans
	"$(MAKE)" migrate
	"$(MAKE)" app

.PHONY: down
down:
	docker compose down --volumes --remove-orphans

.PHONY: app
app:
	cd app && flutter run -d chrome

.PHONY: migrate
migrate:
	docker compose exec api bash -c "poetry run python -m migrate_db"

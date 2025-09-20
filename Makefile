dd-dev:
	docker compose -f docker-compose.dev.yml down

dbr-dev:
	docker compose -f docker-compose.dev.yml down && docker compose -f docker-compose.dev.yml up -d --build

dps-dev:
	docker-compose -f docker-compose.dev.yml ps

dlogs-dev:
	@if [ -z "$(CONTAINER)" ]; then \
		docker compose -f docker-compose.dev.yml logs -f logv2_app; \
	else \
		docker compose -f docker-compose.dev.yml logs -f $(CONTAINER); \
	fi

drestart:
	@if [ -z "$(CONTAINER)" ]; then \
		echo "Usage: make drestart CONTAINER=logv2_app"; \
		echo "Available containers:"; \
		docker compose -f docker-compose.dev.yml ps --format "table {{.Name}}\t{{.Status}}"; \
	else \
		docker compose -f docker-compose.dev.yml restart $(CONTAINER); \
	fi

dstatus:
	docker compose -f docker-compose.dev.yml ps

dlogs-all:
	docker compose -f docker-compose.dev.yml logs -f

# Миграции базы данных
migrate:
	docker exec -it logv2_app go run cmd/migrate/main.go -action=migrate

rollback:
	docker exec -it logv2_app go run cmd/migrate/main.go -action=rollback

docs-gen:
	docker exec -it logv2_app swag init -g cmd/app/main.go -o docs

.PHONY: dd-dev dbr-dev dps-dev dlogs-dev drestart dstatus dlogs-all migrate rollback docs-gen

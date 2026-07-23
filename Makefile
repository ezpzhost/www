PORT ?= 8000

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

.PHONY: serve
serve: ## Run a local preview server on :$(PORT) (python3 -m http.server)
	python3 -m http.server $(PORT)

.PHONY: check
check: ## Start a local server and smoke-test every page returns 200
	@python3 -m http.server $(PORT) --bind 127.0.0.1 >/tmp/ezpzhost-www-serve.log 2>&1 & \
		echo $$! > /tmp/ezpzhost-www-serve.pid
	@sleep 1
	@chmod +x scripts/smoke_test.sh
	@./scripts/smoke_test.sh http://127.0.0.1:$(PORT); ret=$$?; \
		kill "$$(cat /tmp/ezpzhost-www-serve.pid)" 2>/dev/null; \
		rm -f /tmp/ezpzhost-www-serve.pid; \
		exit $$ret

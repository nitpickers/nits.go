REPO_ROOT := $(shell git rev-parse --show-toplevel)
PRE_PUSH := ${REPO_ROOT}/.git/hooks/pre-push

.DEFAULT_GOAL := help
.PHONY: help
help: githooks ## display this doc
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

.PHONY: githooks
githooks:  ## install githooks
	@test -f "${PRE_PUSH}" || cp -ai "${REPO_ROOT}/.githooks/pre-push" "${PRE_PUSH}"

.PHONY: tidy
tidy:
	# tidy
	go mod tidy
	git diff --exit-code

.PHONY: lint
lint:  ## lint
	# lint
	if ! command -v golangci-lint >/dev/null; then echo golangci-lint not found 1>&2; exit 1; fi
	# cf. https://golangci-lint.run/usage/linters/
	golangci-lint run --fix --sort-results
	git diff --exit-code

.PHONY: test
test:  ## test
	# test
	go test -v -race -p=4 -parallel=8 -timeout=300s -cover -coverprofile=./coverage.txt ./...
	go tool cover -func=./coverage.txt

.PHONY: ci
ci: githooks tidy lint test ## ci

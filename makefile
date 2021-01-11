################################################################################
# Variables
################################################################################
CGO := 0
CMD_DIR := cmd
PKG_DIR := pkg
FRONTEND_DIR := web/frontend
OUTPUT_DIR := ./output

# Build details
VERSION ?= 0.0.1
BUILD_INFO ?= "Makefile build"

# Most likely want to override these when calling `make docker`
DOCKER_REG ?= docker.io
DOCKER_REPO ?= changeme/cassandra-prototype
DOCKER_TAG ?= latest
DOCKER_PREFIX := $(DOCKER_REG)/$(DOCKER_REPO)

# Needed for running locally
export CASSANDRA_USERNAME=cassandra
export CASSANDRA_PASSWORD=cassandra

################################################################################
# Lint check everything 
################################################################################
.PHONY: lint
lint: 
	golint -set_exit_status $(CMD_DIR)/... $(PKG_DIR)/...

################################################################################
# Gofmt
################################################################################
.PHONY: format
format :
	@./.github/gofmt-action.sh $(CMD_DIR)/
	@./.github/gofmt-action.sh $(PKG_DIR)/

################################################################################
# Run tests
################################################################################
.PHONY: test
test: 
	go test -v ./$(CMD_DIR)

################################################################################
# Run tests with output reports
################################################################################
.PHONY: test-output
test-output : 
	rm -rf $(OUTPUT_DIR) && mkdir -p $(OUTPUT_DIR)
	gotestsum --junitfile $(OUTPUT_DIR)/unit-tests.xml ./$(CMD_DIR) --coverprofile $(OUTPUT_DIR)/coverage

################################################################################
# Prepare HTML reports from test output
################################################################################
.PHONY: reports
reports : 
	npx xunit-viewer -r $(OUTPUT_DIR)/unit-tests.xml -o $(OUTPUT_DIR)/unit-tests.html
	go tool cover -html=$(OUTPUT_DIR)/coverage -o $(OUTPUT_DIR)/cover.html
	cp testing/reports.html $(OUTPUT_DIR)/index.html

################################################################################
# Build Docker image (alias)
################################################################################
.PHONY: build
build : docker

################################################################################
# Build Docker image
################################################################################
.PHONY: docker
docker :
	docker build . -f Dockerfile \
	--build-arg VERSION=$(VERSION) \
	--build-arg BUILD_INFO='$(BUILD_INFO)' \
	-t $(DOCKER_PREFIX):$(DOCKER_TAG) -t $(DOCKER_PREFIX):latest

################################################################################
# Push Docker image
################################################################################
.PHONY: push
push :
	docker push $(DOCKER_PREFIX)

################################################################################
# Run locally + Cassandra container with hot reloading
################################################################################
.PHONY: runlocal
runlocal :
	scripts/cassandra-local.sh
	air -c .air.toml
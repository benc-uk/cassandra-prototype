################################################################################
# Variables
################################################################################
CGO := 0
CMD_DIR := cmd
PKG_DIR := pkg
FRONTEND_DIR := web/frontend
OUTPUT_DIR := ./output

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
	go test -v github.com/benc-uk/cassandra-sample/cmd

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

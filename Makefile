.PHONY: help install build test lint format clean validate package all setup

# Default target
.DEFAULT_GOAL := help

# Variables
NODE_VERSION := 20
NPM_VERSION := 10.8.2
SCRIPTS_DIR := scripts
ARTIFACTS_DIR := artifacts

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

##@ General

help: ## Display this help message
	@echo "$(BLUE)Stale Action - Development Makefile$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make $(GREEN)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup and Installation

setup: ## Initial setup - install dependencies and prepare environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@node --version || (echo "$(YELLOW)Node.js $(NODE_VERSION) required$(NC)" && exit 1)
	@npm --version || (echo "$(YELLOW)NPM required$(NC)" && exit 1)
	@$(MAKE) install
	@echo "$(GREEN)Setup complete!$(NC)"

install: ## Install npm dependencies
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm install
	@echo "$(GREEN)Dependencies installed!$(NC)"

##@ Development

build: ## Build the TypeScript project
	@echo "$(BLUE)Building project...$(NC)"
	npm run build
	@echo "$(GREEN)Build complete!$(NC)"

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	npm test
	@echo "$(GREEN)Tests complete!$(NC)"

test-quiet: ## Run tests without verbose output
	@echo "$(BLUE)Running tests (quiet mode)...$(NC)"
	npm run test:only-errors

lint: ## Run linter
	@echo "$(BLUE)Running linter...$(NC)"
	npm run lint

lint-fix: ## Run linter and fix issues
	@echo "$(BLUE)Running linter with auto-fix...$(NC)"
	npm run lint:fix

format: ## Format code with prettier
	@echo "$(BLUE)Formatting code...$(NC)"
	npm run format

format-check: ## Check code formatting
	@echo "$(BLUE)Checking code formatting...$(NC)"
	npm run format-check

##@ Workflow Validation

validate: ## Validate workflow configuration and file patterns
	@echo "$(BLUE)Validating workflow configuration...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/validate-config-update.sh
	@TARGET_FOLDER=./ \
	 SOURCE_BASE=./source/reusable-configurations \
	 FILE_PATTERNS="*" \
	 VERBOSE=true \
	 $(SCRIPTS_DIR)/validate-config-update.sh || true

validate-mock: ## Validate with mock source directory (for testing)
	@echo "$(BLUE)Creating mock source directory for testing...$(NC)"
	@mkdir -p ./source/reusable-configurations
	@touch ./source/reusable-configurations/.gitkeep
	@echo "$(BLUE)Running validation with mock data...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/validate-config-update.sh
	@TARGET_FOLDER=./ \
	 SOURCE_BASE=./source/reusable-configurations \
	 FILE_PATTERNS="*" \
	 VERBOSE=true \
	 $(SCRIPTS_DIR)/validate-config-update.sh
	@rm -rf ./source

##@ Packaging

package: ## Package artifacts for handover
	@echo "$(BLUE)Packaging artifacts...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/package-artifacts.sh
	@OUTPUT_DIR=$(ARTIFACTS_DIR) \
	 INCLUDE_PATTERNS=".glob.yaml scripts/ Makefile README.md" \
	 $(SCRIPTS_DIR)/package-artifacts.sh
	@echo "$(GREEN)Packaging complete!$(NC)"

##@ Cleanup

clean: ## Clean build artifacts and temporary files
	@echo "$(BLUE)Cleaning up...$(NC)"
	rm -rf dist/
	rm -rf node_modules/
	rm -rf $(ARTIFACTS_DIR)/
	rm -rf ./source/
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-artifacts: ## Clean only artifact files
	@echo "$(BLUE)Cleaning artifacts...$(NC)"
	rm -rf $(ARTIFACTS_DIR)/
	@echo "$(GREEN)Artifacts cleaned!$(NC)"

##@ CI/CD

ci: ## Run full CI pipeline (format, lint, build, test)
	@echo "$(BLUE)Running CI pipeline...$(NC)"
	@$(MAKE) format-check
	@$(MAKE) lint
	@$(MAKE) build
	@$(MAKE) test-quiet
	@echo "$(GREEN)CI pipeline complete!$(NC)"

all: clean install build test ## Clean, install, build, and test everything
	@echo "$(GREEN)All tasks complete!$(NC)"

##@ Integration Testing

integration-test: validate-mock package ## Run integration tests (validation + packaging)
	@echo "$(BLUE)Running integration tests...$(NC)"
	@echo "$(GREEN)Integration tests complete!$(NC)"

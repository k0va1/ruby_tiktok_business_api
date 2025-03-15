.PHONY: setup build test lint docs shell console publish release clean help

# Default target
all: help

# Setup development environment
setup:
	docker-compose build

# Build the gem
build:
	docker-compose run --rm gem bundle exec rake build

# Run tests
test:
	docker-compose run --rm test

# Run linting (RuboCop)
lint:
	docker-compose run --rm gem bundle exec rubocop

# Generate documentation
docs:
	docker-compose run --rm gem bundle exec yard

# Open a shell in the Docker container
shell:
	docker-compose run --rm gem bash

# Open a console with the gem loaded
console:
	docker-compose run --rm console

# Publish the gem to RubyGems
publish:
	docker-compose run --rm gem bundle exec rake release

# Prepare a new release (bump version and tag)
release:
	@read -p "Enter new version (current: $$(docker-compose run --rm gem ruby -r ./lib/tiktok_business_api/version -e 'puts TiktokBusinessApi::VERSION')): " version; \
	docker-compose run --rm gem bash -c "sed -i \"s/VERSION = .*$$/VERSION = \\\"$$version\\\"/\" lib/tiktok_business_api/version.rb && \
		git add lib/tiktok_business_api/version.rb && \
		git commit -m \"Bump version to $$version\" && \
		git tag -a v$$version -m \"Version $$version\""

# Clean up containers and build artifacts
clean:
	docker-compose down -v
	rm -rf pkg/*

# Display help information
help:
	@echo "Available targets:"
	@echo "  setup    - Set up the development environment"
	@echo "  build    - Build the gem"
	@echo "  test     - Run tests"
	@echo "  lint     - Run RuboCop linting"
	@echo "  docs     - Generate documentation with YARD"
	@echo "  shell    - Open a shell in the Docker container"
	@echo "  console  - Open a Ruby console with the gem loaded"
	@echo "  publish  - Publish the gem to RubyGems"
	@echo "  release  - Prepare a new release (bump version and tag)"
	@echo "  clean    - Clean up containers and build artifacts"
# VARIABLES ###################################################################

PACKAGE := alvis
MODULES := $(wildcard $(PACKAGE)/*.py)
PYTHON := python3.10
PYTHON_VERSION := 310
REPOSITORY := alvis
UML_FORMAT := mmd

#* Docker variables
IMAGE := alvis
VERSION := latest

# PDM ######################################################################

# Example: make pdm-download PYTHON=python3.10
.PHONY: pdm-download
pdm-download: ## Download and install PDM. Options: PYTHON=<python_command> default: python3.10
	@ echo Downloading PDM and installing using $(PYTHON)
	@ curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | $(PYTHON) -

.PHONY: pdm-remove
pdm-remove: ## Remove pdm. Options: PYTHON=<python_command> default: python3.10
	@ echo Removing PDM
	@ curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | $(PYTHON) - --remove

# INSTALL #####################################################################

.PHONY: install
install: install-dependencies install-pre-commit ## Install dependencies and pre-commit hooks

.PHONY: install-dependencies
install-dependencies: ## Install package dependencies
	@ pdm install

.PHONY: install-pre-commit
install-pre-commit: ## Install pre-commit hooks
	@ pdm run pre-commit install

.PHONY: update-dev-dependencies
update-dev-deps:  ## Update development dependencies
	@ pdm update --dev

.PHONY: update-pre-commit
update-pre-commit: ## Update pre-commit hooks
	@ pdm run pre-commit autoupdate

# FORMAT ######################################################################

.PHONY: format
format: format-pyupgrade format-isort format-black ## Format codestyle; pyupgrade, isort, black

.PHONY: format-black
format-black: ## Format code using black
	@ pdm run black --config pyproject.toml .

.PHONY: format-isort
format-isort: ## Format imports using isort
	@ pdm run isort --settings-path pyproject.toml .

.PHONY: format-pyupgrade
format-pyupgrade: ## Update code to desired Python version syntax. Options: PYTHON_VERSION
	@ pdm run pyupgrade --exit-zero-even-if-changed --py$(PYTHON_VERSION)-plus **/*.py

# LINT ########################################################################

.PHONY: lint
lint: test lint-codestyle lint-security ## Run tests and linting operations

.PHONY: lint-codestyle
lint-codestyle: ## Check for codestyle issues
	@ echo Checking imports...
	@ pdm run isort --diff --check-only --settings-path pyproject.toml .
	@ echo
	@ echo Checking codestyle...
	@ pdm run black --diff --check --config pyproject.toml .
	@ echo
	@ echo Checking docstrings...
	@ pdm run pydocstyle $(PACKAGE) tests
	@ echo Success, no missing docstrings!
	@ echo
	@ echo Validating docstrings...
	@ pdm run darglint --verbosity 2 $(PACKAGE) tests
	@ echo Success, docstrings have been validated!
	@ echo
	@ echo Checking code with Pylint...
	@ pdm run pylint $(PACKAGE) tests
	@ echo Linting complete!
	@ echo

.PHONY: lint-security
lint-security: ## Check for security issues
	@ echo Checking for security issues in dependencies with Saftey...
	@ pdm run safety check --full-report --bare
	@ echo
	@ echo Checking for security issues with Bandit...
	@ pdm run bandit -ll --recursive --silent $(PACKAGE) tests
	@ echo
	@ echo Security checks successful!

# TEST ########################################################################

.PHONY: test
test: ## Run tests
	@ pdm run pytest -c pyproject.toml

.PHONY: test-read-coverage
test-coverage: ## Display test coverage in your browser
	$(OPEN) htmlcov/index.html


# DOCKER ######################################################################

DOCKER_CACHE := true

ifeq ($(DOCKER_CACHE), false)
	_DOCKER_CACHE := --no-cache
endif

# Example: make docker VERSION=latest
# Example: make docker IMAGE=<image_name> VERSION=0.1.0
.PHONY: docker-build
docker-build: ## Build docker image. Options: IMAGE=<image_name> default: config_parser | VERSION=<image_tag> default: latest | DOCKER_CACHE=false default: true
	@ echo Building docker $(IMAGE):$(VERSION) ...
	docker build -t $(IMAGE):$(VERSION) . -f ./docker/Dockerfile $(_DOCKER_CACHE) $(_DOCKER_DEV)

.PHONY: docker-remove
docker-remove: ## Remove docker image. Options: IMAGE=<image_name> default: actions_test_python | VERSION=<image_tag> default: latest
	@ echo Removing docker $(IMAGE):$(VERSION) ...
	@ docker rmi -f $(IMAGE):$(VERSION)

# DOCUMENTATION ###############################################################

MKDOCS_INDEX := site/index.html

.PHONY: docs
docs: docs-mkdocs docs-uml ## Generate documentation and UML

.PHONY: docs-mkdocs
docs-mkdocs: $(MKDOCS_INDEX) ## Generate documentation
$(MKDOCS_INDEX): mkdocs.yml docs/*.md
	@ mkdir -p docs/about
	@ cd docs && ln -sf ../README.md index.md
	@ cd docs/about && ln -sf ../../CHANGELOG.md changelog.md
	@ pdm run mkdocs build --clean --strict

.PHONY: docs-uml
docs-uml: ## Generate UML documentation
	@ pdm run pyreverse $(PACKAGE) -p $(PACKAGE) -a 1 -f ALL -o $(UML_FORMAT) --ignore tests
	@ - mv -f classes_$(PACKAGE).$(UML_FORMAT) docs/classes.$(UML_FORMAT)
	@ - mv -f packages_$(PACKAGE).$(UML_FORMAT) docs/packages.$(UML_FORMAT)

.PHONY: docs-serve
docs-serve: docs ## Open documentation locally
	@ eval "sleep 3; $(OPEN) http://localhost:8000" &
	@ pdm run mkdocs serve

.PHONY: docs-deploy
docs-deploy: ## Deploy documentation to gh-pages
	@ mkdocs gh-deploy

# CLEANUP #####################################################################

.PHONY: clean
clean: clean-build clean-docs clean-test clean-compiled ## Delete all generated and temporary files

.PHONY: clean-build
clean-build: ## Delete package build
	@ rm -rf dist/
	@ echo Removed package build files

.PHONY: clean-docker
clean-docker: ## Delete all docker images by name. Options: IMAGE=<image_name> default: config_parser
	@ echo Removing all $(IMAGE) images
	@ docker rmi -f $(shell docker images $(IMAGE) -a -q)
	@ echo All $(IMAGE) images removed

.PHONY: clean-docs
clean-docs: ## Delete UML files in docs directory
	@ rm -rf docs/*.$(UML_FORMAT) site
	@ echo Cleaned docs

.PHONY: clean-compiled
clean-compiled: ## Delete compiled python files
	@ find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf
	@ echo Compiled Python files removed

.PHONY: clean-test
clean-test: ## Delete test cache and coverage reports
	@ rm -rf .cache .pytest .coverage htmlcov
	@ echo Test data removed

.PHONY: clean-pypackages
clean-pypackages: ## Delete __pypackages__
	@ echo Removing __pypackages__ from project.
	@ rm -rf __pypackages__
	@ echo __pypackages__ removed

.PHONY: clean-all
clean-all: clean clean-docker clean-pypackages ## Run all cleaning tasks

# PUBLISHING ##################################################################

.PHONY: bump
bump: ## Update changelog and git tags based on commit changes
	pdm run cz bump --check-consistency --changelog
	git push
	git push --tags

# HELP ########################################################################

.PHONY: help
help: ## Show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

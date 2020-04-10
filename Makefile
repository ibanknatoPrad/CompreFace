SHELL := /bin/bash
.PHONY: $(MAKECMDGOALS)
.EXPORT_ALL_VARIABLES:
.DEFAULT_GOAL := default
FLASK_ENV ?= development
MONGODB_HOST ?= localhost
MONGODB_PORT ?= 27117
API_KEY ?= $(shell echo test-$$(date +'%Y-%m-%d-%H-%M-%S-%3N'))

#####################################
##### MAIN TEST
#####################################

default: test/unit test/lint test

test:
	MEM_LIMIT=4g docker-compose up --build --abort-on-container-exit

#####################################
##### RUNNING IN DOCKER
#####################################

build:
	docker-compose build ml

up:
	docker-compose up ml

down:
	docker-compose down

#####################################
##### RUNNING IN LOCAL ENVIRONMENT
#####################################

setup:
	chmod +x ml/run.sh e2e/run-e2e-test.sh ml/tools/test_oom.sh
	python -m pip install -r ml/requirements.txt
	python -m pip install -e ml/srcext/insightface/python-package

start:
	ml/run.sh start

stop:
	ml/run.sh stop

#####################################
##### TESTING IN LOCAL ENVIRONMENT
#####################################

test/local: test/unit test/lint test/i9n

test/unit:
	python -m pytest -m "not integration" ml/src

test/lint:
	python -m pylama --options ml/pylama.ini ml/src

test/i9n:
	python -m pytest -m integration $(CURDIR)/ml/src

test/e2e: e2e/local

#####################################
##### E2E TESTING
#####################################

e2e:
	e2e/run-e2e-test.sh

e2e/extended:
	$(MAKE) scan
	e2e/run-e2e-test.sh

e2e/local: start
	timeout 10s bash -c "until [ -f $(CURDIR)/ml/run.pid ]; do sleep 1; done"
	sleep 5s
	test -f $(CURDIR)/ml/run.pid
	$(MAKE) e2e && ml/run.sh stop || (ml/run.sh stop; exit 1)

#####################################
##### DEV SCRIPTS
#####################################

# Detect faces on given images, with selected scanners, and output the results:
scan:
	python -m ml.src.services.facescan.run
demo:
	python -m ml.src.services.facescan.run IMG_NAMES=000_5.jpg

# Optimize face detection parameters with a given annotated image dataset:
optimize:
	python -m ml.src.services.facescan.optimizer.run

# Run experiments whether the system will crash with given images, selected face detection scanners, RAM limits, image processing settings, etc.:
crash_lab:
	tools/crash_lab.sh $(CURDIR)/ml/sample_images

#####################################
##### MISC
#####################################

# Give random project name
COMPOSE_PROJECT_NAME:
	@echo frs-core-$$(</dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)

# Find open port
PORT:
	@echo $$(while true; do port=$$(( RANDOM % 30000 + 30000 )); echo -ne "\035" | telnet 127.0.0.1 \
		$$port > /dev/null 2>&1; [ $$? -eq 1 ] && echo "$$port" && exit 0; done )

# Give unique api_key
API_KEY:
	@echo test-$$(date +'%Y-%m-%d-%H-%M-%S-%3N')

# Start database container
db:
	docker-compose up -d mongodb

# Show code stats
stats:
	(which tokei || conda install -y -c conda-forge tokei) && \
	tokei --exclude srcext/

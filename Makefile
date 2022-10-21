# Variables
PROJECTNAME=existenz/builder
TAG=UNDEF
PHP_VERSION=$(shell echo "$(TAG)" | sed -e 's/-.*//')
LATEST_TAG=8.1

.PHONY: all
all: build start test stop clean

build:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker build -t $(PROJECTNAME):$(TAG) -f Dockerfile-$(TAG) --pull .
	if [ "$(TAG)" = "$(LATEST_TAG)" ]; then docker tag $(PROJECTNAME):$(TAG) $(PROJECTNAME):latest; fi

start:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker run -ti -d \
		-v $$(pwd)/tests:/tests \
		--name existenz_builder_instance $(PROJECTNAME):$(TAG) \
		watch date

stop:
	docker stop -t0 existenz_builder_instance
	docker rm existenz_builder_instance

clean:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker rmi $(PROJECTNAME):$(TAG) || true
	docker rmi $(PROJECTNAME):latest || true

test: test-install test-various
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi

test-install:
	docker exec -t existenz_builder_instance php --version | grep -q "PHP $(PHP_VERSION)"
	docker exec -t existenz_builder_instance php --version | grep -q "Xdebug"
	docker exec -t existenz_builder_instance composer --version > /dev/null
	docker exec -t existenz_builder_instance node --version > /dev/null
	docker exec -t existenz_builder_instance npm --version > /dev/null
	docker exec -t existenz_builder_instance yarn --version > /dev/null
	docker exec -t existenz_builder_instance buildah --version > /dev/null
	docker exec -t existenz_builder_instance podman --version > /dev/null

test-various:
	docker exec -t existenz_builder_instance php tests/iconv.php
	docker exec -t existenz_builder_instance php tests/locales.php
	docker exec -t existenz_builder_instance php -m | grep -q "zlib"

shell:
	docker exec -ti existenz_builder_instance sh

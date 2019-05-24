.PHONY: build run stop clean test

# Variables
PROJECTNAME=existenz/builder
TAG=UNDEF
LATEST_TAG=7.3

build:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker build -t $(PROJECTNAME):$(TAG) -f Dockerfile-$(TAG) --pull .
	if [ "$(TAG)" = "$(LATEST_TAG)" ]; then docker tag $(PROJECTNAME):$(TAG) $(PROJECTNAME):latest; fi

run:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker run -ti -d --name existenz_builder_instance $(PROJECTNAME):$(TAG) watch date

stop:
	docker stop -t0 existenz_builder_instance
	docker rm existenz_builder_instance

clean:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker rmi $(PROJECTNAME):$(TAG) || true
	docker rmi $(PROJECTNAME):latest || true

test:
	if [ "$(TAG)" = "UNDEF" ]; then echo "please provide a valid TAG" && exit 1; fi
	docker exec -t existenz_builder_instance php --version | grep -q "PHP $(TAG)"
	docker exec -t existenz_builder_instance php --version | grep -q "Xdebug"
	docker exec -t existenz_builder_instance composer --version > /dev/null
	docker exec -t existenz_builder_instance node --version > /dev/null
	docker exec -t existenz_builder_instance npm --version > /dev/null
	docker exec -t existenz_builder_instance yarn --version > /dev/null

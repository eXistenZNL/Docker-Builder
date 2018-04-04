.PHONY: build run clean

# Variables
PROJECTNAME=existenz/builder
TAGNAME=UNDEF
LATEST_TAG=7.2

build:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker build -t $(PROJECTNAME):$(TAGNAME) -f Dockerfile-$(TAGNAME) --pull .
	if [ "$(TAGNAME)" = "$(LATEST_TAG)" ]; then docker tag $(PROJECTNAME):$(TAGNAME) $(PROJECTNAME):latest; fi

run:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker run -ti -d --name existenz_builder_instance $(PROJECTNAME):$(TAGNAME) watch date

stop:
	docker stop -t0 existenz_builder_instance
	docker rm existenz_builder_instance

clean:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker rmi $(PROJECTNAME):$(TAGNAME)

test:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker exec -t existenz_builder_instance php --version | grep -q "PHP $(TAGNAME)"
	docker exec -t existenz_builder_instance composer --version > /dev/null
	docker exec -t existenz_builder_instance node --version > /dev/null
	docker exec -t existenz_builder_instance npm --version > /dev/null
	docker exec -t existenz_builder_instance yarn --version > /dev/null

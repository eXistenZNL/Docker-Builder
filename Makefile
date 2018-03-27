.PHONY: build run clean

# Variables
PROJECTNAME=existenz/builder
TAGNAME=UNDEF
LATEST_TAG=7.1

build:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker build -t $(PROJECTNAME):$(TAGNAME) -f Dockerfile-$(TAGNAME) --pull .
	if [ "$(TAGNAME)" = "$(LATEST_TAG)" ]; then docker tag $(PROJECTNAME):$(TAGNAME) $(PROJECTNAME):latest; fi

run:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker run -ti --rm $(PROJECTNAME):$(TAGNAME) sh

clean:
	if [ "$(TAGNAME)" = "UNDEF" ]; then echo "please provide a valid TAGNAME" && exit 1; fi
	docker rmi $(PROJECTNAME):$(TAGNAME)

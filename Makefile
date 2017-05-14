.PHONY: build run clean

build:
	docker build -t existenz/builder:latest .

run:
	docker run -ti --rm existenz/builder:latest sh

clean:
	docker rmi existenz/builder:latest

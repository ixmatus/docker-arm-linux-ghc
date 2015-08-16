.PHONY: build push

build:
	sudo docker build -t plumlife/ghc:7.8.4 .

push:
	sudo docker push plumlife/ghc:7.8.4

bash:
	docker run --rm -i -t plumlife/7.8.4 bash

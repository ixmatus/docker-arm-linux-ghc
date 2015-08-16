.PHONY: build push

build:
	sudo docker build -t plumlife/arm-ghc:7.8.4 .

push:
	sudo docker push plumlife/arm-ghc:7.8.4

bash:
	docker run --rm -i -t plumlife/arm-ghc:7.8.4 bash

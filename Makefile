VERSION = 0.3.7
.PHONY: build push 

build: 
	docker buildx build --platform linux/amd64 -t registry-hetzner.finomena.fi/osrm-backendv2:$(VERSION) .

push: build
	docker push registry-hetzner.finomena.fi/osrm-backendv2:$(VERSION)
VERSION = 0.2.5
.PHONY: build push 

build: 
	docker build -t registry.finomena.fi/c/osrm-backendv2:$(VERSION) .

build_h: 
	docker build -t registry-hetzner.finomena.fi/c/osrm-backendv2:$(VERSION) .

push: build
	docker push registry.finomena.fi/c/osrm-backendv2:$(VERSION)

push_h: build_h
	docker push registry-hetzner.finomena.fi/c/osrm-backendv2:$(VERSION)
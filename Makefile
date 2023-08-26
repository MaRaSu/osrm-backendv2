.PHONY: build push 

build: 
	docker build -t registry.finomena.fi/c/osrm-backendv2:0.2.2 .

push: build
	docker push registry.finomena.fi/c/osrm-backendv2:0.2.2
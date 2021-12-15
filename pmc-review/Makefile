.PHONY: run chown

# Starts the structurizr lite docker container
run:
	touch workspace.json
	mkdir -p .structurizr
	docker run -it --rm -p 8080:8080 \
		-v $$(realpath .):/usr/local/structurizr \
		structurizr/lite

# Chowns all the files to the current user
chown:
	chown -R $$(id -u):$$(id -g) ./

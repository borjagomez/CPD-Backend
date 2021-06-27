build-base:
	docker build -t borjagomez/cpdbackend-base - < Dockerfile-base

build:
	docker build . -t borjagomez/cpdbackend 

push-base:
	docker push borjagomez/cpdbackend-base

push:
	docker push borjagomez/cpdbackend 

deploy:
	docker tag borjagomez/cpdbackend gcr.io/cpd-infrastructure/cpdbackend
	docker push gcr.io/cpd-infrastructure/cpdbackend

run:
	docker-compose up --build

stop:
	docker-compose down

bash-base:
	docker run -it borjagomez/cpdbackend-base /bin/bash

bash:
	docker run -it borjagomez/cpdbackend /bin/bash

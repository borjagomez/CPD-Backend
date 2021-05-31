build-base:
	docker build -t borjagomez/cpdbackend-base - < Dockerfile-base

build:
	docker build . -t borjagomez/cpdbackend 

push-base:
	docker push borjagomez/cpdbackend-base

push:
	docker push borjagomez/cpdbackend 

update:
	docker build . -t borjagomez/cpdbackend
	docker push gcr.io/cpd-infrastructure/cpdbackend

run:
	docker-compose up

stop:
	docker-compose down

bash:
	docker run -it borjagomez/cpdbackend /bin/bash
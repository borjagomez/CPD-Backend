build-base:
	docker build . -t borjagomez/cpdbackend-base -f ./Dockerfile-base 

build:
	docker build . -t borjagomez/cpdbackend 

push-base:
	docker push borjagomez/cpdbackend-base

push:
	docker push borjagomez/cpdbackend 

deploy:
	docker tag borjagomez/cpdbackend gcr.io/cpd-infrastructure/cpdbackend
	docker push gcr.io/cpd-infrastructure/cpdbackend
	gcloud run deploy cpdbackend --region=us-central1 --image=gcr.io/cpd-infrastructure/cpdbackend:latest --platform managed --port 3000

run:
	docker-compose up --build

stop:
	docker-compose down

bash-base:
	docker run -it borjagomez/cpdbackend-base /bin/bash

bash:
	docker run -it borjagomez/cpdbackend /bin/bash

build-base:
	docker build -t borjagomez/cpdbackend-base - < Dockerfile-base

build:
	docker build . -t borjagomez/cpdbackend 

push-base:
	docker push borjagomez/cpdbackend-base

push:
	docker push borjagomez/cpdbackend 

deploy:
	gcloud builds submit

run:
	docker-compose up --build

stop:
	docker-compose down

bash:
	docker run -it borjagomez/cpdbackend /bin/bash
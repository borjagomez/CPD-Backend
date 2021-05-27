build:
	docker build . -t borjagomez/cpdbackend 

push:
	docker push borjagomez/cpdbackend 

bash:
	docker run -it borjagomez/cpdbackend /bin/bash
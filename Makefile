default:
	docker build -t openaustralia/mapit-australia .
run:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia /bin/bash
server:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia

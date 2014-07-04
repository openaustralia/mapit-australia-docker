default:
	docker build -t openaustralia/mapit-australia .
run:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia /bin/bash
server:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia
download:
	wget "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_lga_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&4A320EE17A293459CA257937000CC967&0&July%202011&31.10.2011&Previous" -O 1270055003_lga_2011_aust_shape.zip

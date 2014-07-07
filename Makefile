default:
	docker build -t openaustralia/mapit-australia .
run:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia /bin/bash
server:
	docker run -p 8020:80 -i -t openaustralia/mapit-australia
download:
	mkdir -p data
	wget "http://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1259030001_ste11aaust_shape.zip&1259.0.30.001&Data%20Cubes&D39E28B23F39F498CA2578CC00120E25&0&July%202011&14.07.2011&Latest" -O data/1259030001_ste11aaust_shape.zip
	wget "http://aec.gov.au/Electorates/gis/files/national-esri-16122011.zip" -O data/national-esri-16122011.zip
	wget "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_poa_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&71B4572D909B934ECA2578D40012FE0D&0&July%202011&22.07.2011&Previous" -O data/1270055003_poa_2011_aust_shape.zip
	wget "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_sed_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&1F692001AC7E460DCA2578D40013567C&0&July%202011&22.07.2011&Previous" -O data/1270055003_sed_2011_aust_shape.zip
	wget "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_lga_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&4A320EE17A293459CA257937000CC967&0&July%202011&31.10.2011&Previous" -O data/1270055003_lga_2011_aust_shape.zip
	wget "http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_ced_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&AFFAF0F44528F2EFCA2578D40013CA06&0&July%202011&22.07.2011&Previous" -O data/1270055003_ced_2011_aust_shape.zip

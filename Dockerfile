FROM openaustralia/mapit
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

# There are two alternate ways to add the data. The first is to download it locally using "make download"
# and then insert the files here
# ADD data /data
# The second way is to insert the files directly.
ADD http://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1259030001_ste11aaust_shape.zip&1259.0.30.001&Data%20Cubes&D39E28B23F39F498CA2578CC00120E25&0&July%202011&14.07.2011&Latest data/STE11aAust.zip
ADD http://aec.gov.au/Electorates/gis/files/national-esri-16122011.zip data/COM20111216_ELB_region.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_poa_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&71B4572D909B934ECA2578D40012FE0D&0&July%202011&22.07.2011&Previous data/POA_2011_AUST.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_sed_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&1F692001AC7E460DCA2578D40013567C&0&July%202011&22.07.2011&Previous data/SED_2011_AUST.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_lga_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&4A320EE17A293459CA257937000CC967&0&July%202011&31.10.2011&Previous data/LGA_2011_AUST.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_ced_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&AFFAF0F44528F2EFCA2578D40013CA06&0&July%202011&22.07.2011&Previous data/CED_2011_AUST.zip
# The first way is great during development as the step will get cached.
# The second way is great for building on Docker Hub

ADD codes.sql /codes.sql
RUN service postgresql start; cat /codes.sql | su -l -c "psql mapit" mapit

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_create --desc='Initial import' --commit" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_activate --commit" mapit

RUN cd /data; unzip LGA_2011_AUST.zip; rm LGA_2011_AUST.zip
RUN ogr2ogr -f "KML" -dsco NameField=LGA_NAME11 /data/LGA_2011_AUST.kml /data/LGA_2011_AUST.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code LGA --name_type_code LGA --generation_id 1 --commit /data/LGA_2011_AUST.kml" mapit

RUN cd /data; unzip SED_2011_AUST.zip; rm SED_2011_AUST.zip
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
RUN ogr2ogr -f "KML" -dsco NameField=SED_NAME /data/SED_2011_AUST.kml /data/SED_2011_AUST.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code SED --name_type_code SED --generation_id 1 --commit /data/SED_2011_AUST.kml" mapit

RUN cd /data; unzip POA_2011_AUST.zip; rm POA_2011_AUST.zip
RUN ogr2ogr -f "KML" -dsco NameField=POA_CODE /data/POA_2011_AUST.kml /data/POA_2011_AUST.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code POA --name_type_code POA --generation_id 1 --commit /data/POA_2011_AUST.kml" mapit

RUN cd /data; unzip COM20111216_ELB_region.zip; rm COM20111216_ELB_region.zip
RUN ogr2ogr -f "KML" -dsco NameField=ELECT_DIV /data/COM20111216_ELB_region.kml /data/COM20111216_ELB_region.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --commit /data/COM20111216_ELB_region.kml" mapit

#RUN cd /data; unzip CED_2011_AUST.zip; rm CED_2011_AUST.zip
#RUN ogr2ogr -f "KML" -dsco NameField=CED_NAME /data/CED_2011_AUST.kml /data/CED_2011_AUST.shp
#RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --commit /data/CED_2011_AUST.kml" mapit

RUN cd /data; unzip STE11aAust.zip; rm STE11aAust.zip
RUN ogr2ogr -f "KML" -dsco NameField=STATE_NAME /data/STE11aAust.kml /data/STE11aAust.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code STE --name_type_code STE --generation_id 1 --commit /data/STE11aAust.kml" mapit

ADD copyright.html /var/www/mapit/mapit/mapit/templates/mapit/copyright.html
ADD country.html /var/www/mapit/mapit/mapit/templates/mapit/country.html

RUN rm -rf /data

# TODO: Make mapit handle areas with numeric names
# TODO: Look for more authoritive sources for electoral boundaries, LGAs
# TODO: Include Aborginal Areas
# TODO: Include Suburbs
# TODO: Include Council Wards?
# Victorian Council Ward & State Electoral Division Boundaries: https://www.vec.vic.gov.au/publications/publications-maps.html
# South Australian LGAs: http://dpti.sa.gov.au/open_data_portal

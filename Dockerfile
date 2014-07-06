FROM openaustralia/mapit
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

# There are two alternate ways to add the data. The first is to download it locally using "make download"
# and then insert the files here
#ADD data /data
# The second way is to insert the files directly.
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_poa_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&71B4572D909B934ECA2578D40012FE0D&0&July%202011&22.07.2011&Previous data/1270055003_poa_2011_aust_shape.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_sed_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&1F692001AC7E460DCA2578D40013567C&0&July%202011&22.07.2011&Previous data/1270055003_sed_2011_aust_shape.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_lga_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&4A320EE17A293459CA257937000CC967&0&July%202011&31.10.2011&Previous data/1270055003_lga_2011_aust_shape.zip
ADD http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055003_ced_2011_aust_shape.zip&1270.0.55.003&Data%20Cubes&AFFAF0F44528F2EFCA2578D40013CA06&0&July%202011&22.07.2011&Previous data/1270055003_ced_2011_aust_shape.zip
# The first way is great during development as the step will get cached.
# The second way is great for building on Docker Hub

RUN cd /data; unzip 1270055003_lga_2011_aust_shape.zip; rm 1270055003_lga_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_sed_2011_aust_shape.zip; rm 1270055003_sed_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_ced_2011_aust_shape.zip; rm 1270055003_ced_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_poa_2011_aust_shape.zip; rm 1270055003_poa_2011_aust_shape.zip
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
RUN ogr2ogr -f "KML" -dsco NameField=SED_NAME /data/SED_2011_AUST.kml /data/SED_2011_AUST.shp
RUN ogr2ogr -f "KML" -dsco NameField=CED_NAME /data/CED_2011_AUST.kml /data/CED_2011_AUST.shp
RUN ogr2ogr -f "KML" -dsco NameField=LGA_NAME11 /data/LGA_2011_AUST.kml /data/LGA_2011_AUST.shp
RUN ogr2ogr -f "KML" -dsco NameField=POA_CODE /data/POA_2011_AUST.kml /data/POA_2011_AUST.shp

ADD codes.sql /codes.sql
RUN service postgresql start; cat /codes.sql | su -l -c "psql mapit" mapit

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_create --desc='Initial import' --commit" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_activate --commit" mapit

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code SED --name_type_code SED --generation_id 1 --commit /data/SED_2011_AUST.kml" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --commit /data/CED_2011_AUST.kml" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code LGA --name_type_code LGA --generation_id 1 --commit /data/LGA_2011_AUST.kml" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code POA --name_type_code POA --generation_id 1 --commit /data/POA_2011_AUST.kml" mapit

# TODO: Cleanup apt downloads
# TODO: Cleanup temporary data files
# TODO: Make mapit handle areas with numeric names

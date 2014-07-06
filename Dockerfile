FROM openaustralia/mapit
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_create --desc='Initial import' --commit" mapit
RUN apt-get install unzip
RUN mkdir /data
ADD 1270055003_lga_2011_aust_shape.zip /data/1270055003_lga_2011_aust_shape.zip
ADD 1270055003_ced_2011_aust_shape.zip /data/1270055003_ced_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_lga_2011_aust_shape.zip; rm 1270055003_lga_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_ced_2011_aust_shape.zip; rm 1270055003_ced_2011_aust_shape.zip
# Curious. Expected Shapely to be installed earlier
RUN pip install Shapely
# See this: https://code.djangoproject.com/ticket/16778
RUN echo "standard_conforming_strings = off" >> /etc/postgresql/9.1/main/postgresql.conf

RUN service postgresql start; echo "INSERT INTO mapit_country (code, name) VALUES ('AU', 'Australia');" | su -l -c "psql mapit" mapit
RUN service postgresql start; echo "INSERT INTO mapit_type (code, description) VALUES ('LGA', 'Local Government Area');" | su -l -c "psql mapit" mapit
RUN service postgresql start; echo "INSERT INTO mapit_nametype (code, description) VALUES ('LGA', 'Local Government Area');" | su -l -c "psql mapit" mapit
RUN service postgresql start; echo "INSERT INTO mapit_type (code, description) VALUES ('CED', 'Commonwealth Electoral Division');" | su -l -c "psql mapit" mapit
RUN service postgresql start; echo "INSERT INTO mapit_nametype (code, description) VALUES ('CED', 'Commonwealth Electoral Division');" | su -l -c "psql mapit" mapit

RUN apt-get install -y gdal-bin
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
RUN ogr2ogr -f "KML" -dsco NameField=CED_NAME /data/CED_2011_AUST.kml /data/CED_2011_AUST.shp

# Turn debug off so we don't run out of memory during imports
RUN sed 's/DEBUG: True/DEBUG: False/' /var/www/mapit/mapit/conf/general.yml > /var/www/mapit/mapit/conf/general2.yml; mv /var/www/mapit/mapit/conf/general2.yml /var/www/mapit/mapit/conf/general.yml
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --commit /data/CED_2011_AUST.kml" mapit

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_activate --commit" mapit

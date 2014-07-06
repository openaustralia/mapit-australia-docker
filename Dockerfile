FROM openaustralia/mapit
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

# This block should probably be moved to openaustralia/mapit
# See this: https://code.djangoproject.com/ticket/16778
RUN echo "standard_conforming_strings = off" >> /etc/postgresql/9.1/main/postgresql.conf
# Curious. Expected Shapely to be installed earlier
RUN pip install Shapely
# Turn debug off so we don't run out of memory during imports
RUN sed 's/DEBUG: True/DEBUG: False/' /var/www/mapit/mapit/conf/general.yml > /var/www/mapit/mapit/conf/general2.yml; mv /var/www/mapit/mapit/conf/general2.yml /var/www/mapit/mapit/conf/general.yml

# Takes boundary data as shapefiles and converts to kml. Need to do this as loading into mapit as shapefile
# causes problems
RUN apt-get install -y unzip gdal-bin
RUN mkdir /data
ADD data/1270055003_lga_2011_aust_shape.zip /data/1270055003_lga_2011_aust_shape.zip
ADD data/1270055003_ced_2011_aust_shape.zip /data/1270055003_ced_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_lga_2011_aust_shape.zip; rm 1270055003_lga_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_ced_2011_aust_shape.zip; rm 1270055003_ced_2011_aust_shape.zip
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
RUN ogr2ogr -f "KML" -dsco NameField=CED_NAME /data/CED_2011_AUST.kml /data/CED_2011_AUST.shp

ADD codes.sql /codes.sql
RUN service postgresql start; cat /codes.sql | su -l -c "psql mapit" mapit

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_create --desc='Initial import' --commit" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --commit /data/CED_2011_AUST.kml" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_activate --commit" mapit

RUN ogr2ogr -f "KML" -dsco NameField=LGA_NAME11 /data/LGA_2011_AUST.kml /data/LGA_2011_AUST.shp
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code LGA --name_type_code LGA --generation_id 1 --commit /data/LGA_2011_AUST.kml" mapit

FROM openaustralia/mapit
MAINTAINER Matthew Landauer <matthew@oaf.org.au>

RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_generation_create --desc='Initial import' --commit" mapit
RUN apt-get install unzip
RUN mkdir /data
ADD 1270055003_lga_2011_aust_shape.zip /data/1270055003_lga_2011_aust_shape.zip
RUN cd /data; unzip 1270055003_lga_2011_aust_shape.zip; rm 1270055003_lga_2011_aust_shape.zip
#RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --generation_id 1 --commit /data/LGA_2011_AUST.shp" mapit

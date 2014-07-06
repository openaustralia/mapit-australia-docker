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

#RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code LGA --name_type_code LGA --generation_id 1 --name_field LGA_NAME11 --encoding ISO-8859-1 --commit /data/LGA_2011_AUST.shp" mapit
RUN service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code CED --name_type_code CED --generation_id 1 --name_field CED_NAME --encoding ISO-8859-1 --fix_invalid_polygons --commit /data/CED_2011_AUST.shp" mapit

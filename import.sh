#!/bin/bash

NAME=$1
CODE=$2
NAME_FIELD=$3

cd /data; unzip $NAME.zip; rm $NAME.zip
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
ogr2ogr -f "KML" -dsco NameField=$NAME_FIELD /data/$NAME.kml /data/$NAME.shp
service postgresql start; su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code $CODE --name_type_code $CODE --generation_id 1 --commit /data/$NAME.kml" mapit

#!/bin/bash

NAME=$1
CODE=$2
DESCRIPTION=$3
NAME_FIELD=$4

service postgresql start
echo "INSERT INTO mapit_type (code, description) VALUES ('$CODE', '$DESCRIPTION'); INSERT INTO mapit_nametype (code, description) VALUES ('$CODE', '$DESCRIPTION');" | su -l -c "psql mapit" mapit
echo "INSERT INTO mapit_codetype (code, description) VALUES ('$CODE', '$DESCRIPTION')" | su -l -c "psql mapit" mapit

cd /data; unzip $NAME.zip; rm $NAME.zip
# TODO do proper projection conversion using -s_srs "EPSG:28350" -t_srs "EPSG:4326"
ogr2ogr -f "KML" -dsco NameField=$NAME_FIELD /data/$NAME.kml /data/$NAME.shp
su -l -c "/var/www/mapit/mapit/manage.py mapit_import --country_code AU --area_type_code $CODE --name_type_code $CODE --code_type $CODE --code_field Name --use_code_as_id --generation_id 1 --commit /data/$NAME.kml" mapit

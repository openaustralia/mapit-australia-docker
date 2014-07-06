## Dockerized Mapit with Australian data pre-loaded
### This is a work in progress and not quite ready to be used

### How to run this

You actually don't need this repository to try it out. The docker image built from this is
automatically available from the [Docker Hub](https://hub.docker.com/).

First, you'll need to install [Docker](https://docs.docker.com/) if you don't already have it.

Then,
```
docker pull openaustralia/mapit-australia
docker run -p 8020:80 -d openaustralia/mapit-australia
```

Point your web browser to [http://localhost:8020](http://localhost:8020) and you should
MapIt Australia.

### Some example queries

#### [http://localhost:8020/point/4326/150.3,-33.7.html](http://localhost:8020/point/4326/150.3,-33.7.html)
Find areas over the point (150.3,-33.7) which is roughly Katoomba, NSW

#### [http://localhost:8020/area/1785.html](http://localhost:8020/area/1785.html)
The postcode 2780

#### [http://localhost:8020/area/1785/intersects.html](http://localhost:8020/area/1785/intersects.html)
All areas that intersect postcode 2780

#### [http://localhost:8020/area/1785/intersects.html?type=CED](http://localhost:8020/area/1785/intersects.html?type=CED)
All Commonwealth Electoral Divisions that intersect 2780.

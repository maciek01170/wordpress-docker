#!/usr/bin/env bash
docker run --name wp-volumes -v $(pwd)/data/var/lib/mysql:/var/lib/mysql -v $(pwd)/data/var/www/html:/var/www/html -d wp-volumes tail -f /dev/null
docker run --name wp-database --volumes-from wp-volumes -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql
docker run --name wp-wordpress --volumes-from wp-volumes --link wp-database:mysql -p 8080:80 -d wp-wordpress:latest
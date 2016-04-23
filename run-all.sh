#!/usr/bin/env bash
docker run --name wiez-volumes -v $(pwd)/data/var/lib/mysql:/var/lib/mysql -v $(pwd)/data/var/www/html:/var/www/html -d wiez-volumes tail -f /dev/null
docker run --name wiez-database --volumes-from wiez-volumes -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql
docker run --name wiez-wordpress --volumes-from wiez-volumes --link wiez-database:mysql -p 8080:80 -d wiez-wordpress:latest
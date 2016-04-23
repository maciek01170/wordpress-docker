# Overview 
The project contains 3 docker containers:
1. wiez-volumes is just the data volume holding the data for database and wordpress
2. wiez-database is the mysql instance with data from wiez-volumes
3. wiez-wordpress is the wordpress container with data from wiez-volumes

# Build (local)
* `docker build -t wiez-volumes:latest volumes/` 
* `docker build -t wiez-wordpress:latest wordpress/`

# Run (from local images)
... use the shell script **`run-all.sh`**:

* Data volume: `docker run --name wiez-volumes -v $(pwd)/data/var/lib/mysql:/var/lib/mysql -v $(pwd)/data/var/www/html:/var/www/html -d wiez-volumes tail -f /dev/null`
    + parameter: `--name wiez-volumes` gives the name `wiez-volumes` to the container, so other containers can see it
    + parameter `--v \$(pwd)/data/var/www/html:/var/www/html` mounts the host directory $(pwd)/data/var/www/html in container as /var/www/html 
    + parameter `--d` detaches the container (it is run in background)
    + parameter `wiez-volumes` is the name of the image to run
    + parameter `tail -f /dev/null` gives the command to execute (this one never ends)
  
* Database: `docker run --name wiez-database --volumes-from wiez-volumes -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql`
    + parameter `--name wiez-database` gives the name `wiez-database` to the container, so other containers can see it
    + parameter `--volumes-from wiez-volumes` links the container to `wiez-volumes`, so that the directory /var/lib/mysql is taken from wiez-volumes
    + parameter `-e MYSQL\_ROOT\_PASSWORD=mysecretpassword` passes the environment variable to the container _init script_

* Wordpress: `docker run --name wiez-wordpress --volumes-from wiez-volumes --link wiez-database:mysql -p 8080:80 -d wiez-wordpress:latest`
    + parameter `--name wiez-wordpress` gives the name `wiez-wordpress` to the container, so other containers can see it
    + parameter `--volumes-from wiez-volumes` links the container to `wiez-volumes`, so that the directory /var/www/html is taken from wiez-volumes
    + parameter `-p 8080:80` maps the port 80 of the container to the port 8080
    + parameter `-link wiez-database:mysql` links the container `link-wiez-database`as local name `mysql` 

# Backup/restore data
All data persist in `data/` directory, so do whatever you want ....

We launched `wiez-volumes` container with direct mapping to host directories (`-v` parameter). If it had been launched without mapping, we would have used the following commands

* backup
  docker run --name wiez-volumes -d wiez-volumes tail -f /dev/null
  docker run --volumes-from wiez-volumes -v $(pwd)/backups:/backups ubuntu tar cfz /backups/root.tgz /var/lib/mysql /var/www/html
 
* restore 
  docker run --name wiez-volumes -d wiez-volumes tail -f /dev/null
  docker run --volumes-from wiez-volumes -v $(pwd)/backups/:/backups ubuntu bash -c "cd / && tar xvfz /backups/root.tgz"


# Executing commands in container
docker exec -it _cid_ _command_
e.g. `docker exec -it 6f mysql` or `docker exec -it 6f /bin/sh`


# Orchestrating...
## Install crane
bash -c "`curl -sL https://raw.githubusercontent.com/michaelsauter/crane/master/download.sh`" && sudo mv crane /usr/local/bin/crane

### Using
crane lift
crane status 
... etc... 

## Problems 
1. cannot get local images to be run in crane
2. cannot mount host directories to the containes 

## for the very moment 


# apache as reverse_proxy (debian)
* create the virtual site /etc/apache2/sites-available/010-osrodek-wiez.conf
````apache
<VirtualHost *:80>
ServerName 127.0.0.1
ProxyPass 	 / 	http://172.17.0.1:8080
ProxyPassReverse /	http://172.17.0.1:8080
</VirtualHost> 
````
* ensure the proxy and proxy\_http modules are enabled, activate the virtual site and eventually restart apache 
````bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2ensite 010-osrodek-wiez.conf
service apache2 restart
````

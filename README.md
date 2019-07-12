## Setting up Image-Comparator in a Docker container ##

All code from the image-comparator can be found here: https://github.com/CollinWen/Image-Comparator

The dockerfile will automatically create a docker image for the Image-Comaparator and set up a database. A docker image can be run as a virtual linux system, which will be used to deploy the web server. Once the docker image is built and run, the admin can insert custom image datasets and create image classify/compare tasks.

To build a docker container, navigate to the dockerfile directory, and run the following command:
```
docker build . -t <name>:<tag> --build-arg db_name="<database name>" --build-arg host_local_ip="<host local ip>"
```

Once the image is build, you can run the docker image by the following command (note: to make the database and web server accessible locally, we must forward the port from the virtual machine to the actual system, which will allow all users in the network to access the ports):
```
docker run -p 5984:5984 -p 8080:8080 -it -v /data:/data cwen /bin/bash
```

The docker image will open port 5984 for couchdb access and port 8080 for web server access.

## Configuring Couchdb and adding Images ##

Note: the couchdb username and password are set to 'admin' and 'password' by default

To ensure that the database is accessible locally, check the following locations to make sure that all instances of bind_address are set to '0.0.0.0' (127.0.0.1 means that the database is only accessible on the host machine)
* /opt/couchdb/etc/local.ini
* /opt/couchdb/etc/default.ini
* /opt/couchdb/etc/default.d/10-bind-address.ini

Next confirm that CORS (cross-origin resource sharing) is enabled in the following locations
* /opt/couchdb/etc/default.ini
    * enable_cors = true
    * under '[cors]', add the following:
	* origins = *
	* credentials = true
	* methods = GET, PUT, POST, HEAD, DELETE
	* headers = accept, authorization, content-type, origin, referer, x-csrf-token
* /opt/couchdb/etc/local.ini
    * under '[httpd]', add the following:
	* enable_cors = true
    * at the bottom, add:
	* [cors]
	* origins = *
	* credentials = true
	* methods = GET, PUT, POST, HEAD, DELETE

Once you've confirmed the bind_address and CORS are configured properly, you must restart the couchdb server by using the following command:
```
service couchdb restart
```

-insert data

A useful tool to manage your couchdb database is to user project fauxton. If you've set up everything correctly, you should be able to view your database with the URL http://<host_local_ip>:5984/_utils
You can filter the documents in the database by going to the basic_views tab. There, you can filter specific documents and sort the documents cleanly.

## Starting the server ##

To start the web server, run the following command:
```
python -m SimpleHTTPServer 8080
```

Now you should be able to access the web server from any local machine with the URL http://<host_local_ip>:8080


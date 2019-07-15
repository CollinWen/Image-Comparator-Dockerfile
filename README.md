## Setting up Image-Comparator in a Docker container ##

All code for the Image-Comparator can be found here: https://github.com/CollinWen/Image-Comparator

The dockerfile will automatically create a docker image for the Image-Comaparator and set up a database. A docker image can be run as a virtual linux system, which will be used to deploy the web server. Once the docker image is built and run, the admin can insert custom image datasets and create image classify/compare tasks.

First, navigate to the Dockefile and replace <db_name> and <host_local_ip> with the preferred database name and the local ip of the host machine. **This is important as it will replace all occurences of 'rop_images' and '174.16.42.15' with your entered arguments. The server will not function properly if you skip this step.**

To build the docker images, run the following command:
```
docker build . -t <name>:<tag> --build-arg db_name="<database name>" --build-arg host_local_ip="<host local ip>"
```

Once the image is build, you can run the docker image by the following command (note: to make the database and web server accessible locally, we must forward the port from the virtual machine to the actual system, which will allow all users in the network to access the ports):
```
docker run -p 5984:5984 -p 8080:8080 -it -v /data:/data cwen /bin/bash
```

The docker image will open port 5984 for couchdb access and port 8080 for web server access.

## Configuring Couchdb and adding Images ##

To install couchdb, run the following:
```
echo "deb https://apache.bintray.com/couchdb-deb bionic main" \ | tee -a /etc/apt/sources.list
curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \ | apt-key add -
sudo apt-get update && apt-get install couchdb
```

Use the following configurations:
* 1: single node
* 0.0.0.0 bind address
* (password)

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

To finish configuring a single node setup, run the following;
```
curl -X PUT http://admin:<password>@localhost:5984/_users
curl -X PUT http://admin:<password>@localhost:5984/_replicator
```

To create and setup the database, run the following (use the db_name you used from the docker build command):
```
curl -X PUT http://admin:<password>@localhost:5984/<db_name>
cd /Image-Comparator/dbutil
curl -X PUT http://admin:<password>@localhost:5984/<db_name>/_design/basic_views -d @basic_views.json
```

-insert data

Your database is all set to go! A useful tool to manage your couchdb database is to user project fauxton. If you've set everything up correctly, you should be able to view your database with the URL http://<host_local_ip>:5984/_utils
You can filter the documents in the database by going to the basic_views tab. There, you can filter specific documents and sort the documents cleanly.

## Starting the server ##

To start the web server, run the following command:
```
python -m SimpleHTTPServer 8080
```

Now you should be able to access the web server from any local machine with the URL http://<host_local_ip>:8080


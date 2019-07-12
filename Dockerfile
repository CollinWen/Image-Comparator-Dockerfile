# Image-Comaparator Dockerfile
FROM ubuntu
MAINTAINER Collin Wen <collinwen@gmail.com>

# arguments
ARG db_name="rop_images"
ARG host_local_ip="172.16.42.15"

# install required packages
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y python
RUN apt-get install -y nodejs
RUN apt-get install -y ruby
RUN apt-get install -y vim
RUN apt-get install -y curl
RUN apt-get install -y apache2

# clone repository
RUN cd /
RUN git clone https://github.com/CollinWen/Image-Comparator.git


# install couchdb
RUN echo "deb http://apache.bintray.com/couchdb-deb bionic main" \ | tee -a /etc/apt/sources.list
RUN curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \ | apt-key add -
RUN apt-get update && apt-get install -y couchdb

# configure couchdb
# RUN 1
# RUN 0.0.0.0
# RUN password
# RUN password

# start couchdb
RUN service couchdb start
RUN curl -X PUT http://admin:password@127.0.0.1:5984/_users
RUN curl -X PUT http://admin:password@127.0.0.1:5984/_replicator

#TODO replace all instances of "rop_images" with $db_name
#TODO replace all instances of "172.16.42.15" with $host_local_ip

# Create database, add documents
RUN curl -X PUT http://admin:password@localhost:5984/$db_name
RUN cd Image-Comparator/dbutil
RUN curl -X PUT http://admin:password@localhost:5984/$db_name/_design/basic_views -d @basic_views.json

#TODO how to add custom image set

CMD ["echo","Image created"]

#!/bin/bash

yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
docker run -d -p 80:80 --name test-nginx nginx

echo '<html><body><h1>Esta es la EC2 1</h1></body></html>' | docker exec -i test-nginx tee /usr/share/nginx/html/index.html
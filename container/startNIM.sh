#!/bin/bash

if [ -f "/deployment/counter.enabled" ]
then
	export DATAPLANE_TYPE=NGINX_INSTANCE_MANAGER
	export DATAPLANE_FQDN="http://127.0.0.1:11000"
	export DATAPLANE_USERNAME="username@domain"
	export DATAPLANE_PASSWORD="thepassword"

	python3 /deployment/app.py &
fi

/usr/sbin/nginx-manager

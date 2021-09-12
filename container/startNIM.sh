#!/bin/bash

if [ -f "/deployment/counter.enabled" ]
then
	export NGINX_CONTROLLER_TYPE=NGINX_INSTANCE_MANAGER
	export NGINX_CONTROLLER_FQDN="http://127.0.0.1:11000"
	export NGINX_CONTROLLER_USERNAME="username@domain"
	export NGINX_CONTROLLER_PASSWORD="thepassword"

	python3 /deployment/app.py &
fi

/usr/sbin/nginx-manager

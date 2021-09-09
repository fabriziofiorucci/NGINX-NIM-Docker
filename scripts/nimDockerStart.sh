#!/bin/bash

CFGFILE=nim-files/nginx-manager.conf
LICFILE=nim-files/nginx-manager.lic
MANIFEST=manifests/0.nginx-nim.yaml
NAMESPACE=nginx-nim

case $1 in
	'start')
		if [ ! -f $CFGFILE ]
		then
			echo "$CFGFILE not found"
			exit
		fi

		if [ ! -f $LICFILE ]
		then
			echo "$LICFILE not found"
			exit
		fi

		echo "==> Creating ConfigMaps"

		kubectl create namespace $NAMESPACE
		kubectl create configmap nim-config -n $NAMESPACE --from-file=$CFGFILE
		kubectl create configmap nim-license -n $NAMESPACE --from-file=$LICFILE
		kubectl apply -f $MANIFEST -n $NAMESPACE
	;;
	'stop')
		kubectl delete namespace $NAMESPACE
	;;
	*)
		echo "$0 [start|stop]"
		exit
	;;
esac

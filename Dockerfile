FROM ubuntu:latest
ARG NIM_DEBFILE
ARG BUILD_WITH_COUNTER=false

RUN apt-get update

RUN apt-get install -y -q build-essential git nano curl jq
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then apt-get install -y python3-pip python3-dev python3-simplejson python3-requests python3-flask; fi

RUN mkdir deployment

COPY $NIM_DEBFILE /deployment/nim.deb
COPY ./container/startNIM.sh /deployment/
RUN dpkg -i /deployment/nim.deb
RUN rm /deployment/nim.deb

WORKDIR /deployment
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then touch /deployment/counter.enabled; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then git clone https://github.com/fabriziofiorucci/NGINX-InstanceCounter; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/app.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/bigiq.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/nim.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/nc.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp NGINX-InstanceCounter/nginx-instance-counter/cveDB.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then rm -rf NGINX-InstanceCounter; fi

WORKDIR /data
CMD /deployment/startNIM.sh

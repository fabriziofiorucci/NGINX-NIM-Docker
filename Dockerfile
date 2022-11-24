FROM ubuntu:22.04

ARG NIM_DEBFILE
ARG BUILD_WITH_SECONDSIGHT=false
ARG ACM_IMAGE=nim-files/.placeholder
ARG SM_IMAGE=nim-files/.placeholder

# Initial setup
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential git nano curl jq wget gawk \
		nginx lsb-release rsyslog systemd apt-transport-https ca-certificates netcat && \
	mkdir -p deployment/setup

# NGINX Instance Manager 2.4.0+
COPY $NIM_DEBFILE /deployment/setup/nim.deb
COPY $ACM_IMAGE /deployment/setup/acm.deb
COPY $SM_IMAGE /deployment/setup/sm.deb

COPY ./container/startNIM.sh /deployment/
RUN chmod +x /deployment/startNIM.sh

WORKDIR /deployment/setup

COPY $NIM_DEBFILE /deployment/setup/nim.deb

RUN apt-get -y install /deployment/setup/nim.deb && \
	curl -s http://hg.nginx.org/nginx.org/raw-file/tip/xml/en/security_advisories.xml > /usr/share/nms/cve.xml

# Optional API Connectivity Manager
RUN if [ "$ACM_IMAGE" != "nim-files/.placeholder" ] ; then \
	apt-get -y install /deployment/setup/acm.deb; fi

# Optional Security Monitoring
RUN if [ "$SM_IMAGE" != "nim-files/.placeholder" ] ; then \
	apt-get -y install /deployment/setup/sm.deb; fi

RUN rm -r /deployment/setup

# Optional Second Sight
WORKDIR /deployment
RUN if [ "$BUILD_WITH_SECONDSIGHT" = "true" ] ; then \
        apt-get install -y -q build-essential python3-pip python3-dev python3-simplejson git nano curl && \
        pip3 install fastapi uvicorn requests clickhouse-driver python-dateutil flask && \
	touch /deployment/counter.enabled && \
	git clone https://github.com/F5Networks/SecondSight && \
	cp SecondSight/f5tt/app.py . && \
	cp SecondSight/f5tt/bigiq.py . && \
	cp SecondSight/f5tt/cveDB.py . && \
	cp SecondSight/f5tt/f5ttCH.py . && \
	cp SecondSight/f5tt/f5ttfs.py . && \
	cp SecondSight/f5tt/nms.py . && \
	cp SecondSight/f5tt/utils.py . && \
	rm -rf SecondSight; fi
	
WORKDIR /deployment
CMD /deployment/startNIM.sh

FROM ubuntu:latest
ARG NIM_DEBFILE
ARG BUILD_WITH_COUNTER=false

RUN apt-get update

RUN apt-get install -y -q build-essential git nano curl jq
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then apt-get install -y python3-pip python3-dev python3-simplejson; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then pip3 install fastapi uvicorn requests pandas xlsxwriter jinja2; fi

RUN mkdir deployment

COPY $NIM_DEBFILE /deployment/nim.deb
COPY ./container/startNIM.sh /deployment/
RUN dpkg -i /deployment/nim.deb
RUN rm /deployment/nim.deb

WORKDIR /deployment
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then touch /deployment/counter.enabled; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then git clone https://github.com/fabriziofiorucci/F5-Telemetry-Tracker; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/app.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/bigiq.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/nim.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/nms.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/nc.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then cp F5-Telemetry-Tracker/f5tt/cveDB.py .; fi
RUN if [ "$BUILD_WITH_COUNTER" = "true" ] ; then rm -rf F5-Telemetry-Tracker; fi

WORKDIR /data
CMD /deployment/startNIM.sh

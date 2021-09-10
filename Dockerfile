FROM ubuntu:latest
ARG NIM_DEBFILE

RUN apt-get update

RUN apt-get install -y -q build-essential git nano curl jq

RUN mkdir deployment

COPY $NIM_DEBFILE /deployment/nim.deb
RUN dpkg -i /deployment/nim.deb
RUN rm /deployment/nim.deb

WORKDIR /data
CMD /usr/sbin/nginx-manager

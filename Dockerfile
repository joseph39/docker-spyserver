FROM centos

ARG TARGETPLATFORM
ENV TARGETPLATFORM "$TARGETPLATFORM"

RUN yum -y update \
  && yum -y groupinstall 'Development Tools' \
  && yum -y install unzip libusbx-devel wget cmake

RUN wget https://github.com/airspy/airspyone_host/archive/v1.0.9.tar.gz \
  && tar -xvzf v1.0.9.tar.gz \
  && cd airspyone_host-1.0.9/libairspy \
  && mkdir build \
  && cd build \
  && cmake ../ -DINSTALL_UDEV_RULES=ON \
  && make \
  && make install

ENV LD_LIBRARY_PATH /usr/local/lib/

RUN set -ex; \
  if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    wget https://airspy.com/downloads/spyserver-linux-x64.tgz;\
    tar xvzf spyserver-linux-x64.tgz;\
    rm spyserver-linux-x64.tgz;\
  elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then \
    wget https://airspy.com/downloads/spyserver-arm32.tgz;\
    tar xvzf spyserver-arm32.tgz;\
    rm spyserver-arm32.tgz;\
  fi;

RUN mv spyserver spyserver_ping /usr/bin && \
    mkdir -p /etc/spyserver && \
    mv spyserver.config /etc/spyserver

COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]

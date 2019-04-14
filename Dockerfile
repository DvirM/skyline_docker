FROM ubuntu:16.04 as base
RUN apt-get update && apt-get install build-essential checkinstall sudo vim git wget memcached libmemcached-tools libevent-dev python-pip libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev apache2 debconf-utils net-tools  -y
WORKDIR /
RUN git clone https://github.com/wix-playground/skyline.git
ENV PYTHONPATH=/usr/local/lib/python2.7/dist-packages:$PYTHONPATH
RUN sh /skyline/scripts/install_environment.sh

FROM base as run_skyline
ENV WORKSPACE_DIR=/skyline
COPY . $WORKSPACE_DIR
EXPOSE 1500 3306 2024 443
CMD ["bash", "-c", "/skyline/docker_scripts/init.sh"]

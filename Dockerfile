# vim:set ft=dockerfile:

# VERSION 1.0
# AUTHOR:         Alexander Turcic <alex@zeitgeist.se>
# DESCRIPTION:    Tool in a Docker container to unlock a HDD that is password-protected with a newer Lenovo Thinkpad Bios
# TO_BUILD:       docker build --rm -t zeitgeist/docker-lenovo .
# SOURCE:         https://github.com/alexzeitgeist/docker-lenovo

# Pull base image.
FROM debian:jessie
MAINTAINER Alexander Turcic "alex@zeitgeist.se"

# Build hdparm, patched to allow for null-character passwords
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc \
  	make \
  	patch \
    wget && \
  wget http://garr.dl.sourceforge.net/project/hdparm/hdparm/hdparm-9.45.tar.gz && \
  tar xvzf hdparm-9.45.tar.gz && \
  cd hdparm-9.45 && \
  wget https://raw.githubusercontent.com/jethrogb/lenovo-password/master/hdparm.patch && \
  patch -p1 < hdparm.patch && \
  make && make install && \
  cd .. && rm hdparm-9.45.tar.gz && rm -rf hdparm-9.45 && \
  apt-get -y purge gcc git make wget && \
  apt-get -y autoremove --purge && \
  rm -rf /var/lib/apt/lists/*

# Install Lenovo HDD ruby app
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  	git \
    ruby && \
  git clone https://github.com/jethrogb/lenovo-password.git && \
  apt-get -y purge git && \
  apt-get -y autoremove --purge && \
  rm -rf /var/lib/apt/lists/*

CMD ["ruby", "/lenovo-password/pw.rb"]

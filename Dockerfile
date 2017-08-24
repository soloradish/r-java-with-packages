FROM rocker/r-base:latest

MAINTAINER LowID <zhangtongtong@ciphertrading.com>

## gnupg is needed to add new key
RUN apt-get update && apt-get install -y gnupg2

## Install Java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee /etc/apt/sources.list.d/webupd8team-java.list \
    &&  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" \
        | /usr/bin/debconf-set-selections \
    && apt-get update \
    && apt-get install -y oracle-java8-installer \
    && update-alternatives --display java \
    && apt-get install -y r-cran-rmysql unixodbc-dev libcurl3-dev\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && R CMD javareconf

## make sure Java can be found in rApache and other daemons not looking in R ldpaths
RUN echo "/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server/" > /etc/ld.so.conf.d/rJava.conf
RUN /sbin/ldconfig

## Install rJava package
RUN install2.r --error rJava stringi R.utils mailR xts xlsx \
	properties RODBC Rserve pa kernlab PerformanceAnalytics \
	plyr jsonlite quantmod \
  && rm -rf /tmp/* /var/tmp/*

RUN mkdir -p /cipher/cloud
VOLUME /cipher/cloud

ENV SAAS_R_HOME /cipher/cloud
